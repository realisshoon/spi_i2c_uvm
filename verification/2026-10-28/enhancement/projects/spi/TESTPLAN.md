# SPI verification testplan

Scope: paired master/slave RTL, fixed Mode 0, 8-bit full duplex. CPOL/CPHA inputs of master are unused by RTL; no Mode 1/2/3 claim. System clock 100 MHz. Divider half-period is divider+1 system clocks. This is a design timing contract, not a universal SPI duty-cycle specification.

| Objective | Stimulus | Expected/checker | Coverage / bounds |
|---|---|---|---|
| Full-duplex integrity | 49 pattern-category pairs, walking1/0, randomized bytes | Independent request bytes versus raw MOSI/MISO decode and both received bytes | Legacy spi_cg unchanged, exact eight rising edges, two data checks/transfer |
| Divider/timing | div4/5/20/255 | Every active edge and final high width divider+1; MOSI stable on high; CPOL0 on finish | enhanced_cg divider4 bins; 12,000-cycle driver timeout |
| Busy start | Extra START pulse while active every7th item | No extra CS interval/done; same input data | Completed count equals issued count, exactly one done per endpoint |
| Reset recovery | Abort in-flight transfer then four requests | CS inactive, SCLK low, busy0 under reset; aborted separate from completed | Reset log/VCD; bounded response |
| High-speed boundary diagnosis | div0/1/2/3 | Independent pin+received checker detects synchronized-slave limitation | Diagnostic FAILURE kept separate; never merged into normal coverage |
| Checker sensitivity | Explicit NEGATIVE opt-in flips decoded MOSI after simulation sampling | One scoreboard mismatch expected | Deliberate checker unit self-test, not a discovered DUT bug |

PASS: all request/observed/completed counts equal; no unknown active pins, mismatches, duplicate/missing done, unexpected UVM_ERROR/FATAL, timeout. Pin assertions are counted **procedural checks**, not SVA attempts. Simulation timeout 2 s; host limit 240 s/run. Random data has unconstrained uniform 8-bit distributions; divider selection is deterministic round robin. Compile→smoke→81 directed→100 random→1000→10×1000→reset→self-test. Final normal runs use build `closed`; earlier `verified` results exclude the final-pulse check/fix and must not be pooled as final-source results.

External reference: [Analog Devices SPI Mode 0 overview](https://www.analog.com/en/resources/analog-dialogue/articles/introduction-to-spi-interface.html). Actual supported scope is constrained by this RTL.

Targeted closure: separate `resetload` driver build adds only an optional external reset immediately after START; same DUT SHA hashes as `closed`. Four recovery transfers/eight checks PASS, and normal-only URG `coverage/closed_final` FSM6/6. This supplements the existing10k campaign without repeating large random.

Focused QA scope clarification: see QA_REVIEW.md for the exact busy/consecutive/reset/timing stimulus and remaining unverified checks. Normal PASS certifies monitored intervals; no global idle unexpected-output detector or full electrical compliance is claimed.
