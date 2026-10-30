# Find the next…

Select a reference player and a natural position. From that position's LabLogic recipe, take six known reference attributes, ordered by reference value descending, then recipe weight descending, then attribute key. These are the comparison strengths.

Let r_i and c_i be reference/candidate converted values, w_i their position weights, R=max(r), C=max(c), W=sum(w):

```text
Style match = 100 × (1 − sum(w_i × abs(c_i/C − r_i/R)) / W)
Strength match = 100 × sum(w_i × min(1,c_i/r_i)) / W
Headroom = PA − CA
```

Example: a candidate with exactly 80% of every reference strength has 100 style match but 80 strength match. This describes current resemblance, not projected growth.

Candidates must have lower CA than the reference, known non-negative PA, sufficient headroom, age within the selected limit and natural role/side familiarity >=15. The UI initially chooses age 23, headroom 20 and a reference-relative PA threshold (clamped 100–160); blank computation fallbacks are age 23, PA 140 and headroom 20. Optional fees/wages are independent filters.

Unearthed mode derives limits from the managed squad's upper median: CA +10 capped at 140; current reputation +500 capped at 5000; world reputation +500 capped at 4000. Missing squad medians use 130/4000/3000 respectively; missing candidate reputation fails an active limit. All prospects removes those discovery caps. LabLogic and PA/headroom are displayed separately. One save cannot establish a growth trend.
