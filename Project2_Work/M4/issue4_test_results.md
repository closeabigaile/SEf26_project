# M4 Issue 4: Local Automated Testing Verification

Verified on **2026-09-29** against the current working tree on
`M4_implementation_CHeckout_help`, based on commit `35c3ece` and including
uncommitted implementation and test files. Flutter 3.47.2 stable, Dart 3.13.2,
macOS host; existing dependencies were used with `--no-pub`.

**The supplied local “Complete When” checklist is satisfied.** All 139 M4 tests
and all 50 existing M0 checkout baseline tests passed: **189 passed, 0 failed,
0 skipped**. All four test commands exited successfully. No implementation or
test assertions were changed during this verification.

The issue scope also mentions CI. **M4 CI is not verified by this report.** The
local completion checklist does not require a CI result, and existing project
documentation assigns CI verification to Issue 5. If CI is required to close
Issue 4 as well, keep that part pending until a successful remote run is linked.

## Fresh results

| Selection | Passed | Failed | Evidence |
| --- | ---: | ---: | --- |
| Checkout-help service unit tests | 102 | 0 | [M4 log](test_results/issue4_verification_2026-09-29/m4.txt) |
| Additional precision tests | 5 | 0 | Same M4 log |
| Adversarial service regression tests | 8 | 0 | Same M4 log |
| Evidence repository tests | 3 | 0 | Same M4 log |
| Checkout-help screen and state tests | 20 | 0 | Same M4 log |
| Basket help-action widget acceptance test | 1 | 0 | Same M4 log |
| **M4 total** | **139** | **0** | |
| M0 team checkout/basket tests | 38 | 0 | [Team log](test_results/issue4_verification_2026-09-29/m0_team.txt) |
| M0 selected UC8 allowance tests | 5 | 0 | [Allowance log](test_results/issue4_verification_2026-09-29/m0_allowance.txt) |
| M0 inherited QR and basket tests | 7 | 0 | [Inherited log](test_results/issue4_verification_2026-09-29/m0_inherited.txt) |
| **M0 baseline total** | **50** | **0** | |

The 20 screen/state tests comprise 19 widget tests and one original-category
persistence test. Including the separate basket acceptance check, 20 widget
tests passed. Subtotals above must not be added again to the 189-test total.

## Acceptance criteria and coverage

| Requirement | Verified coverage | Result |
| --- | --- | --- |
| All three prepared causes and fallback return expected outputs | Service tests compare the exact cause, explanation, and suggested next step with each fixture's expected output. | Pass |
| Missing/unknown freshness is not automatically outdated | Tests remove freshness fields and test null, unknown, and invalid values on both records; expect fallback. | Pass |
| Outdated evidence cannot assert size/balance diagnosis | Explicitly outdated item or benefit evidence takes priority even when both a size mismatch and shortfall are present. | Pass |
| PAID lines use the original benefit category | Service test expects a cereal shortfall for a PAID line; state test verifies original category survives creation and reload. | Pass |
| Logic preserves input records | All four scenarios compare writable inputs before/after, exercise nested read-only maps, and repeat calls; ambiguous inputs also remain unchanged. | Pass |
| All four scenarios work through the basket | Each test opens the intended card's Get checkout help button in the real BasketScreen, checks the selected item and full explanation/next step, closes help, and confirms My Basket returns. | Pass |
| Wording communicates possible cause or uncertainty | Exact expected explanations plus the explicit “This is guidance, not an official checkout decision.” notice are asserted. | Pass |
| Basket and benefit state remain unchanged | Each scenario compares all basket records and balances before opening, while open, and after closing; the saved fake Firestore document is compared before/after. | Pass |
| Viewing help does not check out or reset usage | Instrumented AppState delegates to real methods and asserts zero checkout, reload, and clear calls. The saved timestamp is placed in the previous month after loading so an unintended reload would exercise the actual monthly reset path. | Pass |
| Existing M0 checkout behavior remains intact | The same 38 + 5 + 7 baseline selection used by the M0 workflow passes without modified baseline tests. | Pass |
| Commands, results, failures, and limitations recorded | This report and linked raw logs. | Pass |

Source tests: [service](../../Project3/test/services/checkout_help_service_test.dart),
[screen/state](../../Project3/test/screens/checkout_help_screen_test.dart),
[repository](../../Project3/test/services/checkout_help_repository_test.dart),
[precision](../../Project3/test/services/checkout_help_precision_test.dart),
[adversarial](../../Project3/test/m4_review/checkout_help_adversarial_test.dart),
and [basket acceptance](../../Project3/test/m4_review/checkout_help_basket_acceptance_test.dart).

Additional widget checks cover ambiguous/conflicting evidence, repeated openings,
same-UPC collisions, delayed/failed loading, changed or removed items, changed
balances, back/outside-tap dismissal, isolated sample baskets, repeated taps,
320×568 layouts, and 200% text scaling.

## Commands used

Run from `Project3` with dependencies already installed. The SDK used was
`/Users/abigailclose/Documents/Flutter SDK/flutter/bin/flutter`.
Use fresh log filenames for later runs to preserve this evidence.

```bash
flutter test test/services/checkout_help_service_test.dart \
  test/services/checkout_help_precision_test.dart \
  test/services/checkout_help_repository_test.dart test/m4_review \
  test/screens/checkout_help_screen_test.dart \
  --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/issue4_verification_2026-09-29/m4.txt

flutter test test/project1a/supreme_uc16-20_test.dart \
  test/project1a/satwi_uc11-15_test.dart \
  test/active/project1a_coverage_gaps_test.dart \
  --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/issue4_verification_2026-09-29/m0_team.txt

flutter test test/project1a/aditya_uc6-10_test.dart \
  --plain-name 'UC8 - Add product to basket' \
  --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/issue4_verification_2026-09-29/m0_allowance.txt

flutter test test/screens/qr_checkout_screen_test.dart \
  test/screens/basket_screen_test.dart \
  --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/issue4_verification_2026-09-29/m0_inherited.txt
```

## Failures and limitations

- No test failures or regressions occurred in this verification. The initial
  sandboxed launch stopped before tests because Flutter could not write its
  SDK cache outside the workspace; the approved invocation then passed.
- Earlier development failures and their fixes remain documented in the
  [historical service report](issue4_service_results_2026-09-27.md),
  [implementation report](implementation_results.md), and
  [frontend report](issue3_frontend.md). Historical statements about unfinished
  widgets are superseded by this verification.
- This run covers the required M4 and selected M0 suites, not the entire app.
  The September 27 full run recorded 278 passes and four failures involving
  signup profile-save errors, sign-out errors, blank-category alternatives,
  and rejected-alternative success messaging. Those failures were not rerun or
  resolved here; see the [full-run log](test_results/issue3_2026-09-27/full_suite_final.txt).
- Results describe the local working tree, not a committed clean checkout or
  GitHub Actions run. The existing M0 workflow does not select the M4 tests;
  the legacy Flutter workflow still targets Project2. CI remains pending.
- Evidence is synthetic and persistence uses fake Firestore with real AppState
  behavior. These tests establish the mock flow, not live benefit eligibility,
  real checkout responses, or user usefulness. Ordinary items without verified
  evidence receive fallback; live integration is outside the agreed mock scope.
- No physical-device, manual screen-reader, participant, or JavaScript/web
  target run was performed. VM numeric tests do not establish web integer
  precision beyond 2^53. Static analysis was not rerun in this verification.
