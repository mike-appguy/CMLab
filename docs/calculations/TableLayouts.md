# Table layouts

Columns are presentation preferences, not scouting/player calculations. Squad Best LabLogic is the highest known natural role/side score (both >=15), as on the profile. Sorting uses unrounded scores.

Single-header-row tables expose Columns controls, native header dragging and resize grips. Preferences are stored per stable table key under cmlab-table-layout-v1 and included in complete workspace backups. Dynamic attributes use stable column identities. Rows and headers are reordered together after render; hidden columns are preserved for later reappearance. Reset restores default order, visibility and widths for that table only. It never clears career, training or scouting records.

Resize limits are 56–800px; keyboard-focus a grip and use Left/Right for 10px steps. A Columns menu provides keyboard-accessible visibility and reorder controls. At least one current column remains visible. Unknown/corrupt records and stale writes are protected. Complex multi-row/grouped headers are left unchanged rather than guessing their alignment.

RC3 replaces the inline menu with a searchable Apply/Cancel popup. Player lists
can add all fifty converted attributes and available player/contract/loan/rep
fields, as well as per-position LabLogic. Missing data is shown as —. Column
choices are saved as optional `extra` keys in the same version1 preference
record, preserving previous layouts. Added sorting routes through each player
list's source sorting before pagination, with unknown values last. Spare width
is distributed proportionally across visible columns; larger layouts scroll.
Non-player tables retain only their own applicable columns.

Nationality is the canonical saved nation code in built-in and added columns,
with the full saved name on hover. Nationality — full name is a separate
explicit display field. Missing codes stay unknown; no codes are invented.
Nationality filters/eligibility still use the full source identity, not display text.
