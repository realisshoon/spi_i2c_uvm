# SPI actual troubleshooting

| Issue | Observation | Confirmed root cause | Fix | Verification / Evidence |
|---|---|---|---|---|
| Truncated terminal SCLK high (newly reproduced real RTL bug) | Same seed55/div4/5/20/255: all8 data checks PASS but4 terminal-high assertions FAIL; div4 last high10ns, regular high50ns | Master transitions DATA→STOP on eighth rising edge. STOP unconditionally drives SCLK low/CS high on next system clock; divider only ran in DATA | Working-copy master divider also runs in STOP; defer terminal falling/CS release until half_tick. Fixed Mode0 specification unchanged | `runs/pulse_before_failure_s55_n4` vs `runs/closed_smoke_s55_n4`, VCD+CSV before/after.0 errors after; final10×1000 data+timing pass. `rtl/spi_master.sv`, `source_diff.patch` |
| Timing monitor inclusive-cycle error (new TB issue) |4 early assertions on first clock edge, while all data checks passed | Monitor counted CS assertion cycle as elapsed halfperiod (off by one) | Initialize edge counter before interval rather than count start cycle | `runs/final_smoke_s2_n4` retained; `runs/verified_smoke_s3_n4` 0 errors |
| Fast-divider synchronized-slave limit (OPEN) | div0..3 boundary diagnostic has3 end-to-end data failures out of8 checks | Slave MISO/CS/SCLK traversal uses multi-stage synchronization. Fast edge spacing insufficient for intended sampling latency; data mismatch confirmed, complete per-divider root-cause closure still open | No arbitrary divider remap or checker relaxation. Supported passing regression uses4/5/20/255; limit documented | `runs/closed_boundary_s44_n4/{sim.log,trace.vcd}`. This is a real failing diagnostic, not a PASS |
| FSM LOAD-reset hole | Original merged FSM5/6; missing LOAD→IDLE | Earlier reset abort only exercised DATA→IDLE | Added external reset immediately after accepted START, before CS assertion; no DUT force | `runs/resetload_reset_load_s66_n4` four recovery transfers/eight checks PASS; native merged FSM6/6 in `coverage/closed_final/report/modinfo.txt`. DUT RTL identical to closed10k build; separate TB build hash preserved |

Portfolio (this enhancement session, tool-assisted work; historical ownership separate):

문제: 기존 Full-Duplex data PASS와 별개로 마지막 SCLK high가 divider 설정보다 짧았습니다.
원인: STOP 상태가 divider half_tick을 기다리지 않고 다음 시스템 클럭에 종료했습니다.
해결: 작업본에서 STOP 구간까지 divider를 유지하고 마지막 high 주기를 완료한 뒤 CS를 해제했습니다.
검증: 같은 seed55의 실패/수정 파형10ns→50ns, 최종10 seeds·10,000 transfers·20,000 data checks와 timing0 errors로 확인했습니다.

Deliberate `negative` monitor corruption is only checker sensitivity self-test; it is not presented as a discovered bug or personal troubleshooting achievement. Procedural pin check counts are not SVA attempts.
