# Player training recommendations (V2)

Exactly eight shared schedules are available; no per-player variants or ninth slot are generated. User settings/slot mappings are preserved and changes require explicit review. Defaults: Goalkeeping, Defensive, Technical, Attacking, Physical, Elite Development, Low Load and Balanced. The historical `recovery` key is retained for compatibility; legacy Recovery is not silently treated as applied Balanced.

Workload points map None/Light/Medium/Intensive to 0/1/2/4, with Fitness doubled. Example: Balanced (Medium in four outfield areas, no goalkeeping) costs 10 points. Capacity starts with (Natural Fitness + max(Stamina,Strength))/2 minus the configured safety margin, then adjusts for missing data, saved injury proneness, age and any actually available condition/injury observations. Capacity is a heuristic, not a proven engine limit.

Position-specific target deficits and importance produce training-need weights. Programmes are evaluated from their actual category intensities, role focus, known PA headroom and workload-risk penalties. Marginal overload is not an automatic rejection. Goalkeepers/outfield players and Elite Development have separate eligibility gates. Physical attributes alone do not establish injury recovery needs. Application records require user confirmation; recommendations never write game training assignments.

The exact scoring, target tables, eligibility gates, capacity adjustments and review/stability logic are included below from the working implementation. They are CM Lab modelling assumptions; the community-derived training-effect groups are not independently certified for every patched executable. Missing condition, injury, minutes and routine data remain missing.

## Current implementation

```js
// CM Lab recommendation model. Settings are planning data, never game writes.
const trainingCategories=['Fitness','Tactics','Shooting','Skills','Goalkeeping'];
const trainingLevels=['None','Light','Medium','Intensive'];
const trainingDefaults=[
 ['gk','Goalkeeping',[2,3,0,1,3]],['defensive','Defensive',[2,3,1,3,0]],
 ['technical','Technical',[2,3,2,3,0]],['attacking','Attacking',[2,3,3,2,0]],
 ['physical','Physical',[3,2,2,3,0]],['elite','Elite Development',[3,3,1,3,0]],
 ['low','Low Load',[2,2,1,3,0]],['recovery','Balanced',[2,2,2,2,0]]
];
// Direct-training groups reported by John North's engine investigation (2026-08-20).
// Experimental on this patched installation. Unlisted attributes earn no benefit.
const trainingEffects={Fitness:['Acceleration','Agility','Jumping','NaturalFitness','Pace','Reflexes','Stamina','Strength'],Tactics:['Decisions','Marking','Movement','Teamwork','Positioning'],Shooting:['Finishing','LongShots','Penalties'],Skills:['Corners','Crossing','Dribbling','FreeKicks','Heading','Passing','Tackling','Technique','ThrowIns'],Goalkeeping:['Handling','OneOnOnes']};
const trainingPriorities={GK:['Handling','Reflexes','OneOnOnes','Agility','Positioning'],CB:['Positioning','Marking','Tackling','Jumping','Heading','Strength'],LB:['Pace','Stamina','Crossing','Tackling','Positioning'],DMC:['Positioning','Tackling','Passing','Decisions','Stamina'],CM:['Passing','Technique','Decisions','Teamwork','Stamina'],LW:['Crossing','Dribbling','Pace','Technique','Movement'],AMC:['Technique','Passing','Dribbling','Decisions','Movement'],ST:['Movement','Finishing','Acceleration','Jumping','Heading','Technique']};
for(const [to,from] of [['RB','LB'],['LWB','LB'],['RWB','LB'],['SW','CB'],['LM','LW'],['RM','LW'],['RW','LW']])trainingPriorities[to]=trainingPriorities[from];
const trainingStatusOrder=['Medical Review Required','Workload Concern','Change Recommended','Development Review Due','Recommended','Applied','Verified','Locked'];
const trainingDay=date=>Date.parse(date+'T00:00:00Z')/86400000;
const trainingAddDays=(date,days)=>new Date((trainingDay(date)+days)*86400000).toISOString().slice(0,10);
function trainingWorkload(programme){return programme.levels.reduce((n,l,i)=>n+([0,1,2,4][l]||0)*(i===0?2:1),0)}
function trainingRole(p,entry){if(entry?.role&&pitchDefinitions.some(([r])=>r===entry.role))return entry.role;const eligible=pitchDefinitions.filter(([r])=>matchesPitch(p,r,15));return eligible.slice().sort((a,b)=>(labScore(p,b[0])??-1)-(labScore(p,a[0])??-1)||pitchDefinitions.indexOf(a)-pitchDefinitions.indexOf(b))[0]?.[0]||pitchRoles(p)[0]||null}
function trainingAttributes(p){return Object.fromEntries(['NaturalFitness','Stamina','Strength','InjuryProneness','Professionalism','Determination',...new Set(Object.values(trainingPriorities).flat())].map(k=>{const raw=p.attributes?.[k],direct=['NaturalFitness','Stamina','Strength','InjuryProneness','Professionalism','Determination'].includes(k);return [k,direct&&(!Number.isFinite(raw)||raw<1||raw>20)?null:labAttribute(p,k)]}))}
function trainingCapacity(p,entry,date,settings){const attrs=trainingAttributes(p),nf=attrs.NaturalFitness,physical=[attrs.Stamina,attrs.Strength].filter(Number.isFinite),known=nf!==null&&physical.length===2;const raw=nf!==null&&physical.length?(nf+Math.max(...physical))/2:null;let allowance=(raw??10)-(settings.margin??1);const reasons=[];
 if(!known){allowance=Math.min(allowance,9);reasons.push('Incomplete fitness attributes: conservative allowance and reduced confidence.')}
 if(attrs.InjuryProneness===null){allowance-=1;reasons.push('Injury proneness unavailable: extra workload margin.')}else if(attrs.InjuryProneness>=15){allowance-=2;reasons.push('High saved injury proneness reduces the allowance.')}else if(attrs.InjuryProneness>=10)allowance-=1;
 if(p.age===null){allowance-=1;reasons.push('Age unavailable.')}else if(p.age>=32){allowance-=2;reasons.push('Age 32+: physical maintenance margin.')}else if(p.age>=29)allowance-=1;
 const observations=(entry?.observations||[]).filter(o=>o.date<=date),recent=observations.filter(o=>trainingDay(date)-trainingDay(o.date)<=28&&Number.isFinite(o.condition));const condition=Number.isFinite(p.condition)?p.condition:null;
 // A single post-match condition observation never triggers a recovery decision.
 const persistentLow=condition!==null&&condition<80&&recent.length>=3&&trainingDay(recent.at(-1).date)-trainingDay(recent[0].date)>=7&&recent.slice(-3).every(o=>o.condition<80);
 if(condition!==null&&condition<90){allowance-=1;reasons.push('Current condition is below 90%; one observation does not establish poor recovery.')}
 if(persistentLow){allowance=Math.min(allowance,6);reasons.push('Repeated low condition across at least three dated saves: review recovery and match exposure.')}
 const injured=p.injuryStatus===true;
 if(injured){allowance=Math.min(allowance,6);reasons.push('Verified current injury: recovery takes priority.')}
 reasons.push('Current routine, injury status, condition and match minutes are unavailable unless explicitly decoded; missing values are not treated as healthy.');
 return {raw,allowance:Math.max(0,Math.round(allowance*10)/10),attrs,condition,injured,persistentLow,confidence:known?'Attribute-based; recovery evidence limited':'Reduced',reasons};
}
// Role expectations are explicit CM Lab targets, not game-engine growth promises.
// Each term is [target /20, importance]. Only trainingEffects can earn benefit.
const trainingExpectations={GK:{Handling:[16,4],Reflexes:[16,3],OneOnOnes:[15,3],Agility:[14,1],Positioning:[14,1]},CB:{Positioning:[16,4],Marking:[16,3],Tackling:[16,3],Jumping:[15,1],Heading:[15,2],Strength:[15,1]},LB:{Pace:[15,2],Stamina:[15,2],Crossing:[14,3],Tackling:[14,3],Positioning:[14,3]},DMC:{Positioning:[16,3],Tackling:[15,3],Passing:[15,3],Decisions:[15,3],Stamina:[15,1]},CM:{Passing:[16,4],Technique:[16,4],Decisions:[15,3],Teamwork:[14,2],Stamina:[14,1]},LW:{Crossing:[16,4],Dribbling:[16,4],Pace:[16,1],Technique:[15,2],Movement:[15,3]},AMC:{Technique:[16,3],Passing:[16,3],Dribbling:[16,3],Decisions:[15,2],Movement:[16,3]},ST:{Movement:[16,4],Finishing:[17,5],Acceleration:[15,1],Jumping:[13,1],Heading:[14,1],Technique:[14,1]}};
for(const [to,from] of [['RB','LB'],['LWB','LB'],['RWB','LB'],['SW','CB'],['LM','LW'],['RM','LW'],['RW','LW']])trainingExpectations[to]=trainingExpectations[from];
const trainingPreferences={GK:['gk'],CB:['defensive'],SW:['defensive'],LB:['defensive','physical'],RB:['defensive','physical'],LWB:['defensive','physical'],RWB:['defensive','physical'],DMC:['defensive','technical'],CM:['technical'],AMC:['technical','attacking'],LM:['attacking','technical'],RM:['attacking','technical'],LW:['attacking','technical'],RW:['attacking','technical'],ST:['attacking']};
function trainingFocusLabel(role){return (trainingPreferences[role]||[]).map(id=>trainingDefaults.find(d=>d[0]===id)?.[1]||id).join(' / ')||'Balanced assessment'}
function trainingNeeds(p,role,capacity){return Object.entries(trainingExpectations[role]||{}).map(([key,[target,importance]])=>{const value=capacity.attrs[key],category=trainingCategories.findIndex(c=>trainingEffects[c].includes(key));return {key,target,importance,value,category,deficit:Number.isFinite(value)?Math.max(0,target-value)/target:0}}).filter(t=>t.category>=0&&Number.isFinite(t.value)).map(t=>({...t,weight:t.importance*(.3+3*t.deficit)}))}
function trainingConfirmed(entry,date){return (entry?.applications||[]).filter(a=>a.date<=date&&a.confirmation==='user-confirmed-v2').at(-1)||null}
function trainingLegacyRecovery(pr){return pr.id==='recovery'&&pr.name==='Recovery'}
function trainingProgrammeScore(p,role,programme,capacity){const needs=trainingNeeds(p,role,capacity),weight=needs.reduce((s,n)=>s+n.weight,0),benefit=weight?needs.reduce((s,n)=>s+n.weight*programme.levels[n.category]/3,0)/weight*100:0,preferences=trainingPreferences[role]||[],preferred=preferences.indexOf(programme.id),headroom=p.paOriginal>=0&&Number.isFinite(p.pa)?Math.max(0,p.pa-p.ca):null;
 const robust=capacity.raw!==null&&capacity.raw>=16&&capacity.attrs.NaturalFitness>=15,elite=programme.id==='elite'&&p.age!==null&&p.age<=23&&headroom!==null&&headroom>=30&&robust;
 const roleBonus=preferred===0?18:preferred>0?12:programme.id==='recovery'?0:programme.id==='low'?-3:programme.id==='elite'?(elite?18:-20):-12;
 const workload=trainingWorkload(programme),excess=Math.max(0,workload-capacity.allowance-1),uncertainty=capacity.condition===null?1.15:1,riskPenalty=(1.6*excess+1.25*excess*excess)*uncertainty;
 // Half a point over a heuristic capacity is not a safety rejection. Confirmed
 // injury/poor recovery is handled separately, never inferred from low stamina.
 const score=benefit+roleBonus+(elite?Math.min(6,headroom/15):0)-riskPenalty;
 return {score,benefit,roleBonus,riskPenalty,emphasis:needs.filter(n=>programme.levels[n.category]>=2).sort((a,b)=>b.weight-a.weight).map(n=>n.key),headroom,needs,elite,workload};
}
function trainingCandidateAllowed(p,role,pr,capacity){if(trainingLegacyRecovery(pr))return false;if(role==='GK')return pr.id==='gk';if(pr.id==='gk')return false;if(pr.id==='elite'&&!(p.age!==null&&p.age<=23&&p.paOriginal>=0&&p.pa-p.ca>=30&&capacity.raw>=16&&capacity.attrs.NaturalFitness>=15))return false;
 // Programme names supply initial focus preferences, not fixed eligibility.
 // Actual category settings determine benefit and can outweigh those preferences.
 // Every shared outfield routine can win if its actual edited settings offer
 // enough benefit; the family preference cannot hide a better custom schedule.
 return true}

function trainingAssess(p,entry,state,date){const role=trainingRole(p,entry),capacity=trainingCapacity(p,entry,date,state.settings),applied=trainingConfirmed(entry,date),legacy=(entry?.applications||[]).some(a=>a.date<=date&&a.confirmation!=='user-confirmed-v2'),anchor=applied?(applied.reviewed&&applied.reviewed<=date?applied.reviewed:applied.date):date,days=applied?trainingDay(date)-trainingDay(anchor):null;
 const mapped=state.programmes.filter(pr=>pr.slot>0&&pr.slot<=state.settings.slots&&!state.programmes.some(o=>o.id!==pr.id&&o.slot===pr.slot)),permitted=mapped.filter(pr=>trainingCandidateAllowed(p,role,pr,capacity)),pool=permitted.length?permitted:mapped.length?mapped:state.programmes;
 const ranked=pool.map(programme=>({...trainingProgrammeScore(p,role,programme,capacity),programme})).sort((a,b)=>b.score-a.score||a.workload-b.workload||a.programme.id.localeCompare(b.programme.id));let best=ranked[0],status='Recommended',reason='New recommendation; no in-game application is assumed.';
 const original=applied?{id:applied.programme,name:applied.name||state.programmes.find(pr=>pr.id===applied.programme)?.name||'Recorded programme',levels:applied.levels?.slice()||state.programmes.find(pr=>pr.id===applied.programme)?.levels,slot:applied.slot}:null,current=original?.levels?{...trainingProgrammeScore(p,role,original,capacity),programme:original}:null,health=capacity.injured||capacity.persistentLow;
 if(health){best=ranked.slice().sort((a,b)=>a.workload-b.workload||b.score-a.score)[0];status='Medical Review Required';reason='Confirmed injury or repeated low-condition evidence: review rest and medical advice in game. Even the lightest shared routine is not automatically suitable.'}
 else if(current){const gain=best.score-current.score,due=days>=state.settings.cycleDays,changed=best.programme.id!==current.programme.id||JSON.stringify(best.programme.levels)!==JSON.stringify(current.programme.levels);
  if(due&&changed&&gain>=state.settings.threshold){status='Change Recommended';reason=`At the ${days}-day review, the alternative improves the development/risk model by ${gain.toFixed(1)} points.`}
  else{best=current;status=due?'Development Review Due':'Applied';reason=due?'No change recommended. Review the recorded programme and begin another cycle.':'No change recommended. Your confirmed programme remains established until the review.'}
 }
 if(entry?.locked&&current){best=current;status=health?'Medical Review Required':'Locked';reason=health?'Your choice is locked; confirmed recovery evidence still requires attention.':'Your confirmed programme is locked; safety and workload concerns remain visible.'}
 const overload=best.workload>capacity.allowance+4;if(!health&&overload){status='Workload Concern';reason+=' The estimate indicates a substantial workload mismatch, not a diagnosed injury. Review the shared Balanced/Low Load options or manually edit one of the existing eight routines.'}
 if(!permitted.length){status='Workload Concern';reason+=' No appropriate uniquely mapped programme is available; repair the existing eight slot mappings.'}
 const needs=trainingNeeds(p,role,capacity).sort((a,b)=>b.weight-a.weight),targets=needs.filter(n=>n.deficit>0).slice(0,3).map(n=>niceAttribute(n.key)+' '+n.value+'/20 (role target '+n.target+')');
 reason+=' Primary role '+(role||'unknown')+'; preferred focus '+trainingFocusLabel(role)+'. '+(targets.length?'Key development needs: '+targets.join(', ')+'. ':'No below-target role attributes were identified. ')+best.programme.name+' uses '+best.emphasis.slice(0,4).map(niceAttribute).join(', ')+' emphasis at load '+best.workload+' versus estimated allowance '+capacity.allowance+'.';
 if((trainingPreferences[role]||[]).includes(best.programme.id))reason+=' Its actual category settings support this role.';else reason+=' This shared alternative balances the measured attribute needs against estimated load; it is not an injury-recovery assignment.';
 const alternatives=ranked.filter(c=>c.programme.id!==best.programme.id).slice(0,3).map(c=>({name:c.programme.name,score:c.score,benefit:c.benefit,riskPenalty:c.riskPenalty,reason:applied&&c.score>best.score&&days<state.settings.cycleDays?'confirmed assignment retained until its scheduled review':Math.abs(c.benefit-best.benefit)<.000001&&Math.abs(c.riskPenalty-best.riskPenalty)<.000001?'same weighted attribute coverage; preferred role focus resolves the tie':c.riskPenalty>8?'larger estimated workload penalty':c.benefit<best.benefit?'less emphasis on weighted role needs':'no meaningful net advantage after role focus and workload risk'}));
 if(legacy&&!applied)reason+=' Previous-version application records are retained as legacy history. Reconfirm only if you actually applied those settings in CM.';
 return {p,role,focus:trainingFocusLabel(role),capacity,applied,legacy,assignmentState:applied?'Applied':'Recommended',days,nextReview:trainingAddDays(anchor,state.settings.cycleDays),programme:best.programme,workload:best.workload,score:best.score,emphasis:best.emphasis,headroom:best.headroom,status,reason,alternatives,overload,entry};
}

```
