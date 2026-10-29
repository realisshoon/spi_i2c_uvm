# I2C actual troubleshooting

| Issue | Observation | Confirmed root cause | Fix | Verification / Evidence |
|---|---|---|---|---|
| ACK wrapper/source mismatch (audit known issue, newly reproduced and fixed) | New baseline run produced12 UVM_ERROR `Slave ACK/NACK is unknown`, legacy FC85.71%; wrong-address results missing despite old historical14/0 claim | Wrapper connected master ACK ports to undeclared internal names, leaving top output unconnected; current command monitor never called SDA helper and waited for slave_rx_done even when wrong-address slave correctly did nothing | Working copy connects `.ack_in(ack_in),.ack_out(ack_out)`; replace command-only monitor with START/STOP/SDA rising-edge decoder, explicit expected request snapshot and bounded completion/drain | `baseline_source/rtl/i2c_master_slave_top.sv`, `runs/baseline_failure_s1_n14/sim.log`, final mixed `runs/distributed_*`; corrected native100kHz10×1000 has zero errors. Historical14/0/100 remains separate from this newly reproduced baseline |
| Invalid read termination (new TB stimulus issue) | Seed2 caused missing STOP/completed count and read mismatch | TB requested master ACK=0 on final byte then STOP. RTL interprets ACK as another-byte continuation; next slave bit can keep SDA low. Single-byte receiver must NACK its final byte | Final-byte NACK=1. Retain unhit ACK-continuation coverage bin and unsupported feature annotation | `runs/final_smoke_s2_n4` VCD/log versus `runs/verified_smoke_s3_n4` and final mixed campaign. No unsupported multi-byte PASS claim |
| Weighted address randomization silently target-only (new stimulus issue) | Early verified1000 requests always3000 checks and only target address; extended low/high/below/above holes persisted | Inherited `soft slave_addr==0x12` remains satisfiable with inline dist including target, overriding intended distribution | Disable the original soft address constraint before the weighted target/boundary distribution | Final distributed normal coverage bin counts target7449, low952, high959, below932, above848 (sum11140). Native `coverage/distributed/report/grpinfo.txt`; all ten seeds mixed |
| Simulation launched before build available (infrastructure issue) | No simulator results, FileNotFoundError for distributed binary | Run queued independently and reached a slot before compile finished | Wait for compile completion and verify executable before simulation | `runs/distributed_smoke_s4_n12/sim.log` preserved as infrastructure failure; actual rerun seed5 completed12/checks30, all PASS. Never counted as DUT result |

Portfolio (new isolated-copy enhancement; not an attribution of historical/team work):

문제: 과거14/0과 달리 현재 소스 재실행에서 ACK unknown12건과 wrong-address 결과 누락을 확인했습니다.
원인: wrapper ACK 포트가 undeclared 신호에 연결됐고, command monitor는 wrong-address에서 발생하지 않는 slave done을 기다렸습니다.
해결: 최소 ACK 배선 수정, 실제 SDA/SCL pin decoder·독립 expected data·bounded timeout·drain 검사를 구현했습니다.
검증: native100kHz10 seeds·10,000 mixed target/wrong-address transactions·23,378 checks,0 errors 및 원본 로그/VCD/URG report로 확인했습니다.

I2C scope remains single data byte with final NACK. `negative` decoder corruption only validates checker sensitivity and is not a discovered issue. Full electrical compliance, arbitration/stretching/repeated-start/continuation are unverified. All pin assertions are procedural checks.
