# D4 — Supreme's UC16–UC20 Traceability and Inherited-Test Assessment

**Author:** Supreme Constantine  
**Branch:** `tests/supreme-UC16-20`  
**Scope:** UC16–UC20  
**Product:** WolfBite  
**Team-authored test file:** `Project3/test/project1a/supreme_uc16-20_test.dart`  
**Execution evidence:** `Project1a_Work/raw_test_output/supreme_uc16_uc20_2026-08-29.txt`

The tests below were designed from the finalized UC16–UC20 use cases and then compared with the inherited WolfBite tests. The mappings describe behavior demonstrated by an assertion or implementation inspection rather than assuming coverage from test or file names alone.

## Team-authored test-to-use-case traceability

| Test | Use case(s) | What it proves |
|---|---|---|
| `test_uc16_decrease_covered_quantity_updates_quantity_and_usage` | UC16, main scenario | Decreasing a covered product removes one unit and decreases its recorded benefit usage by one. |
| `test_uc16_quantity_reaching_zero_removes_selection` | UC16, main scenario | When the selected quantity reaches zero, the product is removed from the basket and associated usage is reduced. |
| `test_uc16_paid_quantity_is_decreased_before_covered_quantity` | UC16, extension 1a | When covered and shopper-paid quantities both exist, the shopper-paid quantity is decreased first. |
| `test_uc16_missing_product_causes_no_quantity_change` | UC16, extension 1c | Requesting a decrease for a product that is not in the basket causes no quantity change. |
| `test_uc16_benefit_usage_does_not_go_below_zero` | UC16, extension 3a | Benefit usage remains at zero rather than becoming negative when recorded usage is already zero. |
| `test_uc17_clear_removes_all_products_and_reverses_usage` | UC17, main scenario | Clearing the basket removes its products and reverses provisional benefit usage. |
| `test_uc17_clear_reverses_usage_across_multiple_categories` | UC17, main scenario | Clearing multiple products reverses usage for each applicable benefit category. |
| `test_uc17_missing_category_balance_still_removes_product` | UC17, extension 4a | A product is still removed when its category is absent from the balance map, without modifying a nonexistent category total. |
| `test_uc17_clear_does_not_make_usage_negative` | UC17, extension 4b | If recorded usage is smaller than the quantity being removed, resulting usage is clamped to zero. |
| `test_uc18_paid_category_is_displayed_as_unlimited` | UC18, extension 2a | The PAID category is displayed as unlimited and shows its current used-item count. |
| `test_uc18_usage_at_allowance_shows_full_progress` | UC18, extension 2b | When usage reaches the allowance, the limited-category progress indicator displays full progress. |
| `test_uc19_qr_code_contains_current_basket_data` | UC19, main scenario | The checkout screen presents a QR-code widget as the scannable checkout handoff. Production inspection shows its input is the JSON-encoded current basket. |
| `test_uc20_checkout_clears_basket_but_retains_benefit_usage` | UC20, main scenario | Finishing checkout clears the basket while retaining recorded benefit usage. |

## Inherited-test assessment

### UC16 — Decrease product quantity

The inherited `AppState` tests include basic `decrementItem` coverage for decreasing a quantity and removing a product when quantity reaches zero.

The UC16 team-authored tests extend that coverage by checking the finalized use-case requirements for shopper-paid-first removal, a missing matching product, and nonnegative benefit usage.

### UC17 — Clear basket

The production `clearBasket()` implementation removes basket selections and subtracts their provisional quantities from applicable balance usage while clamping usage at zero.

The team-authored tests verify multiple-category clearing, absent balance categories, and the nonnegative-usage requirement.

The basket UI also presents a confirmation dialog. Its Cancel action closes the dialog without calling `clearBasket()`, while Clear All calls `clearBasket()` and then closes the dialog. This supports UC17 extension 2a through implementation inspection.

### UC18 — Review benefit balances

Inherited `BalancesScreen` tests already verify:

- a loading indicator while balances are not loaded;
- an empty state when loaded balances contain no categories;
- display of a limited category with used and allowed values; and
- display of a generic unlimited category.

The team-authored tests therefore focus on additional finalized UC18 behavior: PAID being shown as unlimited and a limited category at its allowance displaying full progress.

### UC19 — Prepare checkout handoff

The inherited `QRCheckoutScreen` test verifies that a `QrImageView` is rendered when the basket contains a product.

Production inspection shows that `QRCheckoutScreen` JSON-encodes `appState.basket` and supplies that value to the QR widget. The installed `qr_flutter` version does not expose the encoded value through a public `QrImageView.data` getter, so the team-authored widget test verifies QR presentation while the basket-to-QR mapping is supported by implementation inspection.

The finalized UC19 extensions concerning an unusable QR code or cashier interoperability are not directly exercised by the current automated test because they depend on external scanning/cashier behavior outside the app's test boundary.

### UC20 — Finish shopping session

The production `AppState.checkout()` clears the basket and persists the new state without resetting benefit usage. The team-authored UC20 test verifies this distinction directly.

The inherited `QRCheckoutScreen` test uses a custom `TestAppState.checkout()` implementation that resets every balance's `used` value to zero before clearing the basket. This differs from the real production `checkout()` implementation and conflicts with UC20's requirement that recorded benefit usage be retained.

Therefore, the inherited checkout test should not be treated as evidence that UC20's benefit-retention requirement is satisfied. The team-authored test exercises the real `AppState.checkout()` behavior instead.

## Assessment summary

The inherited WolfBite suite provides useful baseline coverage for several UC16–UC20 behaviors, especially basic quantity changes, balance-screen states, and QR rendering. However, it does not fully cover the finalized use-case requirements.

The 13 team-authored tests add coverage for important UC16–UC20 behaviors and edge cases. All 13 passed against the current implementation. Review of the inherited checkout test also identified a test-double behavior that differs from production behavior, demonstrating why inherited tests were assessed rather than assumed to represent the finalized use cases.