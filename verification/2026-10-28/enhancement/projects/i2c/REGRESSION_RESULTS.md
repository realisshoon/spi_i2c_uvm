# Current-source verification

| Build | Phase | Seed | Issued/completed | Checks PASS/FAIL | UVM E/F | Pin checks/fail | Result |
|---|---|---:|---|---|---|---|---|
|distributed|smoke|4|None/None|None/None|None/None|0/0|FAIL|
|distributed|smoke|5|12/12|30/0|0/0|231063/0|PASS|
|distributed|directed|10|24/24|48/0|0/0|462132/0|PASS|
|distributed|small_random|11|100/100|224/0|0/0|1925538/0|PASS|
|distributed|intermediate|12|1000/1000|2350/0|0/0|19255325/0|PASS|
|distributed|large_random|101|1000/1000|2324/0|0/0|19255338/0|PASS|
|distributed|large_random|102|1000/1000|2326/0|0/0|19255337/0|PASS|
|distributed|large_random|103|1000/1000|2412/0|0/0|19255294/0|PASS|
|distributed|large_random|104|1000/1000|2336/0|0/0|19255332/0|PASS|
|distributed|large_random|105|1000/1000|2366/0|0/0|19255317/0|PASS|
|distributed|large_random|106|1000/1000|2348/0|0/0|19255326/0|PASS|
|distributed|large_random|107|1000/1000|2308/0|0/0|19255346/0|PASS|
|distributed|large_random|108|1000/1000|2304/0|0/0|19255348/0|PASS|
|distributed|large_random|109|1000/1000|2350/0|0/0|19255325/0|PASS|
|distributed|large_random|110|1000/1000|2304/0|0/0|19255348/0|PASS|
|distributed|reset|22|4/4|8/0|0/0|80329/0|PASS|
|distributed|negative|33|1/1|2/1|1/0|19255/0|FAIL (diagnostic/self-test)|

Earlier runs retained in results.json with superseded=true. Never pool old and current-source runs. Every run has metadata.json, original log and DB. Source snapshots/manifests under build/distributed.
