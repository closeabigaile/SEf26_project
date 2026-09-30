# M4 implementation fixes and local validation

> Follow-up: [Issue 3 frontend and demo guide](issue3_frontend.md) documents
> the shared help button, full sample-basket flow, and latest 139-test M4 results.
> The results below are preserved from the earlier implementation run.

Validated on 2026-09-27 on `M4_implementation_CHeckout_help`, including the
uncommitted working tree. **All 134 M4 tests pass.** The complete Flutter suite
passes 273 of 277 tests; the four failures are the same unrelated failures
recorded in the [earlier review](checkout_help_test_review.md). The existing
50-test M0 checkout selection passes as part of that full run.

## What changed

### Decimal comparisons

[CheckoutHelpService](../../Project3/lib/services/checkout_help_service.dart)
now compares floating-point evidence at **15 significant decimal digits**.
This is a documented input-precision policy: binary arithmetic noise such as
`0.1 + 0.2` no longer creates a false difference from `0.3`. Unlike a fixed
absolute tolerance, it does not erase tiny nonzero balances. Integer-to-integer
comparisons remain exact on the tested Dart VM, including counts above 2^53.
Displayed amounts use the same normalization without conversion to an integer.
Nonfinite values or normalization overflow produce fallback.

Differences beyond the 15-significant-digit policy are intentionally not
resolved. Tests also retain genuine small differences such as
`18.000000000001` versus `18`, and `2e-20` versus `1e-20`. This precision policy
is not an official benefit eligibility tolerance. A future provider with
specified decimal scales should supply exact, validated domain quantities.

### Evidence validation

Package units must be one of `oz`, `lb`, `g`, `kg`, `fl oz`, `ml`, `l`, or
`count`, ignoring case and surrounding/repeated whitespace. Unknown matching
labels no longer establish a usable measurement. Different units still use
fallback; no conversion is guessed.

Original categories such as `PAID`, `UNKNOWN`, `UNCLASSIFIED`, `UNSPECIFIED`,
`NONE`, `NULL`, and `N/A` cannot establish size or balance diagnoses. Legitimate
category names remain open-ended, but the category must match the benefit
record and that record must explicitly establish coverage. Explicitly outdated
information still produces uncertainty before any size or balance diagnosis.
The basket's `PAID` label remains valid when the separate original category
is known. New and reloaded basket records preserve that original category.
Old paid records without it remain unknown.

### Basket interface and evidence mapping

Each basket item now has **Get checkout help**. It opens a scrollable dialog
showing the selected name, quantity, payment category, possible cause or
uncertainty, explanation, and suggested next step. Close, back, and outside
tap return to the basket. Help does not reload, persist, clear, or check out
application state. It also does not apply the suggested action.

The dialog follows the selected map object, not a list index. If the item is
removed or basket/balance data changes while help loads or is open, the view
stops displaying the old diagnosis and asks the shopper to reopen help.
A loading failure produces a closable fallback. Repeated taps do not stack
multiple help dialogs. The existing nutrition label can now wrap on a narrow
screen instead of overflowing.

The [repository](../../Project3/lib/services/checkout_help_repository.dart)
loads the registered sample asset and passes only evidence to the service.
It never selects an answer from `expected_help`. A prepared basket line must
explicitly contain `checkout_help_source: synthetic` and a matching
`checkout_help_scenario_id`, UPC/item identity, quantity, basket category, and
original category. Matching a sample UPC alone is insufficient. Sample
explanations are labeled as synthetic, not live benefits.

Use the basket's flask icon (**Try sample checkout help**) to explore all four
prepared scenarios without adding sample items or changing balances. Ordinary
basket items can open help, but currently receive **Unable to determine the
cause**: no verified product/benefit evidence provider exists in this app yet.

Files implementing the flow:

- [basket_screen.dart](../../Project3/lib/screens/basket_screen.dart): per-item action and sample navigation.
- [checkout_help_dialog.dart](../../Project3/lib/widgets/checkout_help_dialog.dart): selected-item display, loading/error handling, invalidation, and closing.
- [checkout_help_samples_screen.dart](../../Project3/lib/screens/checkout_help_samples_screen.dart): isolated sample explorer.
- [checkout_help_repository.dart](../../Project3/lib/services/checkout_help_repository.dart): explicit evidence mapping and asset loading.
- [checkout_help_service.dart](../../Project3/lib/services/checkout_help_service.dart): validation, comparison policy, and explanations.
- [app_state.dart](../../Project3/lib/state/app_state.dart): retain original categories and explicit sample linkage across storage.
- [pubspec.yaml](../../Project3/pubspec.yaml): register the sample asset.

## Tests and results

| Selection | Passed | Failed | Evidence |
| --- | ---: | ---: | --- |
| Original service suite | 102 | 0 | [M4 final log](test_results/implementation_2026-09-27/m4_final.txt) |
| Existing adversarial review checks | 9 | 0 | Same M4 log; assertions retained |
| Additional precision/validation tests | 5 | 0 | Same M4 log |
| Repository tests | 2 | 0 | Same M4 log |
| Widget and application-state tests | 16 | 0 | Same M4 log |
| **M4 total** | **134** | **0** | |
| Complete Flutter suite, including M4 | 273 | 4 | [Full-suite log](test_results/implementation_2026-09-27/full_suite.txt) |
| M0 baseline selection within full suite | 50 | 0 | Same full-suite log; not additional tests |

The M0 selection is unchanged: UC16–20 (13), UC11–15 (14), coverage gaps (11),
selected UC8 (5), inherited QR (1), and inherited basket (6). Each named test
appears in the full-suite output without a failure. No M0 regression was observed.
The separate Python M0 scorer was unchanged; its earlier 13-test passing run
is recorded in the historical review and was not rerun for these app changes.

The new tests protect specific risks:

- [Precision tests](../../Project3/test/services/checkout_help_precision_test.dart): tiny genuine shortfalls, large exact integers, small real size differences, normalized placeholder categories, and unsupported measurement units.
- [Repository tests](../../Project3/test/services/checkout_help_repository_test.dart): immutable sample evidence and rejection of mismatched item identity, quantity, classification, source, or scenario.
- [Widget/state tests](../../Project3/test/screens/checkout_help_screen_test.dart): all four complete messages, selected-item identity, repeated switching, same-UPC collisions, missing evidence, stale state, removal, changed quantity, delayed or failed loads, all dismissal paths, isolated samples, small screens, and original-category persistence.

State tests use real `AppState` behavior with fake Firestore storage. They compare
basket/balances and stored documents before and after help. Instrumented methods
still call their real implementation. The saved document is deliberately dated
in a previous month after initial loading: an accidental help-triggered reload
would reset usage and fail these checks. Checkout, reload, and clear call counts
must remain zero.

Dart analysis reports no issues in the new checkout-help implementation and
new test files. The modified existing basket/state files retain five pre-existing
diagnostics: two unused nutrition imports, an unused QR-dialog method, deprecated
`withOpacity`, and a production `print`. Formatting checks changed no files.
Existing analyzer exclusions and baseline tests were retained.

## Failures encountered

All six M4 failures from the adversarial review now pass without weakening their
assertions. During implementation, widget tests exposed:

1. Cached asset futures crossing widget-test fake-clock environments. Clearing
   the root asset cache between tests fixed test isolation; production loading
   was not replaced with a stub.
2. The sample action was initially attached to an unused QR dialog. It was moved
   to the actual basket app bar.
3. The existing nutrition label overflowed at narrow width. Its text now wraps.
4. One intermediate invocation referenced a precision-test file before the
   file split had succeeded. That run had 23 passing tests and one file-load
   error. The split was completed and the final run uses the actual files.

Intermediate logs are preserved as [initial widget run](test_results/implementation_2026-09-27/widget_initial.txt),
[second widget run](test_results/implementation_2026-09-27/widget_second.txt),
and [test-file setup run](test_results/implementation_2026-09-27/widget_split_setup.txt).

The full-suite failures remain outside this change:

- **UC7-T6:** blank product category still returns healthier alternatives.
- **UC9-T2:** rejecting an alternative still reports success.
- **UC1 profile-save failure:** a Firestore error is not handled during signup.
- **UC3 sign-out failure:** the logout callback does not handle the failed sign-out.

Their details and proposed fixes remain in the earlier review. They were not
skipped or changed to make the full suite appear green.

## Reproduce locally

Run from `Project3` with dependencies already installed. These commands were
run using `/Users/abigailclose/Documents/Flutter SDK/flutter/bin/flutter`
and the adjacent `cache/dart-sdk/bin/dart`. Flutter used approved access to
its SDK cache outside the workspace. No dependencies were added.

```bash
flutter test test/services/checkout_help_service_test.dart \
  test/services/checkout_help_precision_test.dart \
  test/services/checkout_help_repository_test.dart test/m4_review \
  test/screens/checkout_help_screen_test.dart \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/implementation_2026-09-27/m4_final.txt

flutter test --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/implementation_2026-09-27/full_suite.txt

dart analyze lib/services/checkout_help_service.dart \
  lib/services/checkout_help_repository.dart lib/widgets/checkout_help_dialog.dart \
  lib/screens/checkout_help_samples_screen.dart \
  test/services/checkout_help_precision_test.dart \
  test/services/checkout_help_repository_test.dart \
  test/screens/checkout_help_screen_test.dart

dart analyze lib/screens/basket_screen.dart lib/state/app_state.dart
```

Use new log filenames on later runs to retain this evidence.

## Remaining limits

These results establish the local synthetic-evidence flow and unchanged state,
not live benefit eligibility. The service still uses `mock_benefit_unit`, handles
unallocated affected items, and requires an explicit freshness status. A real
provider must establish authoritative size rules, original classification,
whole-line required amounts, allocation-aware availability, units, and freshness
before ordinary items can receive supported diagnoses. Multiple permitted sizes,
unit conversions, and replacement-record reconciliation remain unsupported and
use fallback.

No retailer checkout response, physical device session, participant study, or
GitHub Actions run was performed for these changes. Integer precision beyond
2^53 was verified on the Dart VM, not a JavaScript/web target. Issue 5's CI
verification and real-data integration are still separate work. Nothing was
committed or pushed.
