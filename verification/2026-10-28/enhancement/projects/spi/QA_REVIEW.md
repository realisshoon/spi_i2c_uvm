# Focused protocol QA review

Reviewed actual source, final normal raw simulation logs, build manifests and native report inputs. No new simulations or source changes were made for this review.

- **16 final normal runs**: exactly one RESULT per raw log; issued/completed, check/pass/fail, procedural attempts/failures and aborted counters match results.json; UVM_ERROR/FATAL summaries0 and no individual error/fatal lines.
- Large campaign remains10 seeds101..110×1000. Trials from superseded builds, expected negative self-tests and boundary failures excluded. Test/transaction/check/seed remain distinct.
- Raw hashes match recorded final build manifests. Closed/resetload RTL hashes are identical; resetload changes only optional reset selection in TB driver.
- Millions of pin attempts are repeated clock-cycle procedural checks, **not SVA attempts, unique properties, independent testcases or transactions**. No SVA execution claim.

| Claim / requested feature | Exact supported evidence / limitation |
|---|---|
| Busy START | Actual one-system-clock START pulse on every7th item, ten cycles after initial START; divider4/5/20/255 transfers are still busy then. Same data, exactly8 sampled bits and exactly1 done/endpoint checked. This tests ignored extra START; it does not test changed TX/divider while busy. |
| Consecutive requests | Sequencer runs repeated transfers with explicit12-system-clock post-completion drain. Zero-gap/maximum-throughput request acceptance is **unverified**. |
| Reset | One external abort during DATA and one immediately after accepted START/LOAD; reset CS/SCLK/master_busy checked, then4 complete recovery transfers each. Other bit positions/STOP reset, dedicated late-completion suppression while idle, and independent slave-busy reset assertion are **unverified**. |
| Timing | Actual edge intervals, final high pulse width, MOSI stability during high, CPOL0 return,8 edges and active-pin X/Z are checked procedurally. MISO high-phase stability, sub-system-clock setup/hold, CS inactive minimum time, external asynchronous device timing and electrical compliance are **unverified**. |
| Walking patterns | Directed master walking1 and complementary slave walking0; random campaign hits all16 master walking bins. Not a dedicated exhaustive walking1/0×divider×both-direction cross. |
| Remaining divider defect | div0..3 boundary diagnostic has3 failures/8 data checks. It is retained as an **open real failing diagnostic**, even though marked expected_failure to prevent pooling into normal PASS. No supported-range100% claim beyond4/5/20/255. |
| Unknown/timeout/checker sensitivity | Active-pin X/Z rejection and bounded command/response timeouts are implemented; no unexpected unknowns/timeouts occurred. Decoder one-bit corruption was an explicitly labeled checker self-test. Dedicated X/Z-injection and timeout-injection sensitivity tests were not run. |
| Completion accounting | One serial in-flight request; no pending TLM queue exists. Issued/completed equality and endpoint event counts validate drain inside monitored intervals; do not describe this as a general global unexpected-output detector. |

Metrics correction: no numerical changes required. Legacy weighted get_inst_coverage80.00% is comparable to historical59.59%; native raw65/67=97.01% is separate. Extended20/20; final FSM6/6.
