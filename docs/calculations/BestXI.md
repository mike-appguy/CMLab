# Best XI and national selection

Inputs: the chosen pitch cells, natural role/side suitability and position-specific [LabLogic](LabLogic.md). The pitch offers five lanes on six outfield lines (F, AM, M, DM, D, SW) plus GK, with at most ten outfield slots.

The optimiser uses exact dynamic programming over occupied-position masks. Each player is considered once; placing a natural player in a slot adds 2000 + that slot's LabLogic score. Since a score is at most 100 and there are at most eleven slots, this first maximises filled positions, then total LabLogic. No player appears twice. Unknown scores do not qualify. Name/staff/player order supplies deterministic tie handling. Unfilled slots remain visible.

Example (arithmetic only): if player A scores 90 at CB and 89 at DMC, while B scores 88 at CB and cannot play DMC, the joint solution uses B at CB and A at DMC (177), rather than stranding DMC after greedily placing A at CB.

For national teams, the same exact solver uses the top N candidates per slot for N slots: at most N−1 can be occupied elsewhere, so this pruning preserves the optimum. Seven substitutes are chosen separately from players outside the XI: GK, two defenders, two midfielders and two attackers, scored at their best natural role within that category. This is a planning convention, not a decoded tournament rule. Senior/U21/U19 previews are independent; youth limits are age <21 and <19 on the save date.

National eligibility conservatively excludes players capped for another primary nation from second-nationality pools. Uncapped dual nationals remain provisional; retirement, youth ties, patch rules and availability are not fully decoded. See [Nation and regens](NationAndRegens.md).

Presets apply immediately. Custom allows position editing; Save & apply closes the editor. Club manual player assignments are preserved unless the user explicitly selects a different shape or recommended XI. Companion plans never edit game tactics.
