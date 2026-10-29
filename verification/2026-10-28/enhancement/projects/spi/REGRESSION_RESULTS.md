# Current-source verification

| Build | Phase | Seed | Issued/completed | Checks PASS/FAIL | UVM E/F | Pin checks/fail | Result |
|---|---|---:|---|---|---|---|---|
|closed|smoke|55|4/4|8/0|0/0|6960/0|PASS|
|closed|directed|10|81/81|162/0|0/0|139332/0|PASS|
|closed|small_random|11|100/100|200/0|0/0|174000/0|PASS|
|closed|intermediate|12|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|101|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|102|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|103|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|104|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|105|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|106|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|107|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|108|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|109|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|large_random|110|1000/1000|2000/0|0/0|1740000/0|PASS|
|closed|reset|22|4/4|8/0|0/0|7007/0|PASS|
|closed|negative|33|1/1|1/1|1/0|132/0|FAIL (diagnostic/self-test)|
|closed|boundary|44|4/4|5/3|3/0|288/0|FAIL (diagnostic/self-test)|
|resetload|reset_load|66|4/4|8/0|0/0|6960/0|PASS|

Earlier runs retained in results.json with superseded=true. Never pool old and current-source runs. Every run has metadata.json, original log and DB. Source snapshots/manifests under build/closed.
