# M0 Evaluation Results and Limitations

## Current Result

This document records the M0 evaluation status as of September 29, 2026. M4 integration, local tests, and GitHub CI are verified on commit `c442dca7966543088623a4cbabcfdb68103ea829`. See the [M4 Issue 5 verification report](../M4/issue5_verification_results.md) for the tested commit, commands, raw results, CI jobs, walkthrough, and limitations.

M0 successfully defined the checkout-rejection scenarios, documented current WolfBite checkout behavior, established a passing local automated-test baseline, and created a scoring instrument that produces the expected results for known passing and failing synthetic data. It did **not** verify that real shoppers can identify the expected next step within 60 seconds or that M4 meets the success and improvement targets.

**Participant/user testing was not conducted. Actual usefulness to real users remains unverified.**

## What Was Evaluated

M0 evaluated the documented checkout-help scenarios, existing checkout and basket behavior, 50 selected automated baseline tests, and the Task 3 scoring rules using synthetic records. The evidence is recorded in:

* [M0 Checkout-Help Findings](m0_checkout_help_findings.md)
* [M0/M4 Shared Checkout-Help Use Cases](m4_checkout_help_use_cases.md)
* [M0 Baseline Checkout Test Results](m0_baseline_checkout_results.md)
* [M0 Checkout-Help Scoring](m0_scoring_documentation.md)

M0 did not evaluate participant performance. The scoring script and its 13 automated tests passed locally, including a repeat run on September 26, 2026. On September 26, the selected 50-test Flutter baseline also passed in a clean temporary local copy and in GitHub Actions. The scoring workflow passed again on the same commit. The remote runs are linked below.

M4 is now implemented and verified in CI. The Issue 5 rerun used a clean archive of commit `c442dca7966543088623a4cbabcfdb68103ea829`: **139 M4 tests, 50 M0 baseline tests, and 13 scorer tests passed locally**, with zero failures or skips. Both known synthetic scoring examples produced their expected outcomes. All four corresponding GitHub CI jobs passed on that same commit. The developer browser walkthrough also passed all four prepared scenarios with unchanged basket and benefit state. No participant evaluation was conducted.

## Evaluation Check Results

Statuses mean:

* **Pass:** Repository evidence or the linked GitHub Actions run shows the check was completed successfully.
* **Fail:** The check was performed and did not meet its requirement.
* **Not Verified:** The required feature, data, test, or evaluation is unavailable.

| M0 evaluation check | Status | Evidence or result |
| --- | --- | --- |
| Shared rejection scenarios and expected next steps are defined | **Pass** | M0-M4-01, M0-M4-02, M0-M4-03, and fallback M0-M4-F01 are documented in the shared use cases. |
| Current checkout and basket behavior is documented | **Pass** | The findings and baseline report describe the original flow before M4; the Issue 5 report records the completed help flow. |
| Relevant local baseline tests pass | **Pass** | September 29 regression: 50 selected tests passed; 0 failed; 0 skipped (38 team, 5 allowance, 7 inherited). See the [M4 Issue 5 report](../M4/issue5_verification_results.md). |
| Relevant baseline tests pass in GitHub Actions | **Pass** | [M0 baseline job](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638/job/109695724475) passed all three selected groups and report upload on `c442dca7966543088623a4cbabcfdb68103ea829`. |
| Current rejection-related behavior is recorded | **Pass** | Allowance refusal, paid overflow, checkout state changes, and the lack of an official checkout rejection reason are documented. |
| Sample trial records can be read and scored | **Pass** | The scorer reads both synthetic fixtures and calculates their expected success rates and improvement. |
| Known passing and failing examples produce the expected results | **Pass** | The passing fixture reports 60% baseline, 80% M4, and a 20-point improvement. The failing fixture reports 60%, 60%, and zero improvement. |
| Scoring behavior is covered by local automated tests | **Pass** | All 13 scorer tests pass locally, including the 60-second boundary and invalid-data checks. |
| Scoring checks pass in GitHub Actions | **Pass** | [M0 scoring job](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638/job/109695724277) passed the scorer tests and both example steps on `c442dca7966543088623a4cbabcfdb68103ea829`. |
| M4 checkout help is implemented and its feature tests pass locally | **Pass** | All 139 M4 tests passed on September 29, covering the three causes, fallback, selected-item interface, unchanged state, and no checkout/reset-triggering reload. |
| M4 feature tests pass in GitHub Actions | **Pass** | [Run 36654481638](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638): M4 unit and widget jobs succeeded on the tested commit, alongside M0 baseline/scoring. |
| All prepared scenarios work through the basket without state changes | **Pass** | Developer walkthrough and per-scenario widget tests confirm selected-item messages, unchanged basket/benefits, and no checkout, clear, or reset-triggering reload. See [Issue 5](../M4/issue5_verification_results.md). |
| A shopper identifies the expected next step within 60 seconds | **Not Verified** | Participant/user testing was not conducted. |
| M4 achieves at least an 80% success rate | **Not Verified** | No M4 participant trial records exist. |
| Improvement over the baseline is calculated from participant trials | **Not Verified** | No participant baseline rate or M4 success rate exists. Flutter test pass rates are not participant success rates. |
| M4 improves success by at least 20 percentage points | **Not Verified** | The required baseline and M4 participant rates are unavailable. |
| Actual usefulness to real users is demonstrated | **Not Verified** | Automated application tests do not establish user comprehension or usefulness. |

No required check in the selected M0 baseline or the latest M4 local selection failed. The separate September 27 full-application run recorded **278 passes and four failures** involving blank-category alternatives, rejected-alternative success messaging, signup profile-save errors, and sign-out errors; these remain documented limitations and are not hidden by the selected-suite results. See the [full-suite log](../M4/test_results/issue3_2026-09-27/full_suite_final.txt). The full suite was not rerun on September 29.

The known failing synthetic scoring fixture is intentionally expected to fail and proves that the instrument can report unmet requirements. Checks without the required evidence remain **Not Verified**; they must not be reported as passing.

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

### Latest M4/M0 CI Evidence — September 29, 2026

* Tested commit: `c442dca7966543088623a4cbabcfdb68103ea829`.
* [Combined M4 run 36654481638](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638): **success**, including M4 unit, M4 widget, M0 baseline, and M0 scoring jobs.
* [Separate M0 baseline run 36654481328](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481328): **success** on the same commit.
* [Separate M0 scoring run 36654481298](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481298): **success** on the same commit.
* GitHub Actions API job/step records and artifact metadata are saved with the [Issue 5 evidence](../M4/issue5_verification_results.md). These results verify code behavior and scoring, not user outcomes.

### Historical CI Evidence — September 26, 2026

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
* **M4 is locally implemented and tested, but not evaluated with participants.** The 139 passing M4 tests and unchanged 50-test baseline establish automated behavior and regression coverage. They do not establish the 60-second, 80%, or 20-percentage-point user outcomes. M4 CI now passes on the recorded commit; participant effectiveness remains unverified.
* **The scorer uses synthetic records.** Its passing result demonstrates correct calculations and does not claim that M4 achieved the thresholds.
* **Scoring CI covers the instrument only.** Its successful run does not establish baseline Flutter CI results, M4 feature behavior, or participant outcomes.
* **The baseline is selected.** It covers 50 relevant tests rather than the complete application test suite. This selection passes in the latest local run and the verified September 29 CI run. Four failures remain in the recorded full-application run; the entire application is not established as passing.
* **The original September 21 environment was not a clean checkout.** The historical report records locally resolved dependencies and uncommitted configuration changes. The September 26 CI run uses a repository checkout and committed dependency versions.
* **Tests used mocks and fakes.** They did not use a live Approved Product List, camera, cashier system, or official checkout response.
* **The regular app still points to the previous team's Firebase project.** The current team uses `wolfbyte-proj1`. A separate September 29 read-only walkthrough loaded its APL products and exercised fallback help with a local-only basket; it did not validate authenticated Firebase basket persistence, benefit evidence, or participant outcomes. It is not part of the 189-test automated result.
* **QR coverage was limited.** Existing tests primarily confirmed rendering rather than an end-to-end cashier handoff.
* **The legacy full-application CI still needs review.** `flutter-ci.yml` points to `Project2`. The new M0 baseline workflow runs the selected checks from `Project3`; its success does not establish that the legacy workflow or the full application suite passes.

## Changes and Follow-up Work Needed

1. Review the legacy full-application Flutter workflow separately; the selected M0 baseline checks now pass in their dedicated CI workflow.
2. Coordinate the move to the current team's Firebase project and verify its Authentication, Firestore rules, and APL data.
3. M4 implementation and local feature testing are complete for the agreed mock scope. Keep the shared scenario IDs and expected next steps aligned when changing the feature.
4. M4 unit/widget, M0 regression, and M0 scoring CI are complete on the recorded commit. Retain these checks for future changes. Resolve or track the four full-application failures separately.
5. Conduct comparable baseline and M4 participant trials without outside assistance if real evidence is pursued.
6. Use the scorer to calculate the real success rates and percentage-point improvement when trial records exist.
7. Replace the remaining **Not Verified** statuses with measured Pass or Fail results where evidence becomes available.

## Conclusion

The scenario-definition, current-behavior documentation, selected local baseline, verified M0 baseline/scoring CI, synthetic scorer demonstrations, and 13 recorded local scorer tests **passed**. The latest 139 M4 feature tests, 50 M0 regression tests, and 13 scorer tests **passed locally**, and their corresponding CI jobs **passed on the same commit**. The developer scenario walkthrough and state-preservation checks also passed. The recorded full-application run has four failures outside those selections.

The 60-second real-user outcome, the 80% M4 success requirement, the 20-percentage-point improvement requirement, and actual user usefulness remain **Not Verified**. **Participant testing was not conducted.**

This documentation completes Task 4's reporting requirement for the evidence currently present in the repository. It does not establish that M0's user-effectiveness targets were achieved.
