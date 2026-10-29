# SPI isolated verification enhancement

Original sources under baseline_source are preserved byte-for-byte from the original project. All modifications/runs are confined here. Source snapshots and SHA256 manifests are saved per final build; compile logs preserve actual VCS/UVM versions. Test,seed,transaction,check counts are distinct.

Reproduce with /usr/bin/python3.11 run.py compile NEW_TAG, then /usr/bin/python3.11 run.py NEW_TAG smoke NEW_SEED N, then suite NEW_TAG only after smoke PASS. Use a fresh tag/seed/phase/count combination; existing run directories are never reused. Every EDA operation goes through the global two-slot resource_gate.py. VCS license connectivity requires the educational server environment. The script has bounded simulation/per-command/host timeouts.

Current campaign: build closed, seeds101..110×1000. The resetload build changes only an optional reset phase selector in the driver, with identical RTL; its external LOAD reset case is separately logged and merged for DUT coverage.

See TESTPLAN.md, TROUBLESHOOTING.md, REGRESSION_RESULTS.md, results.json, source_diff.patch. Native reports and input run list under coverage/closed_final. Legacy covergroup bodies are byte-identical; original fail bins retained. All assertion counts here are procedural pin checks, not SVA attempts. Scope and remaining holes are explicit in results.json.

Historical portfolio data and newly reproduced baseline failures are separate. Checker self-test failures are deliberate only to demonstrate checker sensitivity and never merged into normal PASS totals or coverage.
