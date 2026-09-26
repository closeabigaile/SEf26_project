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

M0 did not evaluate participant performance or an implemented M4 feature. The scoring script and its 13 automated tests passed locally, including a repeat run on September 26, 2026. The scoring-specific GitHub Actions workflow completed successfully on September 25, 2026; its result was verified on September 26, 2026. The remote run is linked below. The baseline Flutter checks have local evidence only.

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
| Relevant baseline tests pass in GitHub Actions | **Not Verified** | The collected baseline outputs are from local runs. No passing baseline CI result was collected. |
| Current rejection-related behavior is recorded | **Pass** | Allowance refusal, paid overflow, checkout state changes, and the lack of an official checkout rejection reason are documented. |
| Sample trial records can be read and scored | **Pass** | The scorer reads both synthetic fixtures and calculates their expected success rates and improvement. |
| Known passing and failing examples produce the expected results | **Pass** | The passing fixture reports 60% baseline, 80% M4, and a 20-point improvement. The failing fixture reports 60%, 60%, and zero improvement. |
| Scoring behavior is covered by local automated tests | **Pass** | All 13 scorer tests pass locally, including the 60-second boundary and invalid-data checks. |
| Scoring checks pass in GitHub Actions | **Pass** | [M0 Checkout Trial Scoring, run 36193613481](https://github.com/closeabigaile/SEf26_project/actions/runs/36193613481) completed successfully for commit `8a4a3e7de45820ef631b90bf3b2d47494e961005`. |
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

* Workflow: `M0 Checkout Trial Scoring` (`.github/workflows/m0-scoring.yml`).
* [Run 36193613481](https://github.com/closeabigaile/SEf26_project/actions/runs/36193613481): status **completed**, conclusion **success**.
* Trigger: push to `M0-evaluate-checkout-help`.
* Commit: `8a4a3e7de45820ef631b90bf3b2d47494e961005` (`Task 4 update`).
* Run date: September 25, 2026; result verified September 26, 2026.
* The workflow runs the scoring unit tests and both synthetic examples using Python 3.12. It does not run the Flutter baseline or M4 feature tests.

The failing synthetic example is expected to report **FAIL**. The automated tests assert its expected failing scores, so a successful CI run is consistent with that example failing the evaluation thresholds.

## Limitations

* **Participant/user testing was not conducted.** There are no timed observations for either the current flow or an M4 flow.
* **Actual usefulness to real users remains unverified.** Automated tests measure code behavior, not comprehension, speed, or usefulness.
* **M4 is not implemented.** No M4 behavior or feature-test evidence can be compared with the baseline.
* **The scorer uses synthetic records.** Its passing result demonstrates correct calculations and does not claim that M4 achieved the thresholds.
* **Scoring CI covers the instrument only.** Its successful run does not establish baseline Flutter CI results, M4 feature behavior, or participant outcomes.
* **The baseline was local and selected.** It covered 50 relevant tests rather than the complete application test suite and was not reproduced in CI.
* **The test environment was not a clean checkout.** The baseline report records locally resolved dependencies and retained uncommitted configuration changes.
* **Tests used mocks and fakes.** They did not use a live Approved Product List, camera, cashier system, or official checkout response.
* **The live Firebase configuration is outdated for the current team.** The repository points to the previous team's Firebase project while the current team uses a different project, so live APL behavior was not verified.
* **QR coverage was limited.** Existing tests primarily confirmed rendering rather than an end-to-end cashier handoff.
* **Application CI needs review.** The existing Flutter workflow points to `Project2`, while the evaluated application is in `Project3`.

## Changes and Follow-up Work Needed

1. Correct or replace the Flutter workflow so the relevant Project 3 baseline checks run in CI, and record the remote result.
2. Coordinate the move to the current team's Firebase project and verify its Authentication, Firestore rules, and APL data.
3. Implement M4 checkout help using the shared scenario IDs and expected next steps.
4. Add M4 feature tests for all three primary scenarios, the fallback, and unchanged basket state, then run them in CI.
5. Conduct comparable baseline and M4 participant trials without outside assistance if real evidence is pursued.
6. Use the scorer to calculate the real success rates and percentage-point improvement when trial records exist.
7. Replace the remaining **Not Verified** statuses with measured Pass or Fail results where evidence becomes available.

## Conclusion

The scenario-definition, current-behavior documentation, selected local baseline checks, synthetic scorer demonstrations, 13 local scorer tests, and scoring CI **passed**. No measured project check **failed**. Baseline CI, M4 feature behavior, the 60-second real-user outcome, the 80% M4 success requirement, and the 20-percentage-point improvement requirement remain **Not Verified**.

This documentation completes Task 4's reporting requirement for the evidence currently present in the repository. It does not establish that M0's user-effectiveness targets were achieved.
