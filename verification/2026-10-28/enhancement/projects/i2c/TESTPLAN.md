# I2C verification testplan

Scope: paired master/slave, 7-bit address0x12, one data byte per START/STOP request, native 100 kHz SCL with100 MHz system clock. Open-drain SDA pullup modeled by RTL. No clock-stretching, arbitration, repeated-start, multi-byte, or full electrical/bus-compliance claim. Final controller-receiver byte is NACK, then STOP. ACK=0 requests continuation, which this single-byte test does not support.

| Objective | Stimulus | Expected/checker | Coverage / bounds |
|---|---|---|---|
| Write/read integrity | Directed special bytes and constrained-random requests | Independent request fields captured before START; decode raw SDA at SCL rising; compare wire address/data/ACK and endpoint data | Original i2c_cg unchanged; enhanced address/direction cross |
| Wrong address/boundaries |0,0x7f,0x11,0x13 versus target0x12 | NACK on ninth address clock, no slave data/done side effect; prior slave receive value stable | Extended five address bins×directions; request dist8:1:1:1:1 |
| Wire protocol/response | START, address8+ACK, data8+ACK, STOP | Detect actual SDA START/STOP, exact19 SCL rises including STOP setup, no X/Z; top ACK status equals decoded SDA |12,000-cycle per-command timeout, issued/completed equality |
| Reset/recovery | Abort address byte then4 requests | Release SDA/SCL, no busy, next transaction checked independently | Aborted request separate from completed |
| Checker sensitivity | NEGATIVE flips sampled data in monitor after decode | Expected checker error; excluded from normal regression and coverage | Explicit deliberate checker unit self-test |

PASS: independent data and ACK matches; no monitored side effects/missing/duplicate events, no unknown pins, queues drained, unexpected UVM_ERROR/FATAL0, no timeout. Pin assertions are **procedural checks**. The legacy `soft slave_addr==0x12` constraint is explicitly disabled before applying weighted address constraints; otherwise every random item remains target-only. Final-source build `distributed`; target-only earlier `verified` runs are superseded stimulus diagnostics and must not be pooled. The `enhanced_cg.ack=0` bin is retained unhit, accurately reflecting unsupported continuation. Compile→smoke12→directed24→100 random→1000→10×1000→reset→negative.2 s simulation global timeout and240 s host cap/run.

Specification reference: [NXP UM10204 I2C bus manual](https://community.nxp.com/pwmxy87654/attachments/pwmxy87654/nxp-designs/931/1/UM10204.pdf). Final NACK and STOP are used to end a controller-receiver transfer. Only this DUT's implemented subset is claimed.

Focused QA scope clarification: see QA_REVIEW.md for the exact busy/consecutive/reset/timing stimulus and remaining unverified checks. Normal PASS certifies monitored intervals; no global idle unexpected-output detector or full electrical compliance is claimed.
