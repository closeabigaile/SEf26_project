# Supreme's UC16–UC20 Test Results

**Author:** Supreme Constantine  
**Branch:** `tests/supreme-UC16-20`  
**Scope:** UC16–UC20  
**Product:** WolfBite  
**Execution date:** August 29, 2026  
**Command:** `flutter test test/project1a/supreme_uc16-20_test.dart`  
**Result:** 13 tests executed: 13 passed and 0 failed.

These tests were designed from the finalized UC16–UC20 use cases and compared with the existing WolfBite implementation and inherited tests. Existing tests were reviewed to avoid unnecessary duplication, particularly for the benefit-balance and QR checkout screens.

## UC16 — Decrease product quantity

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc16_decrease_covered_quantity_updates_quantity_and_usage` | Verify the main decrease-quantity behavior. | Quantity decreases by one and covered benefit usage decreases by one. | Passed. Quantity and usage both decreased correctly. |
| `test_uc16_quantity_reaching_zero_removes_selection` | Verify a selection is removed when its quantity reaches zero. | Product is removed from the basket and usage is reduced to zero. | Passed. Product was removed and usage became zero. |
| `test_uc16_paid_quantity_is_decreased_before_covered_quantity` | Verify shopper-paid units are removed before covered units when both exist. | PAID quantity/usage decreases first while covered quantity and usage remain unchanged. | Passed. PAID was removed first and covered usage remained unchanged. |
| `test_uc16_missing_product_causes_no_quantity_change` | Verify behavior when no matching product exists. | Basket quantities and benefit usage remain unchanged. | Passed. No quantity or usage changed. |
| `test_uc16_benefit_usage_does_not_go_below_zero` | Verify benefit usage cannot become negative. | Usage remains at zero even when a decrement would otherwise reduce it below zero. | Passed. Usage remained zero. |

## UC17 — Clear basket

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc17_clear_removes_all_products_and_reverses_usage` | Verify the main clear-basket behavior. | Basket becomes empty and provisional benefit usage is reversed. | Passed. Basket was cleared and usage was reversed. |
| `test_uc17_clear_reverses_usage_across_multiple_categories` | Verify clearing works across multiple benefit categories. | All products are removed and usage for each affected category is reversed. | Passed. Products were removed and category usage was reversed. |
| `test_uc17_missing_category_balance_still_removes_product` | Verify clearing a product whose category is absent from balances. | Product is removed without requiring a category balance update. | Passed. Product was removed and missing balance data caused no issue. |
| `test_uc17_clear_does_not_make_usage_negative` | Verify usage is clamped when recorded usage is smaller than removed quantity. | Basket is cleared and resulting usage is zero rather than negative. | Passed. Usage remained at zero. |

## UC18 — Review benefit balances

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc18_paid_category_is_displayed_as_unlimited` | Verify the PAID category is distinguished as unlimited. | PAID displays an Unlimited label and its used-item count. | Passed. PAID displayed as Unlimited with the correct usage text. |
| `test_uc18_usage_at_allowance_shows_full_progress` | Verify a limited category at its allowance displays full progress. | Usage text shows the full allowance and the progress indicator has a value of 1.0. | Passed. Usage text was correct and progress was full. |

Inherited `BalancesScreen` tests already cover the loading state, empty benefit data, limited benefit display, and generic unlimited-category display.

## UC19 — Prepare checkout handoff

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc19_qr_code_contains_current_basket_data` | Verify checkout presents a scannable QR representation. | A QR code is rendered for checkout. | Passed. A `QrImageView` was displayed. |

The production checkout screen constructs the QR input by JSON-encoding the current basket. The installed `qr_flutter` version does not expose the encoded data through a public `QrImageView.data` getter, so the widget test verifies that the QR representation is rendered rather than directly reading its encoded payload.

## UC20 — Finish shopping session

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc20_checkout_clears_basket_but_retains_benefit_usage` | Verify completed checkout clears selections without reversing consumed benefits. | Basket becomes empty while recorded benefit usage remains unchanged. | Passed. Basket was cleared and benefit usage was retained. |

## Summary

All 13 team-authored UC16–UC20 tests passed against the current WolfBite implementation.

The tests verify quantity reduction, clear-basket behavior, benefit-balance presentation, checkout handoff presentation, and completion of the shopping session. Existing inherited tests were also reviewed so that new tests focused on use-case requirements that were not already adequately covered.