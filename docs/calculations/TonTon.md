# TonTon — TT2 and Hidden Freak HF1

TonTon looks for unusual combinations of current attributes, quality above similar-CA peers, future opportunity and overlooked value. It is separate from LabLogic and is labelled Experimental Attribute Model. It does not simulate the match engine or predict wins.

Each position has weighted attribute groups. A group's value is its mean converted attribute /20 ×5. Role quality is the weighted harmonic mean: `1 / sum(groupWeight/groupValue)`. Multiply by `min(roleFit,sideFit,20)/20` (GK uses role for side) to obtain Monster /100. Both familiarity values must reach 15. Example: equally weighted group values 80 and 60 give harmonic quality 68.57, before familiarity.

Comparison populations cover the whole loaded save, not the visible filters. Similar-CA bands begin ±10, expand to ±20 then ±30 until at least 60 peers; require at least 100 players in the role. Use median quality and MAD. Excess = Monster − peer median. Robust residual z = excess/max(3,1.4826×MAD) × n/(n+30). Surplus pp compares actual and expected quality percentiles in the full role population; tied percentiles use midranks.

Standard discovery rank = Monster × (0.8 + 0.2 × clamp(z/3,0,1)). Future opportunity uses 50% current Monster +25% PA/200 +15% headroom/60 +10% (23−age)/7, component-clamped to 0–100; age <=23 and known PA >=CA are required. This is opportunity, not projected attributes.

Value score = 60% Monster +40% inverse price percentile among same-role players within five points of rounded quality (at least 30 known prices). League comparisons require adequate same-division populations; cheap tags check value and wage percentiles and avoid treating a loan destination as the owner.

Hidden Freak defaults cap CA at125 and recorded value at £2m (editable), with no automatic age cap or name blacklist. Hiddenness uses inverse CA/value/current-reputation/owning-club-reputation percentiles, weights 25/35/25/15%, combined geometrically over available components (CA/value and >=2 components required). Hiddenness = visibility × (0.5+0.5×clamped residual strength). Hidden rank =45% residual strength +35% Hiddenness +10% risk review +10% value score. Full exact elite gates and role groups follow below. Rankings are not success probabilities.

## Implemented role groups and TT2 calculations

```js
// TT2: original experimental multi-axis model. No external formula/weight code.
// Role groups are declared modelling assumptions, not verified engine coefficients.
const tt2Groups={
 GK:[['Shot stopping',.5,['Handling','Reflexes','OneOnOnes']],['Athletic coverage',.3,['Agility','Anticipation','Positioning']],['Decisions',.2,['Decisions','Teamwork']]],
 CB:[['Defending',.4,['Marking','Positioning','Tackling']],['Aerial strength',.3,['Jumping','Heading','Strength']],['Mobility',.15,['Pace','Acceleration','Agility']],['Distribution',.15,['Passing','Teamwork','Decisions']]],
 LB:[['Defending',.25,['Marking','Positioning','Tackling']],['Wide contribution',.3,['Dribbling','Crossing','Movement']],['Mobility',.3,['Pace','Acceleration','Stamina']],['Link play',.15,['Technique','Decisions','Teamwork']]],
 LWB:[['Wide contribution',.4,['Dribbling','Crossing','Movement']],['Mobility',.3,['Pace','Acceleration','Stamina']],['Defending',.15,['Positioning','Tackling']],['Link play',.15,['Technique','Decisions','Teamwork']]],
 DMC:[['Ball winning',.35,['Positioning','Tackling','Anticipation']],['Distribution',.3,['Passing','Technique','Vision']],['Physical coverage',.2,['Stamina','Strength','Pace']],['Support',.15,['Teamwork','WorkRate','Decisions']]],
 CM:[['Ball control',.35,['Passing','Technique','Vision']],['Movement',.25,['Movement','Dribbling']],['Physical coverage',.2,['Stamina','Pace','Acceleration']],['Support',.2,['Teamwork','WorkRate','Decisions']]],
 AMC:[['Creation',.4,['Dribbling','Technique','Passing','Vision']],['Attacking movement',.3,['Movement','Anticipation','Finishing']],['Mobility',.2,['Pace','Acceleration','Agility']],['Support',.1,['Decisions','Teamwork']]],
 LW:[['Wide threat',.35,['Dribbling','Crossing','Technique']],['Attacking movement',.25,['Movement','Finishing']],['Mobility',.3,['Pace','Acceleration','Agility','Stamina']],['Support',.1,['Decisions','Teamwork','WorkRate']]],
 ST:[['Goal threat',.4,['Finishing','Movement','Anticipation']],['Link play',.2,['Dribbling','Technique','Passing']],['Mobility',.25,['Pace','Acceleration','Agility','Stamina']],['Aerial strength',.15,['Jumping','Heading','Strength']]]
};
const tt2Alias={RB:'LB',RWB:'LWB',SW:'CB',LM:'LW',RM:'LW',RW:'LW'};
const tt2ClassicKeys=['Technique','Flair','Determination','Movement'];
let tt2Revision=0,ttAllRows=[],tt2State={version:1,patchFingerprint:'',benchmark:null},tt2StorageRaw=null,tt2StorageBlocked=false;
const tt2StorageKey='cmlab-tonton-evidence-v2';
function tt2Signature(){return TT_VERSION+':groups-1:'+tt2State.patchFingerprint+':'+tt2Revision}
function ttRoleScore(p,role){const d=labDefinition(role),groups=tt2Groups[tt2Alias[role]||role];if(!d||!groups||!Number.isFinite(p.ca)||p.ca<0||p.ca>200)return null;const roleFit=p.posRaw?.[d[1]],sideFit=d[2]===null?roleFit:p.posRaw?.[d[2]];if(!Number.isFinite(roleFit)||!Number.isFinite(sideFit)||roleFit<15||sideFit<15)return null;
 const axes=groups.map(([name,weight,keys])=>{const values=keys.map(key=>labAttribute(p,key));return {name,weight,keys,values,value:values.every(Number.isFinite)?values.reduce((a,b)=>a+b,0)/values.length*5:null}});if(axes.some(a=>a.value===null))return null;
 const weights=new Map();for(const axis of axes)for(const key of axis.keys)weights.set(key,(weights.get(key)||0)+axis.weight/axis.keys.length);const attributes=[...weights].map(([key,weight])=>({key,weight,value:labAttribute(p,key)}));const quality=1/axes.reduce((sum,a)=>sum+a.weight/a.value,0),fit=Math.min(20,roleFit,sideFit)/20;
 return {monster:quality*fit,quality,fit,axes,attributes,role,t1:ttT1RoleScore(p,role)?.monster??null,weakest:Math.min(...axes.map(a=>a.value)),evidence:'Experimental attribute model'}
}
function tt2Classic(p,role=null){const values=tt2ClassicKeys.map(k=>labAttribute(p,k)),minimum=Number($('tontonClassicMin').value)||14;return {values,minimum,score:values.every(Number.isFinite)?Math.pow(values.reduce((a,b)=>a*b,1),.25)*5:null,match:role!=='GK'&&values.every(v=>Number.isFinite(v)&&v>=minimum)}}
function tt2Risks(p,row){const risks=[];for(const axis of row.axes)if(axis.value<50)risks.push(axis.name+' '+axis.value.toFixed(1)+'/100: uneven role profile');for(const [key,limit,label] of [['Consistency',8,'Low consistency'],['ImportantMatches',6,'Low important-matches attribute'],['Professionalism',6,'Low professionalism: development context only']]){const v=labAttribute(p,key);if(v===null)risks.push(niceAttribute(key)+' unavailable');else if(v<limit)risks.push(label+' '+v+'/20')}const injury=labAttribute(p,'InjuryProneness');if(injury!==null&&injury>=16)risks.push('High stored injury proneness '+injury+'/20; current injuries are unknown');return risks}
function tt2RiskReview(p,row){const consistency=labAttribute(p,'Consistency'),important=labAttribute(p,'ImportantMatches');return row.weakest>=45&&consistency!==null&&consistency>=8&&important!==null&&important>=6}
function tt2DiscoveryRank(monster,z){return monster*(.8+.2*(z===null?0:ttClamp(z/3*100))/100)}
function ttBuild(){const signature=tt2Signature();if(ttCache?.players===PLAYERS&&ttCache.signature===signature)return ttCache;const groups=new Map(),result=[];
 for(const [role] of pitchDefinitions){const rows=PLAYERS.map(player=>{const score=ttRoleScore(player,role);return score?{player,...score}:null}).filter(Boolean);groups.set(role,{rows,scores:rows.map(r=>r.monster).sort((a,b)=>a-b),cas:rows.map(r=>r.player.ca).sort((a,b)=>a-b),peers:new Map(),values:new Map(),levels:new Map()})}
 for(const [role,g] of groups){for(const row of g.rows){const p=row.player,ca=Math.round(p.ca);if(!g.peers.has(ca)){let band=10,peers=[];for(const width of [10,20,30]){band=width;peers=g.rows.filter(r=>Math.abs(r.player.ca-ca)<=width);if(peers.length>=60)break}const values=peers.map(r=>r.monster).sort((a,b)=>a-b),median=ttMedian(values),mad=median===null?null:ttMedian(values.map(v=>Math.abs(v-median)).sort((a,b)=>a-b));g.peers.set(ca,{n:peers.length,band,median,mad,valid:g.rows.length>=100&&peers.length>=60})}const peer=g.peers.get(ca),percentile=ttPercentile(g.scores,row.monster),expected=peer.valid?ttPercentile(g.scores,peer.median):null,excess=peer.valid?row.monster-peer.median:null,surplusZ=peer.valid?excess/Math.max(3,peer.mad*1.4826)*peer.n/(peer.n+30):null;
 const bucket=Math.round(row.monster);if(!g.values.has(bucket)){const peers=g.rows.filter(r=>Math.abs(r.monster-bucket)<=5);g.values.set(bucket,{prices:peers.map(r=>r.player.value).filter(v=>Number.isFinite(v)&&v>=0).sort((a,b)=>a-b),wages:peers.map(r=>r.player.wage).filter(v=>Number.isFinite(v)&&v>=0).sort((a,b)=>a-b)})}const pricePeers=g.values.get(bucket),prices=pricePeers.prices,value=Number.isFinite(p.value)&&p.value>=0&&prices.length>=30?.6*row.monster+.4*(100-ttPercentile(prices,p.value)):null;
 const division=p.division;if(division&&!g.levels.has(division)){const rows=g.rows.filter(r=>r.player.division===division);g.levels.set(division,{length:rows.length,scores:rows.map(r=>r.monster).sort((a,b)=>a-b),prices:rows.map(r=>r.player.value).filter(v=>Number.isFinite(v)&&v>=0).sort((a,b)=>a-b),wages:rows.map(r=>r.player.wage).filter(v=>Number.isFinite(v)&&v>=0).sort((a,b)=>a-b)})}const level=division?g.levels.get(division):{length:0,scores:[],prices:[],wages:[]},levelPercentile=level.length>=30?ttPercentile(level.scores,row.monster):null,levelPrices=level.prices,levelWages=level.wages;const cheap=levelPrices.length>=30&&levelWages.length>=30&&Number.isFinite(p.value)&&p.value>=0&&Number.isFinite(p.wage)&&p.wage>=0&&ttPercentile(levelPrices,p.value)<=35&&ttPercentile(levelWages,p.wage)<=50;
 const risks=tt2Risks(p,row),reviewed=tt2RiskReview(p,row),future=ttFuture(p,row.monster),tags=[];
 if(row.monster>=72&&percentile>=95&&excess>=6&&surplusZ>=1.25&&reviewed)tags.push('Game Breaker');
 if(row.monster>=60&&levelPercentile!==null&&levelPercentile>=85&&cheap&&reviewed&&!loanInfo(p))tags.push('Cult Hero');
 if(g.rows.length>=100&&peer.valid&&future!==null&&p.age<=23&&p.pa-p.ca>=25&&row.monster>=65&&percentile>=80&&reviewed&&labAttribute(p,'Professionalism')>=8&&labAttribute(p,'Determination')>=10)tags.push('Future Monster');
 const surplusStrength=surplusZ===null?0:ttClamp(surplusZ/3*100),rankScore=tt2DiscoveryRank(row.monster,surplusZ),evidenceCoverage=peer.valid?'Stable CA comparison':'CA comparison unavailable';
 result.push({...row,population:g.rows.length,percentile,caPercentile:ttPercentile(g.cas,p.ca),peer,surplus:expected===null?null:percentile-expected,surplusZ,excess,future,value,valueN:prices.length,medianValue:ttMedian(prices),levelN:level.length,levelPercentile,tags,risks,reviewed,rankScore,evidenceCoverage})}}
 ttCache={players:PLAYERS,signature,groups,rows:result};return ttCache}

```

## Hidden Freak definitions and elite gates

```js
// HF1 discovery policy. TT2 role effectiveness and its tracking version are unchanged.
let ttHiddenCache=null,ttModeContext='now',ttModeResetting=false;
const ttModeLimits={now:{ca:'',value:'',age:'',minPa:'',maxPa:''},hidden:{ca:'125',value:'2000000',age:'',minPa:'',maxPa:''},future:{ca:'',value:'',age:'',minPa:'',maxPa:''}};
function ttSyncModeLimits(){if(ttModeResetting)return;const mode=$('tontonMode').value||'now';if(mode===ttModeContext)return;ttModeLimits[ttModeContext]={ca:$('tontonCa').value,value:$('tontonValue').value,age:$('tontonAge').value,minPa:$('tontonMinPa').value,maxPa:$('tontonMaxPa').value};const limits=ttModeLimits[mode];$('tontonCa').value=limits.ca;$('tontonValue').value=limits.value;$('tontonAge').value=limits.age;$('tontonMinPa').value=limits.minPa;$('tontonMaxPa').value=limits.maxPa;ttModeContext=mode;ttSort={key:'rankScore',desc:true};ttPage=0}
function ttHiddenCaps(){return ($('tontonMode').value||'now')==='hidden'?{ca:$('tontonCa').value,value:$('tontonValue').value}:ttModeLimits.hidden}
function ttHiddenEligible(p){const {ca,value}=ttHiddenCaps();return Number.isFinite(p.ca)&&p.ca>=0&&p.ca<=200&&Number.isFinite(p.value)&&p.value>=0&&(ca===''||p.ca<=Number(ca))&&(value===''||p.value<=Number(value))}
function ttHiddenPopulation(){const build=ttBuild();if(ttHiddenCache?.build===build)return ttHiddenCache;const clubReputations=new Map();for(const p of PLAYERS)if(p.clubId>=0&&Number.isFinite(p.clubReputation)&&p.clubReputation>=0&&p.clubReputation<=10000)clubReputations.set(p.clubId,p.clubReputation);const ownerRep=p=>clubReputations.get(opportunityOwner(p))??null,roles=new Map();for(const [role,g] of build.groups){const sorted=key=>g.rows.map(r=>key==='owner'?ownerRep(r.player):r.player[key]).filter(v=>Number.isFinite(v)&&v>=0&&(key!=='currentReputation'||v<=10000)).sort((a,b)=>a-b);roles.set(role,{ca:sorted('ca'),value:sorted('value'),reputation:sorted('currentReputation'),club:sorted('owner')})}ttHiddenCache={build,roles,ownerRep,analyses:new WeakMap()};return ttHiddenCache}
function ttHiddenAnalysis(row){const cache=ttHiddenPopulation();if(cache.analyses.has(row))return cache.analyses.get(row);const p=row.player,pop=cache.roles.get(row.role),parts=[];for(const [key,label,weight,value,values] of [['ca','Low CA',.25,p.ca,pop.ca],['value','Low recorded valuation',.35,p.value,pop.value],['reputation','Low current reputation',.25,p.currentReputation,pop.reputation],['club','Low owning-club stature',.15,cache.ownerRep(p),pop.club]]){const valid=Number.isFinite(value)&&value>=0&&(key!=='reputation'||value<=10000)&&values.length>=100,percentile=valid?ttPercentile(values,value):null;parts.push({key,label,weight,value,percentile,score:percentile===null?null:Math.max(1,100-percentile)})}const known=parts.filter(p=>p.score!==null),weight=known.reduce((s,p)=>s+p.weight,0),visibility=known.length>=2&&parts[0].score!==null&&parts[1].score!==null?Math.exp(known.reduce((s,p)=>s+p.weight*Math.log(p.score),0)/weight):null,surplus=row.surplusZ===null?0:ttClamp(row.surplusZ/3*100),score=visibility===null?null:visibility*(.5+.5*surplus/100),review=row.reviewed?100:50,value=Number.isFinite(row.value)?row.value:0,rank=score===null?0:.45*surplus+.35*score+.10*review+.10*value;const result={score,visibility,parts,coverage:known.length,surplus,review,value,rank};cache.analyses.set(row,result);return result}
function ttModeRank(row){return ($('tontonMode').value||'now')==='hidden'?ttHiddenAnalysis(row).rank:row.rankScore}
function ttHiddenElite(row){const h=ttHiddenAnalysis(row);return ttHiddenEligible(row.player)&&row.monster>=60&&row.excess>=7&&row.surplusZ>=1.5&&row.surplus>=10&&row.reviewed&&h.coverage>=3&&h.score!==null&&h.score>=55}
function ttEliteForMode(row){return ($('tontonMode').value||'now')==='hidden'?ttHiddenElite(row):row.tags.length>0}

```
