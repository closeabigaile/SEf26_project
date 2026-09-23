# M0 Evaluation Results and Limitations

## Final Result

This document records the final M0 evaluation status supported by repository evidence as of September 22, 2026.

M0 successfully defined the checkout-rejection scenarios, documented current WolfBite checkout behavior, and established a passing local automated-test baseline. It did **not** verify that shoppers can identify the expected next step within 60 seconds or that M4 meets the success and improvement targets.

**Participant/user testing was not conducted. Actual usefulness to real users remains unverified.**

## What Was Evaluated

M0 evaluated the documented checkout-help scenarios, existing checkout and basket behavior, and 50 selected automated baseline tests. The evidence is recorded in:

* [M0 Checkout-Help Findings](m0_checkout_help_findings.md)
* [M0/M4 Shared Checkout-Help Use Cases](m4_checkout_help_use_cases.md)
* [M0 Baseline Checkout Test Results](m0_baseline_checkout_results.md)

M0 did not evaluate participant performance or an implemented M4 feature. The Task 3 scoring script also remains unimplemented.

## Evaluation Check Results

Statuses mean:

* **Pass:** Repository evidence shows the check was completed successfully.
* **Fail:** The check was performed and did not meet its requirement.
* **Not Verified:** The required feature, data, test, or evaluation is unavailable.

| M0 evaluation check | Status | Evidence or result |
| --- | --- | --- |
| Shared rejection scenarios and expected next steps are defined | **Pass** | M0-M4-01, M0-M4-02, M0-M4-03, and fallback M0-M4-F01 are documented in the shared use cases. |
| Current checkout and basket behavior is documented | **Pass** | The findings and baseline report describe current behavior and missing checkout help. |
| Relevant local baseline tests pass | **Pass** | 50 selected tests passed; 0 failed; 0 skipped. All three baseline commands exited successfully. |
| Current rejection-related behavior is recorded | **Pass** | Allowance refusal, paid overflow, checkout state changes, and the lack of an official checkout rejection reason are documented. |
| Sample trial records can be read and scored | **Not Verified** | The Task 3 scoring script and sample records have not been implemented. |
| Scoring behavior is covered by automated tests and CI | **Not Verified** | No Task 3 scorer tests or scoring-specific CI check exist. |
| M4 checkout help is implemented and its feature tests pass | **Not Verified** | M4 checkout help and its feature tests do not yet exist. |
| A shopper identifies the expected next step within 60 seconds | **Not Verified** | Participant/user testing was not conducted. |
| M4 achieves at least an 80% success rate | **Not Verified** | No M4 participant trial records exist. |
| Improvement over the baseline is calculated | **Not Verified** | No participant baseline rate or M4 success rate exists. Flutter test pass rates are not participant success rates. |
| M4 improves success by at least 20 percentage points | **Not Verified** | The required baseline and M4 participant rates are unavailable. |
| Actual usefulness to real users is demonstrated | **Not Verified** | Automated application tests do not establish user comprehension or usefulness. |

No check is marked **Fail** because no measured check produced a failing result. Checks without the required implementation or evidence are **Not Verified**; they must not be reported as passing.

## Passed Evidence

The local baseline contained:

| Test group | Passed |
| --- | ---: |
| UC11-UC20 and coverage-gap tests | 38 |
| Selected UC8 addition and allowance tests | 5 |
| Inherited QR checkout and basket-screen tests | 7 |
| **Total** | **50** |

These tests confirm relevant code behavior, including allowance refusal, paid overflow, basket controls, QR widget rendering, checkout state changes, and persistence-failure behavior. They do not measure whether a real shopper understands what to do after a rejection.

## Limitations

* **Participant/user testing was not conducted.** There are no timed observations for either the current flow or an M4 flow.
* **Actual usefulness to real users remains unverified.** Automated tests measure code behavior, not comprehension, speed, or usefulness.
* **M4 is not implemented.** No M4 behavior or feature-test evidence can be compared with the baseline.
* **The Task 3 scorer is not implemented.** Sample records, threshold calculations, scorer tests, and scoring CI checks remain pending.
* **The baseline was local and selected.** It covered 50 relevant tests rather than the complete application test suite and was not reproduced in CI.
* **The test environment was not a clean checkout.** The baseline report records locally resolved dependencies and retained uncommitted configuration changes.
* **Tests used mocks and fakes.** They did not use a live Approved Product List, camera, cashier system, or official checkout response.
* **QR coverage was limited.** Existing tests primarily confirmed rendering rather than an end-to-end cashier handoff.
* **CI needs review.** The existing workflow points to `Project2`, while the evaluated application is in `Project3`.

## Changes and Follow-up Work Needed

1. Implement the Task 3 scoring script, known passing and failing sample records, automated tests, and a CI check.
2. Implement M4 checkout help using the shared scenario IDs and expected next steps.
3. Add M4 feature tests for all three primary scenarios, the fallback, and unchanged basket state.
4. Conduct comparable baseline and M4 participant trials without outside assistance.
5. Use the scorer to calculate the real success rates and percentage-point improvement.
6. Replace the **Not Verified** statuses with measured Pass or Fail results where evidence becomes available.
7. Correct or replace the current CI workflow so it runs the relevant Project 3 and M0 checks.

## Conclusion

The scenario-definition, current-behavior documentation, and selected local baseline checks **passed**. No measured check **failed**. The 60-second outcome, 80% M4 success requirement, and 20-percentage-point improvement requirement are **Not Verified** because M4, the scorer, and participant trial data are unavailable.

This documentation completes Task 4's reporting requirement for the evidence currently present in the repository. It does not establish that M0's user-effectiveness targets were achieved.
