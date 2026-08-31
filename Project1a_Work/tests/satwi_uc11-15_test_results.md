# Satwi's UC11–UC15 Test Results

**Author:** Satwi
**Branch:** `tests/satwi-UC11-15`
**Scope:** UC11–UC15
**Product:** WolfBite
**Execution date:** August 30, 2026
**Command:** `flutter test test/project1a/satwi_uc11-15_test.dart --reporter expanded`
**Result:** 15 tests executed: 15 passed, 0 failed.

These tests were designed from the finalized use cases before assessing the
project's inherited tests. UC11 is tested at the `AppState` level rather than
through the widget layer because `ReceiptScannerScreen` hard-codes
`AplService()` internally and makes live network calls to `api.ocr.space`
with no constructor injection point, so it cannot be exercised offline the
way `ScanScreen` could. This is a testability finding, not a gap in effort.

## UC11 — Add receipt products

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc11_multiple_recognized_products_are_each_added` | UC11 main scenario requires each recognized product to be evaluated and added to the basket | Each distinct product is added as a new line and its category usage increases | **PASS** — both products were added as new lines and both categories' used counts increased by one. |
| `test_uc11_duplicate_recognized_upc_increments_but_addition_count_is_undercounted` | UC11 extension 2a says a product already in the basket increases its quantity, but the reported addition count omits that increase | The second addition increments quantity but `addItem` returns `false` for that path | **PASS** — the first call returned `true`, the second returned `false`, and the single basket line's quantity was 2, confirming the undercount risk described in the use case. |
| `test_uc11_product_at_category_cap_is_rejected_not_added_as_paid` | UC11 extension 2b says a product whose category is at its cap is rejected rather than added as shopper-paid | The product is not added and covered usage is unchanged | **PASS** — the product did not appear in the basket and used count remained unchanged. |
| `test_uc11_product_without_nutrition_uses_zero_defaults` | UC11 extension 1a says a product lacking nutrition values receives zero-valued defaults | The product is added successfully with zero-valued nutrition fields | **PASS** — the product was added and its nutrition map defaulted calories and protein to `0.0`. |

## UC12 — Review basket

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc12_basket_displays_items_quantities_and_categories` | UC12 main scenario requires each product's name, quantity, and category to be presented | Both products' names and categories appear along with a total-items summary | **PASS** — both product names and categories appeared, along with the "Total Items:" label. |
| `test_uc12_empty_basket_shows_empty_state` | UC12 extension 1a says an empty basket must explain its state rather than appear blank | An empty-basket message and a way to begin scanning are shown | **PASS** — "Your basket is empty" and "Start Scanning" both appeared. |
| `test_uc12_covered_and_paid_lines_for_same_upc_display_separately` | UC12 extension 1c says a product with covered and shopper-paid quantities must be presented as separate selections | The same product name appears twice, once under each category | **PASS** — "Whole Milk" appeared twice, once for MILK and once for PAID. |

## UC13 — Review basket-product nutrition

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc13_expanding_item_shows_nutrition_facts` | UC13 main scenario requires calories, fat, sodium, sugar, and protein to be presented on request | Expanding the item reveals its stored nutrition values | **PASS** — the nutrition panel appeared with the exact stored calorie, fat, and sodium values. |
| `test_uc13_missing_nutrition_map_shows_zero_defaults` | UC13 extension 2a says a product with no stored nutrition information displays zero defaults | Zero-valued nutrition fields appear instead of a crash or missing section | **PASS** — the expanded panel showed `0.0 cal` and `0.0mg` defaults. |
| `test_uc13_collapsing_hides_nutrition_facts` | UC13 extension 4a says a shopper may return to the basket summary after viewing details | The nutrition panel closes and the summary control returns to its collapsed label | **PASS** — after collapsing, "Nutrition Facts" was no longer present and "Show Nutritional Info" reappeared. |

## UC14 — Increase product quantity

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc14_increase_button_calls_increment_when_under_cap` | UC14 main scenario requires a quantity increase to call the real state update when allowance is available | Pressing the increase control invokes `incrementItem` for the correct product and category | **PASS** — `incrementItem('1', 'MILK')` was called exactly once. |
| `test_uc14_increase_button_still_active_at_cap_and_reports_paid_intent` | UC14 extension 1a says an exhausted allowance continues into UC15 rather than blocking the action | The increase control remains enabled, its tooltip signals shopper-paid intent, and the real state method is still invoked | **PASS** — the control's tooltip read "Will add as paid" and `incrementItem` was still called once, confirming the UI does not distinguish the cap boundary before delegating to state. |

## UC15 — Add shopper-paid quantity

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc15_increment_at_cap_creates_separate_paid_line` | UC15 main scenario requires an additional unit at a full category to be represented as a distinct shopper-paid line | A new PAID line is created and covered usage is unchanged | **PASS** — one PAID line with quantity 1 was created and MILK's used count remained 3. |
| `test_uc15_second_paid_request_increments_existing_paid_line` | UC15 extension 2a says a repeated shopper-paid request increases the existing paid line rather than duplicating it | Only one PAID line exists after two shopper-paid requests, with quantity 2 | **PASS** — exactly one PAID line existed with quantity 2 after two increments. |
| `test_uc15_paid_category_has_no_allowance_cap_confirming_unlimited_display` | UC15 extension 4a says the shopper-paid category appears as unlimited on the benefits screen even though it is not a real WIC benefit | The PAID category's `allowed` value is `null`, the underlying cause of the unlimited display | **PASS** — `balances['PAID']['allowed']` was `null` after a shopper-paid increment. |

## Findings summary

- No inherited implementation mismatches were found in UC11–UC15 (unlike
  UC1 and UC3, where Abigail's suite exposed uncaught exceptions).
- **UC11 testability limitation:** `ReceiptScannerScreen` cannot be tested
  at the widget level offline, since it hard-codes `AplService()` and calls
  a live OCR API with no injection seam. This mirrors the "receipt scanner"
  fragility Codex flagged in the model comparison phase (frequent recent
  changes, external dependency, no test seam).
- **UC11 extension 2a confirmed:** `addItem`'s Boolean return value
  undercounts additions when a recognized product already exists in the
  basket, exactly as the finalized use case predicted.
- **UC15 extension 4a confirmed:** the PAID category has no `allowed` cap
  by design, which is the root cause of it displaying as "unlimited" on the
  benefits screen despite not being an actual WIC benefit.