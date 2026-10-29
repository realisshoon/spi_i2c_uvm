# UVM 후속 검증 보존 — 2026-10-28

교육 당시 원본 코드는 기존 repository 경로와 main 커밋에 그대로 보존한다. 이 폴더만 추가하며 기존 파일은 수정하지 않는다. 후속 코드·2026-10-19 실행 결과는 **Codex 지원 후속 검증**이다. 2026-10-28 작업은 보존 로그 재집계·패키징이며 새로운 시뮬레이션 PASS가 아니다.

## 읽는 순서

- `audit/canonical_runs.csv`: 이 저장소의 최종 정상 실행만. Test class / Seed / issued / completed / checks / PASS·FAIL / 단위를 구분한다.
- `audit/canonical_runs.json`: 실행 명령·시각·원래 경로·coverage DB 기록 및 저장소 내부 로그/소스 snapshot 연결.
- `evidence/<project>/runs/`: 개발 중 실행·실패·diagnostic도 포함한 원본 로그와 metadata. `run_classification.json`의 `in_final_normal_101`만 최종 정상 집계다. 기록된 PASS라도 superseded trial을 최종 결과에 더하지 않는다.
- `evidence/<project>/coverage/`: native URG의 TXT report와 merge 근거. VDB·시뮬레이터 binary·파형·EDA 생성 코드·브라우저 프로필·license/auth 파일은 제외했다. 이 파일만으로 URG를 재merge할 수 있다는 뜻은 아니다.
- `enhancement/projects/`: 원본 baseline 사본, 최종 RTL/TB, Test Sequence, 보존 regression script, testplan, 원래 results·문서. 원래 문서의 절대경로는 당시 환경 기록이다.
- `evidence/<project>/builds/`: 정상 실행 당시 source snapshots, compile log, 기존 source hash manifest.
- `audit/source_build_checks.json`: 당시 snapshot의 해시와 현재 작업본의 비교.
- `source_diffs/`, `audit/baseline_to_followup_changes.json`: 보존 baseline→후속 코드 차이와 SHA-256.
- `audit/main_baseline_comparison.json`: 로컬 baseline과 GitHub main의 byte 비교. 불일치는 숨기지 않으며 교육 당시 성공 로그가 현 소스에서 생성됐다는 주장으로 바꾸지 않는다.
- `audit/original_20261028/`: 제공받은 10/28 검수 HTML·CSV·JSON·script를 byte 그대로 보존. HTML의 원래 상대 링크는 옛 workspace 기준으로, 이 저장소의 탐색 링크가 아니다. 내부 탐색은 이 README와 canonical_runs를 사용한다. 원본 audit.py는 당시 로컬 경로가 필요한 기록용이다.
- `audit/provenance_101.json`: 전체 101개 검수 행의 원래 경로·해시·결과·현재 보존 위치. 이 저장소 외 대상은 metadata only 또는 다른 지정 저장소로 명시한다. VGA/CNN 코드·raw logs는 포함하지 않았고 해당 저장소도 수정하지 않는다.
- `SHA256SUMS`: 이 아카이브의 파일 무결성. `python3 verify_archive.py`는 해시·로그·계수만 검토하며 시뮬레이터를 실행하지 않는다.

## 집계와 Coverage 해석

SPI: 최종 정상 16회/16 seeds, 11,193 transfers, 22,386 comparisons PASS. 대표 10 seeds 101–110은 10,000 transfers/20,000 checks로 전체의 부분집합이다. I2C: 15회/15 seeds, 11,140 transactions, 26,038 checks PASS; 대표 10 seeds 101–110은 10,000 transactions/23,378 checks다.

SPI FC: legacy weighted 80.00%, raw 65/67, enhanced 20/20. DUT Line/Condition/Branch/FSM 100%, Toggle 97.98%. I2C FC: legacy 25/25, enhanced 18/19(94.74%). DUT Line/Condition/Branch/FSM/Toggle = 97.98/97.62/90.91/58.14/97.12%. Coverage는 최종 정상 merge이며 대표 10 seeds만의 report가 아니다.

SPI는 패턴·divider·busy START·DATA/LOAD reset 및 terminal high timing을 보강했다. 현재 driver는 `resetload`와 일치하고 `closed` driver와 다르므로 각 실행의 snapshot을 사용한다. 두 build의 DUT RTL은 동일하다. divider 0–3 진단은 3 checks FAIL로 OPEN이다.

I2C는 wrapper ACK 연결, pin decode, 주소 분포, final NACK 및 reset/drain 검사를 보강했다. distributed 16개 소스 hash가 현재 파일과 일치한다. ACK 배선 수정 코드와 후속 실행 근거는 존재하지만 교육 당시 sampling 수정의 인과관계와는 별개다. Before seed 1 / After seed 10은 동일 seed A/B가 아니다. ACK continuation, multi-byte, repeated START, clock stretching/arbitration, 전용 duration timing은 미검증이다.

## 재실행

보존 regression scripts는 당시 실행 방식의 근거이며 이 패키징에서 실행하지 않았다. `python3 prepare_replay.py --project <name> --build <tag> --output <새 빈 경로>`로 당시 snapshot과 scripts를 별도 경로에 준비할 수 있다. 이 명령은 복사와 명령 출력만 수행한다. 실행에는 VCS/URG/UVM 및 라이선스가 필요하다. 생성된 새 경로에서만 compile·simulation하며 기존 evidence와 run 이름을 덮어쓰지 않는다. 새 실행 결과를 확인하기 전에는 PASS로 기록하지 않는다.

전체 101건은 SPI 16 + I2C 15 + AXI 15 + VGA 14 + Basic 41이다. CNN은 이 101건에 포함되지 않는다. 교육 당시 결과, 실패 재현, 의도적인 checker qualification, 미해결 진단 실패, 최종 정상 회귀를 구분한다.

## 업로드 확정 안내 (2026-10-29)

### 최초 교육 구현과 후속 작성 주체

SPI/I2C는 사용자가 직접 수행한 **개인 교육 프로젝트**다. 교육 당시 RTL 설계·UVM 환경 구성·보드 검증 이력과, 2026년 10월 Codex 지원으로 작성·수정된 RTL/UVM·자동화·검수 자료의 작성 주체를 구분한다. 후속 자동화 수정 코드를 교육 당시 사용자가 직접 작성한 코드로 소급하지 않는다. 교육 당시 SPI 48 checks / FC 59.59%, I2C 최종 14 PASS / FC 100%는 과거 로그의 결과이며, I2C 초기 sampling 수정의 인과관계는 별도 미확정이다.

해결 근거: SPI terminal high의 STOP/half_tick 처리와 I2C wrapper ACK 포트 연결 수정. SPI Before build는 pulse_before, After는 closed이며 현재 driver는 resetload다. I2C Before baseline/seed 1과 After distributed/seed 10은 동일 seed 실험이 아니다. 일부 역사적 실패 build에는 당시 소스 manifest가 없어 정확한 per-run source hash를 복원했다고 주장하지 않는다.

### 로그·Coverage·소스·파형 위치

- [정상 실행별 계수·로그 경로](audit/canonical_runs.csv)
- [실행 metadata 및 source snapshot 매핑](audit/canonical_runs.json)
- [Baseline → Enhancement 변경과 SHA-256](audit/baseline_to_followup_changes.json)
- [빌드별 소스 해시 확인](audit/source_build_checks.json)
- [전체 101개 로그의 출처·보존 범위](audit/provenance_101.json)
- [2026-10-28 원본 검수 문서](audit/original_20261028/review.html)

원본 로그·metadata의 `wave`는 당시 로컬 VCD 위치를 기록한다. 파형과 VDB는 승인된 경량 업로드에서 제외했으며, GitHub에서 다운로드 가능한 것으로 표시하지 않는다. Native 화면 원본과 캡처 조건은 로컬 `/home/pedu36/workspace/UVM_ENHANCEMENT_20261019/PPT_FINAL_SELECTION/NATIVE_WAVEFORMS/`의 `SOURCE_MANIFEST.json`, `CAPTURE_METADATA.md`와 연결된다. 아래 원본 VCD는 형식 변환 후 실제 Verdi nWave에서 열어 캡처한 자료이며, 파형을 재도식화한 이미지와 구분한다.

- `/home/pedu36/workspace/UVM_ENHANCEMENT_20261019/projects/spi/runs/pulse_before_failure_s55_n4/trace.vcd`
- `/home/pedu36/workspace/UVM_ENHANCEMENT_20261019/projects/spi/runs/closed_smoke_s55_n4/trace.vcd`
- `/home/pedu36/workspace/UVM_ENHANCEMENT_20261019/projects/i2c/runs/baseline_failure_s1_n14/trace.vcd`
- `/home/pedu36/workspace/UVM_ENHANCEMENT_20261019/projects/i2c/runs/distributed_directed_s10_n24/trace.vcd`

Native Coverage TXT 경로:

- [spi/coverage/closed_final/groups.txt](evidence/spi/coverage/closed_final/groups.txt)
- [spi/coverage/closed_final/hierarchy.txt](evidence/spi/coverage/closed_final/hierarchy.txt)
- [spi/coverage/closed_final/tests.txt](evidence/spi/coverage/closed_final/tests.txt)
- [i2c/coverage/distributed/groups.txt](evidence/i2c/coverage/distributed/groups.txt)
- [i2c/coverage/distributed/hierarchy.txt](evidence/i2c/coverage/distributed/hierarchy.txt)
- [i2c/coverage/distributed/tests.txt](evidence/i2c/coverage/distributed/tests.txt)

기존 main과 교육 원본 경로에는 변경을 적용하지 않는다. 이 폴더의 로그는 기존 실행 보존이며 업로드·검수 과정의 새 simulation/URG 실행은 0회다.

### 전달 형식 기록

자동 승인 검토의 요청 크기 제한에 맞추어 `audit/original_execution_manifest_101.json`은 JSON 공백만 축소했다. 101개 실행 객체의 값·배열 순서·구조는 원본과 동일하다. 원본 파일 SHA-256 및 변환 후 SHA-256을 `audit/file_origins.json`에 함께 기록했다. RTL·Testbench·실행 로그·2026-10-28 원본 검수 파일은 byte 그대로 보존했다.
