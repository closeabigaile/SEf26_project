# M0 Baseline Checkout Test Results

## Result

**50 tests passed; 0 failed; 0 skipped.** All three test commands exited with code 0 on September 21, 2026. These are local baseline results, not CI results or M4 feature results.

The selection covers QR handoff, checkout completion, saved state, basket controls, and category-allowance behavior. The complete basket-related files also include supporting receipt-addition, nutrition-display, and balance-display checks; not all 50 tests exercise checkout directly.

| Test selection | Passed | Evidence |
| --- | ---: | --- |
| Team tests: UC11–UC20 and the coverage-gap file | 38 | [Raw output](test_results/baseline_team_2026-09-21.txt) |
| Team tests: UC8 addition and allowance checks | 5 | [Raw output](test_results/baseline_allowance_2026-09-21.txt) |
| Inherited QR checkout and basket UI tests | 7 | [Raw output](test_results/baseline_inherited_2026-09-21.txt) |
| **Total** | **50** | |

## Environment

* Branch: `M0-evaluate-checkout-help`.
* HEAD: `a01028b80e66acf0e28f6e132ff5b7aa01a0fbc5`.
* Platform: macOS, Apple silicon (`Darwin arm64`).
* Flutter: `3.47.2` stable; Dart: `3.13.2`.
* Tests ran from `Project3`, with one worker and existing dependencies (`--no-pub`). Resolved package configuration used `cloud_firestore 6.7.1` and `fake_cloud_firestore 4.2.0`.
* Existing uncommitted settings were retained: `pubspec.yaml` pins those two package versions; `analysis_options.yaml` adds generated/platform-folder exclusions. This is a result for the local working tree, not a clean-checkout reproduction.
* The tests use fake/mocked account and product state. They did not require a live APL record, camera, or participant session.

The initial sandboxed launch could not write to Flutter's SDK cache and stopped before running tests. The same test command was rerun with permission and passed. No application code, test source, or dependency configuration was changed for this run.

## Behavior Verified

| Baseline behavior | Test evidence | Result |
| --- | --- | --- |
| QR handoff displays a QR widget | `test_uc19_qr_code_contains_current_basket_data` in [supreme_uc16-20_test.dart](../../Project3/test/project1a/supreme_uc16-20_test.dart); `renders QR code using basket JSON` in [qr_checkout_screen_test.dart](../../Project3/test/screens/qr_checkout_screen_test.dart) | Pass; widget presence only |
| Checkout clears the basket and retains used benefits | `test_uc20_checkout_clears_basket_but_retains_benefit_usage` in the UC16–UC20 file | Pass |
| Checkout saves an empty basket with retained usage | `checkout saves an empty basket and retains used benefits` in [project1a_coverage_gaps_test.dart](../../Project3/test/active/project1a_coverage_gaps_test.dart) | Pass |
| A save failure propagates an exception after local basket clearing | `save failure leaves the local basket cleared and reports failure` in the coverage-gap file | Pass; confirms an existing limitation |
| A new item is refused when allowance is exhausted | `UC8-T2 exhausted allowance -> unchanged basket and usage` in [aditya_uc6-10_test.dart](../../Project3/test/project1a/aditya_uc6-10_test.dart) | Pass |
| Increasing an existing item at its category cap creates a separate paid line | `test_uc15_increment_at_cap_creates_separate_paid_line` in [satwi_uc11-15_test.dart](../../Project3/test/project1a/satwi_uc11-15_test.dart) | Pass |
| Basket display, quantity changes, paid-intent tooltip, clearing, and clear cancellation | UC12–UC17 tests, coverage-gap tests, and [basket_screen_test.dart](../../Project3/test/screens/basket_screen_test.dart) | Pass |

Per-file counts: UC16–UC20 **13**, UC11–UC15 **14**, coverage gaps **11**, selected UC8 **5**, inherited QR **1**, inherited basket **6**.

## Commands to Reproduce

From the repository's `Project3` directory, with dependencies already installed and the output directory present:

```bash
flutter test test/project1a/supreme_uc16-20_test.dart test/project1a/satwi_uc11-15_test.dart test/active/project1a_coverage_gaps_test.dart \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M0/test_results/baseline_team_2026-09-21.txt

flutter test test/project1a/aditya_uc6-10_test.dart \
  --plain-name 'UC8 - Add product to basket' \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M0/test_results/baseline_allowance_2026-09-21.txt

flutter test test/screens/qr_checkout_screen_test.dart test/screens/basket_screen_test.dart \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M0/test_results/baseline_inherited_2026-09-21.txt
```

Use new output filenames for future runs to preserve this evidence.

## September 26 CI Verification

The same three baseline selections passed in [M0 Checkout Baseline, run 36263549665](https://github.com/closeabigaile/SEf26_project/actions/runs/36263549665) for commit `e628c4150b553d1b91f7500b1353912a28978500` on `M0-evaluate-checkout-help`. All three test steps and report upload completed successfully. The 50 tests also passed in a clean temporary local copy before the push.

The [dedicated baseline workflow](../../.github/workflows/m0-checkout-baseline.yml) uses Ubuntu, Flutter `3.47.2`, the `Project3` working directory, and committed dependency versions installed with `flutter pub get --enforce-lockfile`. Its report artifact is named `m0-checkout-baseline-results`. This supplements the September 21 local evidence above; those original logs are preserved.

The workflow runs on pushes and pull requests that change `Project3/**`, `Project2_Work/M0/**`, or the workflow itself. To inspect a run, open GitHub **Actions → M0 Checkout Baseline → Test M0 checkout baseline**, then expand the three test steps. The run summary also contains the downloadable reports.

## Limitations and Remaining Work

* **Passing tests do not mean all checkout behavior is correct.** In particular, the save-failure test expects an exception and a locally cleared basket. It does not prove recovery or a shopper-facing error message. Review this behavior separately before treating checkout persistence as robust.
* **QR coverage is limited.** The QR tests assert widget presence, not exact encoded basket data, cashier scanning, or a complete Finish Transaction button/navigation interaction. The inherited QR test's replacement `checkout` method resets usage, unlike production; its render-only test does not verify production checkout behavior.
* **M4 scenarios are not covered yet.** Package-size explanations, balance-help explanations, stale-information handling, the fallback, and returning from help to an unchanged basket still need M4 feature tests using the [shared use cases](m4_checkout_help_use_cases.md).
* **CI covers this selection only.** The dedicated M0 baseline workflow passes. The legacy [full-application workflow](../../.github/workflows/flutter-ci.yml) still points at `Project2` and needs separate review.
* **This was a selected baseline run, not the full application suite.** No code fixes were required to get these selected tests to pass.
* **Participant testing was not conducted, and user usefulness remains unverified.** These results do not establish the 60-second, 80% success, or 20-percentage-point improvement targets.

**Task 2 status:** The baseline-checkout portion is complete locally and in CI. M4 feature verification, including its CI checks, remains pending until M4 is implemented.
