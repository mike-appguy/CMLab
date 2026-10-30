# Recruitment comparisons and opportunities

Replacements compare a chosen squad player at a specified position. Current quality is position-specific LabLogic; CA difference and LabLogic difference are target minus benchmark. The comparison does not model willingness to sign.

Comparable defaults: world reputation within ±1500 of the benchmark (clamped 0–10000), current reputation <= benchmark +1500, CA <= benchmark +20 (capped 200). Wider mode uses ±3000/current +3000 and CA +40. Lower mode sets the world minimum to zero. Any level disables these caps. When a benchmark metric is unknown, its corresponding cap is unavailable; candidate unknowns fail active caps.

Example: benchmark world 4000, current 5000, CA 120 gives world 2500–5500, current <=6500 and CA <=140 in comparable mode. These are discovery bounds, not an affordability or transfer-likelihood score.

Costs use zero for a free agent, a recorded minimum release fee where active, otherwise recorded value. Neither is a guaranteed negotiated asking price. Optional budget, wage, age, CA, higher-CA and higher-LabLogic controls combine with these constraints.

Opportunity categories use decoded contracts/listing/clause signals, excluding own players and owned loanees by default. Parent contracts are distinct from loan expiry. A player being on loan does not itself mean they are available for loan. Unknown prices or PA do not satisfy active limits. The War Room stores user intent, not evidence of transfer availability.
