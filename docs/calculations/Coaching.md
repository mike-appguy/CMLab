# Coaching assignments

Inputs: eligible assistant/coaching staff decoded from employment roles and club training-roster references; converted outfield and goalkeeping coaching attributes. Unknown eligibility is excluded. See the scoring assumptions, not a claim of engine certification.

Each selected coach contributes their outfield rating to Fitness, Tactics, Shooting and Skills, and their goalkeeping rating to Goalkeeping. Each area targets 50. The optimiser jointly searches minimal covering subsets, or all known contributions when the target is unattainable. The soft preference is normally three areas per coach; exceeding it is allowed.

The lexicographic objective is, in order:
1. Maximise areas reaching 50.
2. Minimise total shortfall below 50.
3. Minimise coaches exceeding the soft workload preference.
4. Minimise total excess above 50.
5. Minimise total assignments.

Example (arithmetic only): contributions 18 + 17 + 15 reach 50 exactly; 18 + 17 + 14 leave one point short. The joint assignment can differ from independently choosing each column, because a coach's workload couples the columns.

The four outfield columns are symmetric in this model; the search avoids equivalent permutations. This is a community-based planning assumption, not a decoded training-engine formula. Manual assignments and Auto Optimise affect the companion plan only.
