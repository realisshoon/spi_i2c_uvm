# Focused protocol QA review

Reviewed actual source, final normal raw simulation logs, build manifests and native report inputs. No new simulations or source changes were made for this review.

- **15 final normal runs**: exactly one RESULT per raw log; issued/completed, check/pass/fail, procedural attempts/failures and aborted counters match results.json; UVM_ERROR/FATAL summaries0 and no individual error/fatal lines.
- Large campaign remains10 seeds101..110×1000. Trials from superseded builds, expected negative self-tests and boundary failures excluded. Test/transaction/check/seed remain distinct.
- Raw hashes match recorded final build manifests. Final mixed-address distributed build is distinct from prior target-only trials.
- Millions of pin attempts are repeated clock-cycle procedural checks, **not SVA attempts, unique properties, independent testcases or transactions**. No SVA execution claim.

| Claim / requested feature | Exact supported evidence / limitation |
|---|---|
| Busy START | No busy command injection in the final I2C campaign; not claimed verified. |
| Consecutive requests | Repeated START-address-data-STOP requests with explicit5-clock command waits and12-clock post-STOP gap. Zero-gap/minimum-bus-free-time stress is **unverified**. |
| Reset | One external abort during address transfer, bus release/master_busy checked, followed by4 checked recovery requests. Reset during payload/ACK/STOP/read stall and a global idle late-done suppression checker are **unverified**. |
| Timing | Raw START/STOP detection, SCL rising-edge address/data/ACK decode,19 rising edges including STOP setup, active SDA/SCL unknown rejection, top ACK status and wrong-address side effects checked. No dedicated tLOW/tHIGH/tSU/tHD measurement checker, rate sweep or analog/electrical compliance. Native100kHz is the RTL parameter setting, not an independently swept timing certificate. |
| ACK/NACK scope | Address/data ACK and wrong-address NACK checked; final controller-read NACK checked. ACK=0 continuation remains unhit/not verified; repeated-start/multi-byte/stretch/arbitration not claimed. |
| Wrong-address checking | Checks decoded address NACK, no slave RX/TX done, unchanged prior slave_rx_data. Released-bus FF readback is not separately compared for wrong addresses. |
| Reference independence | Expected request fields are captured before START from non-DUT interface reference fields written by the driver; monitor decodes independent SDA/SCL values, scoreboard compares endpoints and wire data. Not a Python golden model. |
| Unknown/timeout/checker sensitivity | Active-pin X/Z rejection and bounded command/response timeouts are implemented; no unexpected unknowns/timeouts occurred. Decoder one-bit corruption was an explicitly labeled checker self-test. Dedicated X/Z-injection and timeout-injection sensitivity tests were not run. |
| Completion accounting | One serial in-flight request; no pending TLM queue exists. Issued/completed equality and endpoint event counts validate drain inside monitored intervals; do not describe this as a general global unexpected-output detector. |

Metrics correction: no numerical changes required. Legacy25/25=100%; extended18/19=94.74% raw bin ratio, continuation ACK unhit. Newly reproduced baseline12 unknown-ACK errors/85.71% does not prove historical12/0 or14/0.
