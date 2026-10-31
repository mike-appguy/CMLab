# LabLogic v1 — calculation and positional attribute weights

This is CM Lab's transparent scouting model, not a verified CM 01/02 match-engine formula. The weights below are generated from the working lab_logic.js, including right-side aliases. PA, age, reputation, value and wage are not direct inputs to current LabLogic. CA affects the conversion of certain attributes, rather than contributing a separate score bonus.

## Score out of 100

For position weights w and converted attribute values a (1–20):

```text
weightedMean = sum(a * w) / sum(w)
attributeQuality = weightedMean / 20
roleFit = clamp(stored role familiarity, 0, 20) / 20
sideFit = clamp(stored side familiarity, 0, 20) / 20
LabLogic = 100 * (0.80 * attributeQuality + 0.10 * roleFit + 0.10 * sideFit)
```

Goalkeeper has no side requirement: sideFit = roleFit, giving **80% attributes + 20% goalkeeper familiarity**. The score is calculated before rounding; the interface normally shows one decimal place. Missing required attributes/familiarity produce an unknown score. Natural-position selection normally requires role and side familiarity of at least 15/20. Best LabLogic is the highest score over those natural positions. A tactic uses its exact role/side cell, not a player's overall best score.

Example: weightedMean 15/20 and natural role/side both 20/20 gives **80.0/100**. High PA does not increase this current-quality score.

## Position weights

Weights are relative within each position. An attribute with weight 3 contributes three times as much as one with weight 1. Its share of the complete score is 80% × weight / totalWeight. Familiarity supplies the remaining 20%.

| Position | Total weight | Attributes and weights |
| --- | ---: | --- |
| GK | 13 | Handling **3**; Reflexes **3**; One On Ones **2**; Agility **1**; Positioning **2**; Decisions **1**; Anticipation **1** |
| LB | 15 | Tackling **3**; Positioning **3**; Marking **2**; Pace **2**; Stamina **2**; Crossing **2**; Work Rate **1** |
| RB | 15 | Tackling **3**; Positioning **3**; Marking **2**; Pace **2**; Stamina **2**; Crossing **2**; Work Rate **1** |
| CB | 19 | Marking **3**; Tackling **3**; Positioning **3**; Heading **3**; Jumping **2**; Strength **2**; Anticipation **2**; Decisions **1** |
| SW | 16 | Anticipation **3**; Positioning **3**; Tackling **2**; Marking **2**; Pace **2**; Passing **2**; Decisions **2** |
| LWB | 16 | Crossing **3**; Pace **3**; Stamina **3**; Dribbling **2**; Work Rate **2**; Tackling **2**; Positioning **1** |
| RWB | 16 | Crossing **3**; Pace **3**; Stamina **3**; Dribbling **2**; Work Rate **2**; Tackling **2**; Positioning **1** |
| DMC | 17 | Positioning **3**; Tackling **3**; Anticipation **2**; Decisions **2**; Passing **2**; Teamwork **2**; Stamina **2**; Strength **1** |
| LM | 16 | Crossing **3**; Dribbling **3**; Pace **2**; Acceleration **2**; Passing **2**; Work Rate **2**; Stamina **2** |
| RM | 16 | Crossing **3**; Dribbling **3**; Pace **2**; Acceleration **2**; Passing **2**; Work Rate **2**; Stamina **2** |
| CM | 18 | Passing **3**; Vision **3**; Decisions **3**; Teamwork **2**; Stamina **2**; Work Rate **2**; Technique **2**; Anticipation **1** |
| LW | 17 | Dribbling **3**; Crossing **3**; Pace **3**; Acceleration **2**; Movement **2**; Finishing **2**; Technique **2** |
| RW | 17 | Dribbling **3**; Crossing **3**; Pace **3**; Acceleration **2**; Movement **2**; Finishing **2**; Technique **2** |
| AMC | 17 | Vision **3**; Passing **3**; Dribbling **3**; Movement **3**; Decisions **2**; Technique **2**; Finishing **1** |
| ST | 19 | Finishing **4**; Movement **4**; Anticipation **2**; Acceleration **2**; Pace **2**; Heading **2**; Strength **1**; Consistency **2** |

Right-sided RB/RWB/RM/RW reuse LB/LWB/LM/LW weights respectively; their side familiarity is right-sided. Sweeper uses its own recipe. DMC and AMC use distinct weights. Central and wide variants in the detailed position screen use the appropriate stored role and side, with the position-family recipe above.

## Attribute conversion

CM Lab consistently uses its existing CMScout-style 1–20 conversion. These are model/display values, **not independently verified in-match values for every patch**. For non-CA-dependent attributes, the stored value is clamped to 1–20. For CA-dependent attributes:

```js
isGoalkeeper = storedGoalkeeperFamiliarity >= 15;
alwaysHigh = [Anticipation, Decisions, Heading, LongShots,
              Passing, Penalties, Positioning, Tackling];
keeping = [Handling, Reflexes, OneOnOnes];
high = alwaysHigh.includes(attribute)
    || (keeping.includes(attribute) ? isGoalkeeper : !isGoalkeeper);
temp = rawSignedAttribute / 10 + CA / (high ? 20 : 200) + 10;
converted = trunc(clamp(temp * temp / 30 + temp / 3 + 0.5, 1, 20));
```

CA-dependent fields: Anticipation, Crossing, Decisions, Dribbling, Finishing, Handling, Heading, LongShots, Marking, Movement, OneOnOnes, Passing, Penalties, Positioning, Reflexes, Tackling, ThrowIns, Vision. Other inputs in the position recipes use their stored values, clamped to 1–20.

## Position familiarity map

These are the detailed profile positions. Wing-back variants use the LWB/RWB recipe; wide DM variants use DMC. Pitch-cell logic also allows wing-back familiarity for the outer DM line, as shown by the tactic editor.

| Position | Stored role | Stored side | Recipe |
| --- | --- | --- | --- |
| GK | Goalkeeper | None | GK |
| DL | Defender | Left | LB |
| DR | Defender | Right | RB |
| DC | Defender | Centre | CB |
| SWL | Sweeper | Left | SW |
| SWR | Sweeper | Right | SW |
| SWC | Sweeper | Centre | SW |
| WBL | Wing-back | Left | LWB |
| WBR | Wing-back | Right | RWB |
| WBC | Wing-back | Centre | LWB |
| DML | Defensive midfielder | Left | DMC |
| DMR | Defensive midfielder | Right | DMC |
| DMC | Defensive midfielder | Centre | DMC |
| ML | Midfielder | Left | LM |
| MR | Midfielder | Right | RM |
| MC | Midfielder | Centre | CM |
| AML | Attacking midfielder | Left | LW |
| AMR | Attacking midfielder | Right | RW |
| AMC | Attacking midfielder | Centre | AMC |
| FL | Forward | Left | ST |
| FR | Forward | Right | ST |
| FC | Forward | Centre | ST |

## Scope and feedback

LabLogic is not TonTon's TT2 Monster score, Find the next style similarity, a growth forecast or a guarantee of match performance. Those features have separate purposes. Individual roles, instructions, tactics, opponents, condition and hidden engine behaviour can affect results. This file documents the implemented weights; suggestions and alternative sets are welcome through [GitHub Issues](https://github.com/mike-appguy/CMLab/issues). Please distinguish personal experience, controlled testing and proposed modelling assumptions when sharing evidence.

## Player Search and profiles (3.3)

Player profiles and the squad table show the highest known natural-position
LabLogic. The profile also names that position. Player Search has one canonical
LabLogic column beside CA/PA: the main pitch-position filter takes priority,
then an explicit advanced rating-role override, otherwise best natural position.
Its heading states the scoring basis. The same score is used for its numeric
sorting and active rating limits. Optional position-specific columns are opt-in
in the column catalogue; they do not replace the canonical search score.
