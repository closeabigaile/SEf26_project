# Checkout Help Test Review

> Historical results before the implementation fixes. See
> [current implementation and validation](implementation_results.md): the
> six M4 review failures are resolved and the basket interface is implemented.

Reviewed locally on 2026-09-27 on `M4_implementation_CHeckout_help`, based on
HEAD `76d50a2dd137afd11c9e8a4b24bd841640b8b641` and the existing uncommitted work.
**Production code and fixtures were not changed during this review.** The
earlier number-formatting fix was already present when this review began.

**Main finding:** the prepared service cases pass, but M4 is not yet a complete
basket feature in this checkout. There is no item-level help action or help
view. Focused review tests also expose decimal-comparison and evidence-validation
weaknesses. The new failing tests are intentionally left active, not skipped
or changed to accept the implementation's current answers.

## 1. Current implementation

Think of `CheckoutHelpService.explain` as a calculator. A caller supplies an
item record and a benefit record. The calculator checks whether those records
support one explanation and returns a `CheckoutHelpResult` containing a cause
label, explanation, and suggested next step.

The current flow is:

1. Read freshness and category fields. Reject malformed statuses and known
   category conflicts.
2. If either record explicitly says `outdated`, return the stale-information
   explanation only when the replacement-information flag is false.
3. Otherwise require current, covered, matching-category evidence, valid
   numeric values, comparable size units, the mock benefit unit, and zero
   allocation to the affected item.
4. Compare selected versus permitted size, and required versus available
   benefit units. Exactly one supported cause produces its message. Both
   causes, neither cause, or unusable evidence produce the fallback.
5. Return text. The service has no Firebase, Provider, navigation, or mutable
   application-state dependency.

No production caller currently supplies those records to the service. The
basket still offers quantity controls, nutrition expansion, checkout, and
clear-cart actions. The fixtures are loaded directly by tests, not by the app.

### Files involved and integration boundaries

| Responsibility | Files inspected | What exists now |
| --- | --- | --- |
| Logic and result model | [checkout_help_service.dart](../../Project3/lib/services/checkout_help_service.dart) | Both `CheckoutHelpService` and `CheckoutHelpResult` are in this file. There is no separate typed input model. Inputs are maps. |
| Prepared data and expected outputs | [checkout_help_scenarios.json](../../Project3/assets/mock/checkout_help_scenarios.json) | Three causes and the fallback; synthetic evidence only. |
| Basket frontend | [basket_screen.dart](../../Project3/lib/screens/basket_screen.dart) | Real basket widget; no help button, dialog, or service call. |
| Basket/balance storage | [app_state.dart](../../Project3/lib/state/app_state.dart) | Basket maps, allocations through category usage, persistence, checkout, and monthly reset. No checkout-help adapter. |
| Adjacent checkout UI | [qr_checkout_screen.dart](../../Project3/lib/screens/qr_checkout_screen.dart) | QR display and Finish Transaction; this is not the help view. |
| Routing and shared state | [app_router.dart](../../Project3/lib/app_router.dart), [main.dart](../../Project3/lib/main.dart) | Basket route and Provider wiring; no help route or service wiring. A future help dialog would not necessarily need its own route. |
| Product lookup/alternatives | [apl_service.dart](../../Project3/lib/services/apl_service.dart), [scan_screen.dart](../../Project3/lib/screens/scan_screen.dart) | Catalog and healthier alternatives; no checkout-help evidence adapter. |
| Assets/dependencies | [pubspec.yaml](../../Project3/pubspec.yaml) | Mock checkout-help JSON is not registered as an app asset. |
| Existing M4 unit tests | [checkout_help_service_test.dart](../../Project3/test/services/checkout_help_service_test.dart) | 102 tests; no existing M4 widget tests. |
| Existing M0 team baseline tests | [supreme_uc16-20_test.dart](../../Project3/test/project1a/supreme_uc16-20_test.dart), [satwi_uc11-15_test.dart](../../Project3/test/project1a/satwi_uc11-15_test.dart), [project1a_coverage_gaps_test.dart](../../Project3/test/active/project1a_coverage_gaps_test.dart), selected UC8 tests in [aditya_uc6-10_test.dart](../../Project3/test/project1a/aditya_uc6-10_test.dart) | 38 team tests plus 5 selected allowance tests. |
| Existing basket/QR widget baseline | [basket_screen_test.dart](../../Project3/test/screens/basket_screen_test.dart), [qr_checkout_screen_test.dart](../../Project3/test/screens/qr_checkout_screen_test.dart) | 7 tests for existing controls/rendering; not help interactions. |
| Shared requirements | [m4_checkout_help_use_cases.md](../M0/m4_checkout_help_use_cases.md), [m0_checkout_help_findings.md](../M0/m0_checkout_help_findings.md) | Scenarios, uncertainty, original-category requirement, and unchanged-state acceptance criteria. |
| M0 regression selection | [m0_baseline_checkout_results.md](../M0/m0_baseline_checkout_results.md) | Exact 50-test selection and its limitations. |
| M0 scoring code and tests | [evaluate_checkout_trials.py](../M0/evaluate_checkout_trials.py), [test_evaluate_checkout_trials.py](../M0/test_evaluate_checkout_trials.py) | Separate evaluation calculator and 13 tests. These do not call the M4 service. |
| M0 scoring examples | [passing_example.json](../M0/trial_data/passing_example.json), [failing_example.json](../M0/trial_data/failing_example.json) | Synthetic trial outcomes; a different schema from M4 evidence. |
| M0 scoring/results documentation | [m0_scoring_documentation.md](../M0/m0_scoring_documentation.md), [m0_evaluation_results.md](../M0/m0_evaluation_results.md) | Historical evaluation and scoring context, not proof of current M4 UI behavior. |
| M4 documentation | [README.md](README.md), [issue4_test_results.md](issue4_test_results.md) | Earlier service results and pending widget work. This review supplements those results. |
| CI | [m0-checkout-baseline.yml](../../.github/workflows/m0-checkout-baseline.yml), [m0-scoring.yml](../../.github/workflows/m0-scoring.yml), [flutter-ci.yml](../../.github/workflows/flutter-ci.yml) | M0 workflows select only their tests. The legacy full Flutter workflow still targets `Project2`, not `Project3`. No M4 CI success is established here. |

The broader run also included the remaining existing tests:
`test/project1a/abigail_uc1-5_test.dart`, `test/screens/login_screen_test.dart`,
`signup_page_test.dart`, `scan_screen_test.dart`, `balances_screen_test.dart`,
`test/state/app_state_test.dart`, and `test/services/apl_service_test.dart`.
Shared mocks are in `test/mocks/mocks.dart` and `mocks.mocks.dart`; the team-suite
selection is documented in `test/active/README.md`. Those paths are under
`Project3`. No existing tests or mocks were edited.

## 2. Existing test coverage

The existing 102 M4 tests already do a useful job protecting:

* Exact causes, explanations, and next steps for all four fixtures.
* Unknown versus explicitly outdated freshness, and conservative fallback
  for missing, invalid, or conflicting evidence.
* Original benefit category when the basket classification is `PAID`.
* Equal balances, zero balances, variable quantities, size differences,
  alternate categories, and numeric formatting, including the earlier overflow fix.
* Unchanged input maps, read-only nested maps, repeated calls, and independence
  between scenario results.

The gaps were more important than adding more permutations of null values:

* Decimal arithmetic was not tested near equality. Comparing exact binary
  floating-point values can create a diagnosis from a rounding artifact.
* Text validation checked types and emptiness, but not whether matching text
  actually identifies a category or measurement unit.
* No test proved that a shopper could reach help from a real basket item.
* The mock service data is richer than real basket records. Tests manually
  supply original categories, size rules, freshness, and available amounts;
  the app does not currently assemble or persist that evidence for M4.
* Exact fixture comparisons preserve wording even when wording is awkward.
  Passing those tests does not establish that the advice is understandable.
* Some existing tests encode conservative implementation choices, such as
  rejecting an existing allocation or any flagged replacement. These prove
  current behavior, not that the choices meet future real-data needs.

Existing inherited basket tests override some state mutation methods. The
inherited QR test only checks for a QR widget and supplies a replacement
checkout method that resets usage, unlike production. The stronger team
baseline exercises real checkout/persistence behavior, but none of these tests
opens checkout help. They cannot substitute for M4 interaction tests.

## 3. Weak points discovered

### Missing user-facing integration — blocks M4 acceptance

The real basket does not expose “Get checkout help.” A09 confirms this with
the actual widget and two basket items. It stops at that missing prerequisite;
there is no artificial test-only help dialog. Selected-item content, repeated
open/close, back navigation, and state preservation remain unverified.

### Exact decimal comparisons — numeric policy gap with reproducible failures

The service accepts decimal numbers but uses `!=` and `>` directly. For
example, `0.1 + 0.2` and `0.3` have slightly different binary representations.
A01 and A02 produce a mismatch and shortfall even though their intended decimal
amounts are equal. The original whole-unit fixtures are unaffected. These tests
propose an explicit precision rule for future computed evidence; the current
specification does not define that precision.

### Matching placeholders are accepted as usable evidence

Two `unknown` size-unit labels pass the unit comparison. Two `UNKNOWN`
category labels, or two `PAID` original-category labels with a contradictory
coverage flag, pass the category checks. A05–A07 show these combinations
producing size advice instead of the fallback. These are malformed imported
records, not official categories or real benefit rules.

### Real basket records are not ready to supply the service's evidence

The basket uses `upc`, `category`, and `qty`; the service expects
`original_benefit_category`, `quantity`, sizes, freshness, and benefit evidence.
Creating a `PAID` line copies name and nutrition but does not retain an original
benefit category on that line. `loadUserState` reconstructs a fixed field set
and would discard added evidence fields if they were merely attached to a
basket map. This is an integration risk found by inspection, not an implemented
adapter failure. Resolve the data ownership and mapping before testing reloads.

### Advice still contains implementation-oriented wording

The zero-balance suggestion says a substitution “should not be presented as
restoring coverage.” The stale suggestion says the text “does not assume
WolfBite already provides a refresh feature.” These explain requirements to
developers rather than giving direct instructions to a shopper. They match
the approved fixtures, so this is a usability recommendation, not a failing
contract test. Consider “Choosing another cereal will not restore your cereal
balance” and a direct instruction to verify current information. Any change
should update the shared expected messages deliberately.

### Other limits to keep explicit

The service only accepts `mock_benefit_unit`, zero affected-item allocation,
one permitted size, and matching measurement units. It cannot independently
verify item/benefit association or the truth of a `current` status. Those are
caller responsibilities not yet implemented. Scientific notation for extreme
values is numerically correct but may be confusing; no real-domain maximum
or display precision is specified. These limitations are not silently fixed
or disguised by a passing mock-data test.

## 4. Tests added or improved

Added two files under `Project3/test/m4_review`. Existing tests and production
behavior were left intact. Each new test has one purpose:

| Test | Situation and user problem protected against | Result |
| --- | --- | --- |
| A01 | Equivalent decimal package sizes computed differently; avoids recommending a needless package swap. | **Fail** |
| A02 | Required/available decimal amounts differ only by arithmetic rounding; avoids a false benefit shortfall. | **Fail** |
| A03 | A genuinely small positive balance, `0.001`, against one required unit; preserves the shortfall and avoids saying the balance is zero. | Pass |
| A04 | A real `18.01` versus `18` oz difference; prevents an overbroad rounding fix from erasing real mismatches. | Pass |
| A05 | Both size-unit labels are `unknown`; prevents matching placeholders from becoming a confident size comparison. | **Fail** |
| A06 | An adapter mistakenly uses payment classification `PAID` as the original benefit category; requires fallback for the contradiction. | **Fail** |
| A07 | Both categories are `UNKNOWN`; prevents an unclassified item from receiving size-based advice. | **Fail** |
| A08 | Several permitted-size records are supplied; prevents choosing the first and recommending a swap when that input shape is unsupported. | Pass |
| A09 | Real basket with two items; looks for the help action within the intended item's card, rather than accepting a global or other-item control. | **Fail: action absent** |

Sources: [A01–A08 service tests](../../Project3/test/m4_review/checkout_help_adversarial_test.dart)
and [A09 basket acceptance test](../../Project3/test/m4_review/checkout_help_basket_acceptance_test.dart).
No additional integration harness was invented: with the basket connection
absent, such a harness would test assumptions about future production code.

## 5. Edge cases tested

Across the existing and new suites, coverage includes missing/empty records,
nulls and invalid types, zero and exact-boundary balances, a small positive
balance, very large numbers, nonfinite/negative values, selected sizes above
and below the permitted size, decimal equality, competing causes, explicit
and unknown freshness, category conflicts, unclassified items, and fallback.
Input mutation and result independence are also checked at service level.

Actual multi-item help selection, changing basket quantities or benefit balances
while a help view is open, reopening help, dismissing by back/outside tap,
logging out during help, and resuming a saved basket cannot yet be exercised.
The presence of two rendered items in A09 does not establish any of those flows.

## 6. Test results

| Run | Passed | Failed | Notes |
| --- | ---: | ---: | --- |
| Existing M4 unit tests | 102 | 0 | Executed as part of the existing full suite. |
| New adversarial service tests | 3 | 5 | Deliberate reproductions remain failing. |
| New basket acceptance prerequisite | 0 | 1 | Real widget has no help entry point. |
| M0 checkout baseline | 50 | 0 | Same 38 + 5 + 7 selection, rerun separately. |
| M0 scoring tests | 13 | 0 | Tests the evaluation calculator, not user usefulness. |
| Broader existing Flutter suite | 241 | 4 | 245 existing tests; includes the 102 M4 tests and the baseline selections, excludes the 9 new tests. |

These rows overlap and should not be added together. The two disjoint Flutter
selections (245 existing + 9 new) produced **244 passes and 10 failures**.
No tests were skipped. The new test files passed Dart analysis. All recorded
results are local; GitHub Actions was not triggered or checked for these changes.

The scorer's passing example returned 80% M4 success and a 20-percentage-point
improvement. The failing example correctly returned 60% and zero improvement.
Its printed `FAIL` is the expected evaluation result, not a failing test run.
Both example commands exited successfully.

### Commands and logs

From `Project3`, using the existing installed dependencies:

```bash
flutter test test/m4_review --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/review_2026-09-27/adversarial_tests.txt

flutter test test/project1a test/active test/screens test/state \
  test/services/apl_service_test.dart test/services/checkout_help_service_test.dart \
  --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/review_2026-09-27/existing_full_suite.txt

flutter test test/project1a/supreme_uc16-20_test.dart test/project1a/satwi_uc11-15_test.dart \
  test/active/project1a_coverage_gaps_test.dart --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/review_2026-09-27/m0_team.txt

flutter test test/project1a/aditya_uc6-10_test.dart --plain-name 'UC8 - Add product to basket' \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/review_2026-09-27/m0_allowance.txt

flutter test test/screens/qr_checkout_screen_test.dart test/screens/basket_screen_test.dart \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/review_2026-09-27/m0_inherited.txt

dart analyze test/m4_review
```

From `Project2_Work/M0`:

```bash
python3 -m unittest -v test_evaluate_checkout_trials.py
python3 evaluate_checkout_trials.py trial_data/passing_example.json
python3 evaluate_checkout_trials.py trial_data/failing_example.json
```

Raw evidence: [new tests](test_results/review_2026-09-27/adversarial_tests.txt),
[existing suite](test_results/review_2026-09-27/existing_full_suite.txt),
[M0 team](test_results/review_2026-09-27/m0_team.txt),
[M0 allowance](test_results/review_2026-09-27/m0_allowance.txt),
[M0 inherited](test_results/review_2026-09-27/m0_inherited.txt),
[scoring tests](test_results/review_2026-09-27/m0_scoring_tests.txt),
[passing example](test_results/review_2026-09-27/m0_scoring_passing_example.txt),
[failing example](test_results/review_2026-09-27/m0_scoring_failing_example.txt),
and [analysis](test_results/review_2026-09-27/analysis.txt).
The 30-second per-test limit bounds potential hangs; no timeout caused a failure.

## 7. Failures / possible bugs

### New M4 failures

| Test | Expected versus actual | Likely cause and user impact | Smallest reasonable next step |
| --- | --- | --- | --- |
| A01 | Equal intended decimal sizes should not support a cause; actual result is `package_size_mismatch`. | Exact `!=` in the service treats a floating-point artifact as a different package. A shopper could be told to swap an already matching item. | Define supported size precision and normalize once at the input boundary, preferably to scaled integers/decimal values. Do not add an arbitrary broad tolerance. Retain A04. |
| A02 | Equal intended decimal amounts should not support a cause; actual result is `insufficient_category_balance`. | Exact `>` interprets arithmetic noise as insufficient coverage. A shopper could reduce covered quantity unnecessarily. | Decide whether mock benefit units must be whole counts. Reject unsupported fractions, or adopt defined decimal precision if fractional units are intended. Recheck genuinely small balances with A03. |
| A05 | Unknown units should return fallback; actual result is `package_size_mismatch`. | Nonempty equal strings are treated as compatible units. Advice can become “eligible 18 unknown package.” | Reject explicit unknown placeholders; define validated unit values at the evidence boundary. Unsupported conversions should continue to fall back. |
| A06 | `PAID` as an original benefit category should return fallback; actual result is `package_size_mismatch`. | Matching category strings plus `category_covered: true` bypass semantic validation. An adapter copying payment classification could generate unsupported advice. | Separate payment classification from original category and reject reserved classification values as category evidence. |
| A07 | Unclassified `UNKNOWN` records should return fallback; actual result is `package_size_mismatch`. | The service does not distinguish a category from a placeholder. Unclassified items can receive advice that assumes otherwise-eligible category coverage. | Normalize unknown-category placeholders to unavailable evidence and require a validated original category. |
| A09 | Intended item should offer “Get checkout help”; actual widget contains zero matching actions. | Basket integration is absent. Shoppers cannot reach any of the passing service behavior. | Implement Issue 3's per-item action and real help view, with an explicit evidence mapping, before expanding open/close assertions. |

A01/A02 and the placeholder cases are tests of reasonable robustness expectations
beyond the original four fixture inputs. They make precision and validation
assumptions visible; they do not establish new official benefit rules. No
production changes were made to force those expectations to pass.

### Existing broader-suite failures

These four failures occurred in the existing-suite run without the new review
tests. None of their failing paths calls `CheckoutHelpService`; they are existing
application issues observed during the review, not evidence that M4 changed
those paths.

| Existing test | Expected versus actual | Likely cause and user impact | Recommended smallest fix |
| --- | --- | --- | --- |
| `UC7-T6 blank category -> no search results` | Empty category should return no alternatives; actual result includes an eligible document whose category is empty. | `AplService.healthierSubstitutes` queries an empty string without rejecting it. An unclassified item can receive unrelated alternatives. | Return an empty list for a blank normalized category before querying. |
| `UC9-T2 rejected alternative -> must not report success` | A rejected addition should not display success; actual UI says “Added healthier item: Better cereal.” | The alternatives callback ignores the outcome of `AppState.addItem` and always shows success. A shopper may think the basket contains an item that was refused. | Make addition outcomes distinguish rejection from quantity increment, then show success only for an actual basket change. A simple boolean check alone is insufficient because `addItem` also returns false after incrementing an existing line. |
| `test_uc01_profile_save_failure_does_not_complete_registration_flow` | A profile-save error should be shown and registration should not complete; actual Firestore exception is uncaught and the expected snackbar is absent. | Signup catches `FirebaseAuthException`, not the separate Firestore failure. An account can exist without a saved profile or a clear recovery message. | Catch the profile-write error, show a recoverable failure, and avoid success navigation. Decide recovery for the partially created account explicitly. |
| `test_uc03_sign_out_failure_leaves_shopper_signed_in` | Failed sign-out should keep the session and show an error; actual network-related auth exception escapes the callback. | The scan screen awaits sign-out without a catch. A shopper gets no clear feedback on whether logout succeeded. | Catch the failure, keep the current route/session, and display a retryable error. |

Sources inspected for those causes: `apl_service.dart`'s healthier-alternative
query, `scan_screen.dart`'s add-alternative and logout callbacks, and
`signup_page.dart`'s exception handling. No unrelated fixes were made.

## 8. M4 acceptance confidence

**Strongly protected within the declared mock contract:** the three prepared
causes and fallback; full message pairs; uncertainty wording; original category
use on the prepared paid line; unchanged service input maps; and many malformed
or conflicting numeric inputs. The 50-test checkout baseline and 13 scoring
tests passed in this review.

**Needs a decision or fix:** decimal precision, explicit unknown unit/category
handling, original-category preservation and evidence mapping, and clearer
shopper-facing advice. The new failing tests make these weaknesses visible.

**Not verified:** item-specific opening, selected-item display, repeated
open/close, switching between items, edits or balance updates around help,
navigation/dismissal, state preservation through the real UI, and assurance
that viewing help never triggers checkout or monthly reset. The existing
service's lack of side effects is encouraging but does not prove a future UI
caller will be side-effect free.

After Issue 3, test all four scenarios through the real interface. Include two
items (also covered and paid lines sharing a UPC), change the selected item or
quantity between openings, dismiss through supported navigation paths, and
compare complete state snapshots while observing checkout/reset side effects.
Do not infer item identity from a list index that may change after removal.
If help reads a snapshot while balances change, define whether it refreshes or
clearly tells the shopper the information is no longer current.

**Recommendation: keep Issue #26 open.** Resolve or explicitly accept the
service robustness decisions, implement the basket connection, then complete
widget/state tests and CI verification. Real-data suitability and user
usefulness require additional evidence beyond these local automated tests.
