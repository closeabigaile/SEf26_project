# M0 Evaluation Results and Limitations

## Current Result

This document records the M0 evaluation status supported by repository evidence and the verified GitHub Actions result as of September 26, 2026.

M0 successfully defined the checkout-rejection scenarios, documented current WolfBite checkout behavior, established a passing local automated-test baseline, and created a scoring instrument that produces the expected results for known passing and failing synthetic data. It did **not** verify that real shoppers can identify the expected next step within 60 seconds or that M4 meets the success and improvement targets.

**Participant/user testing was not conducted. Actual usefulness to real users remains unverified.**

## What Was Evaluated

M0 evaluated the documented checkout-help scenarios, existing checkout and basket behavior, 50 selected automated baseline tests, and the Task 3 scoring rules using synthetic records. The evidence is recorded in:

* [M0 Checkout-Help Findings](m0_checkout_help_findings.md)
* [M0/M4 Shared Checkout-Help Use Cases](m4_checkout_help_use_cases.md)
* [M0 Baseline Checkout Test Results](m0_baseline_checkout_results.md)
* [M0 Checkout-Help Scoring](m0_scoring_documentation.md)

M0 did not evaluate participant performance or an implemented M4 feature. The scoring script and its 13 automated tests passed locally, including a repeat run on September 26, 2026. On September 26, the selected 50-test Flutter baseline also passed in a clean temporary local copy and in GitHub Actions. The scoring workflow passed again on the same commit. The remote runs are linked below.

## Evaluation Check Results

Statuses mean:

* **Pass:** Repository evidence or the linked GitHub Actions run shows the check was completed successfully.
* **Fail:** The check was performed and did not meet its requirement.
* **Not Verified:** The required feature, data, test, or evaluation is unavailable.

| M0 evaluation check | Status | Evidence or result |
| --- | --- | --- |
| Shared rejection scenarios and expected next steps are defined | **Pass** | M0-M4-01, M0-M4-02, M0-M4-03, and fallback M0-M4-F01 are documented in the shared use cases. |
| Current checkout and basket behavior is documented | **Pass** | The findings and baseline report describe current behavior and missing checkout help. |
| Relevant local baseline tests pass | **Pass** | 50 selected tests passed; 0 failed; 0 skipped. All three baseline commands exited successfully. |
| Relevant baseline tests pass in GitHub Actions | **Pass** | [M0 Checkout Baseline, run 36263549665](https://github.com/closeabigaile/SEf26_project/actions/runs/36263549665) completed successfully, including all three selected test groups and report upload. |
| Current rejection-related behavior is recorded | **Pass** | Allowance refusal, paid overflow, checkout state changes, and the lack of an official checkout rejection reason are documented. |
| Sample trial records can be read and scored | **Pass** | The scorer reads both synthetic fixtures and calculates their expected success rates and improvement. |
| Known passing and failing examples produce the expected results | **Pass** | The passing fixture reports 60% baseline, 80% M4, and a 20-point improvement. The failing fixture reports 60%, 60%, and zero improvement. |
| Scoring behavior is covered by local automated tests | **Pass** | All 13 scorer tests pass locally, including the 60-second boundary and invalid-data checks. |
| Scoring checks pass in GitHub Actions | **Pass** | [M0 Checkout Trial Scoring, run 36263549773](https://github.com/closeabigaile/SEf26_project/actions/runs/36263549773) completed successfully for commit `e628c4150b553d1b91f7500b1353912a28978500`. |
| M4 checkout help is implemented and its feature tests pass | **Not Verified** | M4 checkout help and its feature tests do not yet exist. |
| A shopper identifies the expected next step within 60 seconds | **Not Verified** | Participant/user testing was not conducted. |
| M4 achieves at least an 80% success rate | **Not Verified** | No M4 participant trial records exist. |
| Improvement over the baseline is calculated from participant trials | **Not Verified** | No participant baseline rate or M4 success rate exists. Flutter test pass rates are not participant success rates. |
| M4 improves success by at least 20 percentage points | **Not Verified** | The required baseline and M4 participant rates are unavailable. |
| Actual usefulness to real users is demonstrated | **Not Verified** | Automated application tests do not establish user comprehension or usefulness. |

No project outcome is marked **Fail** because no measured project check produced a failing result. The known failing synthetic fixture is intentionally expected to fail and proves that the instrument can report unmet requirements. Checks without the required implementation or evidence are **Not Verified**; they must not be reported as passing.

## Passed Evidence

The local baseline contained:

| Test group | Passed |
| --- | ---: |
| UC11-UC20 and coverage-gap tests | 38 |
| Selected UC8 addition and allowance tests | 5 |
| Inherited QR checkout and basket-screen tests | 7 |
| **Total** | **50** |

These tests confirm relevant code behavior, including allowance refusal, paid overflow, basket controls, QR widget rendering, checkout state changes, and persistence-failure behavior. They do not measure whether a real shopper understands what to do after a rejection.

The scoring instrument also passed its local checks:

| Scoring evidence | Result |
| --- | --- |
| Known passing synthetic fixture | 60% baseline, 80% M4, 20-point improvement; **Pass** |
| Known failing synthetic fixture | 60% baseline, 60% M4, 0-point improvement; **Fail as expected** |
| Automated scorer tests | 13 passed, 0 failed |

These results verify the instrument's calculations, not M4 or real-user usefulness.

### Collected CI Evidence

* Baseline workflow: `M0 Checkout Baseline` (`.github/workflows/m0-checkout-baseline.yml`), [run 36263549665](https://github.com/closeabigaile/SEf26_project/actions/runs/36263549665): **completed**, **success**.
* The baseline job ran on Ubuntu with Flutter `3.47.2`, from `Project3`, using `flutter pub get --enforce-lockfile`. All three test steps (38 team tests, 5 UC8 tests, 7 inherited tests) and the `m0-checkout-baseline-results` report upload completed successfully.
* Scoring workflow: `M0 Checkout Trial Scoring` (`.github/workflows/m0-scoring.yml`), [run 36263549773](https://github.com/closeabigaile/SEf26_project/actions/runs/36263549773): **completed**, **success**.
* Trigger: push to `M0-evaluate-checkout-help`.
* Commit for both runs: `e628c4150b553d1b91f7500b1353912a28978500` (`Run M0 checkout baseline tests in GitHub Actions`).
* Run and verification date: September 26, 2026.
* The scoring workflow runs the scoring unit tests and both synthetic examples using Python 3.12. Neither workflow verifies M4 feature behavior.
* The earlier [scoring run 36193613481](https://github.com/closeabigaile/SEf26_project/actions/runs/36193613481) also passed on September 25 for commit `8a4a3e7de45820ef631b90bf3b2d47494e961005`.

The failing synthetic example is expected to report **FAIL**. The automated tests assert its expected failing scores, so a successful CI run is consistent with that example failing the evaluation thresholds.

## Limitations

* **Participant/user testing was not conducted.** There are no timed observations for either the current flow or an M4 flow.
* **Actual usefulness to real users remains unverified.** Automated tests measure code behavior, not comprehension, speed, or usefulness.
* **M4 is not implemented.** No M4 behavior or feature-test evidence can be compared with the baseline.
* **The scorer uses synthetic records.** Its passing result demonstrates correct calculations and does not claim that M4 achieved the thresholds.
* **Scoring CI covers the instrument only.** Its successful run does not establish baseline Flutter CI results, M4 feature behavior, or participant outcomes.
* **The baseline is selected.** It covers 50 relevant tests rather than the complete application test suite. This selection now passes locally and in CI.
* **The original September 21 environment was not a clean checkout.** The historical report records locally resolved dependencies and uncommitted configuration changes. The September 26 CI run uses a repository checkout and committed dependency versions.
* **Tests used mocks and fakes.** They did not use a live Approved Product List, camera, cashier system, or official checkout response.
* **The live Firebase configuration is outdated for the current team.** The repository points to the previous team's Firebase project while the current team uses a different project, so live APL behavior was not verified.
* **QR coverage was limited.** Existing tests primarily confirmed rendering rather than an end-to-end cashier handoff.
* **The legacy full-application CI still needs review.** `flutter-ci.yml` points to `Project2`. The new M0 baseline workflow runs the selected checks from `Project3`; its success does not establish that the legacy workflow or the full application suite passes.

## Changes and Follow-up Work Needed

1. Review the legacy full-application Flutter workflow separately; the selected M0 baseline checks now pass in their dedicated CI workflow.
2. Coordinate the move to the current team's Firebase project and verify its Authentication, Firestore rules, and APL data.
3. Implement M4 checkout help using the shared scenario IDs and expected next steps.
4. Add M4 feature tests for all three primary scenarios, the fallback, and unchanged basket state, then run them in CI.
5. Conduct comparable baseline and M4 participant trials without outside assistance if real evidence is pursued.
6. Use the scorer to calculate the real success rates and percentage-point improvement when trial records exist.
7. Replace the remaining **Not Verified** statuses with measured Pass or Fail results where evidence becomes available.

## Conclusion

The scenario-definition, current-behavior documentation, selected local and CI baseline checks, synthetic scorer demonstrations, 13 local scorer tests, and scoring CI **passed**. No measured project check **failed**. M4 feature behavior, the 60-second real-user outcome, the 80% M4 success requirement, and the 20-percentage-point improvement requirement remain **Not Verified**.

This documentation completes Task 4's reporting requirement for the evidence currently present in the repository. It does not establish that M0's user-effectiveness targets were achieved.
