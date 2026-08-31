# D4 — Satwi's UC11–UC15 Traceability and Inherited-Test Assessment

**Author:** Satwi
**Branch:** `tests/satwi-UC11-15`
**Scope:** UC11–UC15
**Product:** WolfBite
**Team-authored test file:** `Project3/test/project1a/satwi_uc11-15_test.dart`
**Execution evidence:** `Project1a_Work/raw_test_output/satwi_uc11_uc15_2026-08-30.txt`

The tests below were designed from the finalized use cases before assessing
the inherited WolfBite tests. All mappings describe behavior proved by an
assertion or mock verification; they do not infer coverage merely from a
test or file name.

## Team-authored test-to-use-case traceability

| Test | Use case(s) | What it proves |
|---|---|---|
| `test_uc11_multiple_recognized_products_are_each_added` | UC11 | Distinct recognized products are each added as new basket lines with corresponding category usage increases. |
| `test_uc11_duplicate_recognized_upc_increments_but_addition_count_is_undercounted` | UC11, extension 2a | A duplicate recognized UPC increments the existing line's quantity, but the caller-visible Boolean result understates the change, matching the use case's documented risk. |
| `test_uc11_product_at_category_cap_is_rejected_not_added_as_paid` | UC11, extension 2b | A product whose category is already at its cap is rejected outright rather than silently converted to a shopper-paid line. |
| `test_uc11_product_without_nutrition_uses_zero_defaults` | UC11, extension 1a | A product lacking nutrition values is still added, with zero-valued nutrition substituted. |
| `test_uc12_basket_displays_items_quantities_and_categories` | UC12 | The basket presents each selected product's name and category alongside a running total. |
| `test_uc12_empty_basket_shows_empty_state` | UC12, extension 1a | An empty basket explains its state and offers to begin product identification instead of appearing blank. |
| `test_uc12_covered_and_paid_lines_for_same_upc_display_separately` | UC12, extension 1c | A product with both covered and shopper-paid quantities is presented as two separate selections rather than merged. |
| `test_uc13_expanding_item_shows_nutrition_facts` | UC13 | Requesting detailed nutrition for a basket product reveals its stored calorie, fat, and sodium values. |
| `test_uc13_missing_nutrition_map_shows_zero_defaults` | UC13, extension 2a | A basket product with no stored nutrition information displays zero defaults instead of failing. |
| `test_uc13_collapsing_hides_nutrition_facts` | UC13, extension 4a | The shopper can return to the basket summary, collapsing the nutrition detail view. |
| `test_uc14_increase_button_calls_increment_when_under_cap` | UC14 | Requesting another unit under an available allowance invokes the real quantity-increase state method. |
| `test_uc14_increase_button_still_active_at_cap_and_reports_paid_intent` | UC14, extension 1a | An exhausted allowance does not block the increase control; instead its tooltip signals the shopper-paid path continued in UC15, and the same state method is still invoked. |
| `test_uc15_increment_at_cap_creates_separate_paid_line` | UC15 | An additional unit requested after WIC coverage is exhausted is represented as a distinct shopper-paid line, leaving covered usage unchanged. |
| `test_uc15_second_paid_request_increments_existing_paid_line` | UC15, extension 2a | A repeated shopper-paid request for the same product increases the existing paid line instead of duplicating it. |
| `test_uc15_paid_category_has_no_allowance_cap_confirming_unlimited_display` | UC15, extension 4a | The shopper-paid category is derived as uncapped, confirming the root cause of its "unlimited" appearance on the benefits screen despite not being a real WIC benefit. |

## Bidirectional coverage check

### Use cases to tests

| Assigned use case | Team-authored tests | Use-case-level status |
|---|---:|---|
| UC11 — Add receipt products | 4 | Covered at the state level; widget-level testing is blocked by a missing injection seam in `ReceiptScannerScreen` (documented below). |
| UC12 — Review basket | 3 | Covered; happy path, empty state, and covered/paid separation are exercised. |
| UC13 — Review basket-product nutrition | 3 | Covered; happy path, missing data, and collapse behavior are exercised. |
| UC14 — Increase product quantity | 2 | Covered; under-cap and at-cap paths are exercised. |
| UC15 — Add shopper-paid quantity | 3 | Covered; creation, duplicate-request, and the unlimited-display root cause are exercised. |

All five assigned use cases have direct executable evidence. "Covered" here
means each use case has one or more tests; it does not claim that every
possible input or extension has been exhausted.

### Tests to use cases

All 15 tests map directly to UC11–UC15. There are **no orphan
team-authored tests** in this assigned subset.

### Remaining requirement-level opportunities

- UC11: a true end-to-end test through `ReceiptScannerScreen` itself,
  blocked by its lack of dependency injection for `AplService` and its
  live network call to `api.ocr.space`.
- UC12: a basket containing more than a handful of items, to check
  scrolling/layout behavior at scale.
- UC13: a basket product with a partially populated nutrition map (some
  fields present, others absent), rather than fully present or fully
  absent.
- UC14: the case where the matching covered product cannot be found at
  all (extension 2a), which requires seeding a mismatched UPC/category.
- UC15: the case where the original covered product cannot be found when
  creating a shopper-paid line (extension 2b).

These are acknowledged extensions, not orphaned use cases.

## Assessment of the inherited WolfBite tests

Per `Project1a_Work/baseline.md`, the state, basket, scan, QR checkout, and
APL service inherited test files did not compile in the as-is baseline run,
due to a `cloud_firestore`/`fake_cloud_firestore` `WriteBatch.update`
interface mismatch. Since UC11–UC15 depend almost entirely on
`state/app_state.dart` and `screens/basket_screen.dart`, both of which fall
inside the non-compiling set, there is **no executable inherited-test
evidence available for this assigned subset.**

| Use case | Inherited test evidence | Verdict | Important blind spots |
|---|---|---|---|
| UC11 — Add receipt products | No dedicated receipt-scanner test file exists in the inherited suite at all. | **No source or executable coverage** | The inherited suite does not address duplicate-UPC undercounting, category-cap rejection, or missing-nutrition defaults for receipt-recognized products. |
| UC12 — Review basket | `screens/basket_screen_test.dart` (if present) falls within the baseline's non-compiling set. | **No executable baseline evidence** | Empty-state display and covered/paid line separation are not verifiable from the current inherited suite. |
| UC13 — Review basket-product nutrition | Same file as UC12; non-compiling. | **No executable baseline evidence** | Missing-nutrition zero-default behavior is not verifiable. |
| UC14 — Increase product quantity | `state/app_state_test.dart` falls within the baseline's non-compiling set. | **No executable baseline evidence** | The at-cap-continues-to-paid path is not verifiable from the inherited suite. |
| UC15 — Add shopper-paid quantity | Same file as UC14; non-compiling. | **No executable baseline evidence** | The uncapped PAID category's role in the "unlimited" display quirk is not verifiable from the inherited suite. |

## Inherited-suite execution limitation

This finding is consistent with Abigail's baseline report: the as-is
`flutter test` run failed overall because of a `cloud_firestore` version
resolved against an incompatible `fake_cloud_firestore` release. Since all
five of this assignment's use cases depend on `AppState` or `BasketScreen`,
none of the relevant inherited test intent could be confirmed as
executable evidence. This is dependency/code-rot evidence, reported rather
than repaired, consistent with the Project 1a ground rules.

## Overall inherited-test judgment for UC11–UC15

Unlike UC1–UC5, where some inherited tests at least reached passing
results before the suite's compilation failures, **UC11–UC15's relevant
inherited test files fall entirely within the non-compiling set.** The
Project 1a tests in this submission are therefore the only current
executable evidence for these five use cases. They additionally surface
one testability limitation not present in UC1–UC5: `ReceiptScannerScreen`
cannot be exercised offline at the widget level due to its lack of a
dependency-injection seam for `AplService`, a structural gap the inherited
suite does not address either.