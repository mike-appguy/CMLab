# Transfer / Move On (experimental planning model)

Only current managed-club players are assessed. For each natural pitch position, calculate LabLogic for the player and all other natural squad options. Take the three highest peer scores; require at least two. Standard = their median. Gap = standard − player score. Use the player's smallest comparable gap, protecting useful alternate positions. This is a role benchmark, not a global squad average.

Default review threshold is 10 LabLogic points (editable). Below that: Within squad standard. At or above it, inspect known non-negative PA−CA and age:

| Age | Headroom weight |
| --- | ---: |
| <=20 | 1.0 |
| 21–23 | 0.8 |
| 24–26 | 0.5 |
| 27–29 | 0.25 |
| >=30 | 0.1 |

Age-weighted headroom = (PA−CA) × weight. This is an explicit, heuristic planning indicator in CA points, not projected development, future LabLogic or an estimated probability. It must not be compared numerically to the LabLogic gap as though they have the same units.

If indicator >=20: protect development potential. If raw headroom >=20 but indicator <20: age-risk review. Otherwise indicator <10 gives little-headroom Move On review; 10–20 gives limited-headroom review. Unknown age/PA leaves growth-dependent review unassessed. Inadequate positional peers also leaves the player unassessed.

Arithmetic examples with a 20-point positional LabLogic gap: CA120/PA125 at18 has 5 weighted points and is flagged; CA120/PA175 at18 has55 and is protected; the latter at30 has5.5 and receives an age-risk review. None predicts the player's eventual ability.

Thin-cover warnings are retained even if another comparable role is weak. Loan reviews refer to retention/parent terms, not selling a player the managed club does not own. Recommendations never execute game actions. No existing training, shortlist or career records are changed by viewing this page.
