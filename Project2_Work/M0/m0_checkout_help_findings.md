# M0 Checkout-Help Findings

## 1. Purpose

M0 evaluates whether checkout help improves a shopper's ability to identify the expected next step after an item is rejected. M4 will build checkout help. Both milestones need the same scenarios, example records, and expected next steps.

This document records the current code findings and proposes shared scenarios for M4 review. It does not report completed evaluation results or agreement from M4. Participant testing was not conducted, and user usefulness remains unverified.

The application currently lives in `Project3`, despite this being the Project 2 assignment. This document lives in `Project2_Work/M0`, following the repository's earlier assignment-documentation folders. File links below are relative to this document.

## 2. Current Checkout Flow

1. **Look up a product.** In [scan_screen.dart](../../Project3/lib/screens/scan_screen.dart), `ScanScreen` is the scanning page. Its `_checkEligibility` function asks `AplService.findByUpc` to find the barcode in the Approved Product List (APL), a product collection stored in Firestore. A missing record produces “UPC … not found in APL.”
2. **Check the category allowance before adding.** The scanning page asks `AppState.canAdd` whether the category has room. If the category is full, the page displays “Category limit reached” and disables its Add button. This is an item-count check, not a complete checkout eligibility decision.
3. **Keep track of the basket.** In [app_state.dart](../../Project3/lib/state/app_state.dart), `AppState` holds the basket and benefit counts. `addItem` adds a product and increases category usage. A new product is refused when its category is full. Increasing an existing product through `incrementItem` can instead create a separate `PAID` basket line when coverage is exhausted.
4. **Review items.** In [basket_screen.dart](../../Project3/lib/screens/basket_screen.dart), `BasketScreen` shows items, quantities, categories, and nutrition badges. The plus button remains available at the limit, with the tooltip “Will add as paid.” There is no checkout-help button.
5. **Prepare checkout.** “Ready to Checkout” opens `QRCheckoutScreen` in [qr_checkout_screen.dart](../../Project3/lib/screens/qr_checkout_screen.dart). It turns the current basket into JSON, a text representation of the item data, and displays it as a QR code.
6. **Finish the session.** “Finish Transaction” calls `AppState.checkout`, which clears the basket and saves state. Category usage remains recorded. The screen displays “Transaction Complete! Balances updated.” and returns to scanning. It does not receive a cashier approval or an item-level rejection response.

`BasketScreen` also contains `_showQRDialog`, an older-looking handoff dialog function. The active checkout button opens `QRCheckoutScreen`; no call to `_showQRDialog` was found.

## 3. What Happens Today When an Item Is Rejected

**WolfBite does not currently receive or display an official checkout rejection reason.** The current app has these related behaviors:

* An unknown barcode produces a “not found in APL” message and clears the current product result.
* A full category produces “Category limit reached” and a disabled Add button on the scanning page.
* Increasing an existing basket item beyond its category allowance can add a shopper-paid line instead of blocking the increase.
* A product's eligibility field can produce a “WIC Eligible” badge. The badge is not confirmation that checkout will accept the item.
* Lookup errors produce an error message. A failed checkout save can throw an exception after the local basket has already been cleared; this is a save failure, not a product rejection.

There is no basket-item explanation identifying a possible package-size mismatch, balance shortfall, or stale-information problem. There is no corresponding checkout-help next step. Healthier alternatives exist, but they are nutrition suggestions, not verified solutions to a rejected item.

The existing count checks can detect a full category. They cannot distinguish all three proposed checkout-help causes.

## 4. Existing Code and Data We Can Reuse

### Basket logic and item records

**File:** [app_state.dart](../../Project3/lib/state/app_state.dart)

**What it does:** `AppState.basket` is a list of maps: named values such as `upc`, `name`, `category`, `qty`, and `nutrition`. There is no separate typed item model in this flow. `addItem`, `incrementItem`, and `decrementItem` manage items. `loadUserState` restores saved items.

**Why it matters for M0/M4:** This is the basket that opening and closing help must preserve. Its creation and restoration paths do not retain structured package-size restrictions, a rejection reason, or product freshness evidence. A paid line uses `PAID` as its category, so that line alone does not identify the original benefit category.

### Benefit records

**File:** [app_state.dart](../../Project3/lib/state/app_state.dart)

**What it does:** `AppState.balances` stores `allowed` and `used` item counts for each category. `_deriveAllowed` supplies default limits. A null allowance means uncapped. Usage increases while building the basket and remains after checkout.

**Why it matters for M0/M4:** The counts provide a starting point for mock balance scenarios. They are not demonstrated live benefit-account balances. M0 and M4 must agree how basket allocations affect the remaining amount for the affected item.

### Product lookup and eligibility metadata

**File:** [apl_service.dart](../../Project3/lib/services/apl_service.dart)

**What it does:** `AplService.findByUpc` reads a product record from Firestore. `substitutes` filters for eligible products in the same category. `healthierSubstitutes` ranks alternatives using nutrition information.

**Why it matters for M0/M4:** Product identity and category can connect a basket item to mock evidence. Lookup success does not establish why checkout rejected an item, and healthier suggestions do not establish package-size or balance compatibility.

### Imported product data and timestamps

**File:** [import.js](../../Project3/scripts/import.js)

**What it does:** `normalizeRecord` imports product name, category, `eligible: true`, and an `updatedAt` import timestamp. It does not import structured package-size rules.

**Why it matters for M0/M4:** Existing imported fields are insufficient for the size scenario. An import timestamp says when a record was imported, not necessarily when the underlying information was verified.

**File:** [app_state.dart](../../Project3/lib/state/app_state.dart)

**What it does:** `_persist` writes a user-state timestamp. `_isNewMonth` and `_resetMonthlyUsage` use the saved timestamp to reset usage and clear the basket across calendar months.

**Why it matters for M0/M4:** This monthly reset is not stale-information checkout help. M4 needs an agreed freshness rule for its mock evidence. Help must not trigger a basket-clearing reset.

### Existing warnings and status displays

**Files:** [scan_screen.dart](../../Project3/lib/screens/scan_screen.dart), [basket_screen.dart](../../Project3/lib/screens/basket_screen.dart), [balances_screen.dart](../../Project3/lib/screens/balances_screen.dart), and [nutritional_utils.dart](../../Project3/lib/utils/nutritional_utils.dart)

**What they do:** `ScanScreen` displays lookup errors and category-limit warnings. `_BasketItemState.build` draws a basket row and its paid-overflow tooltip. `_BalanceCard.build` shows used/allowed counts or “Unlimited.” `NutritionalUtils.getBadges` can supply a “WIC Eligible” badge.

**Why they matter for M0/M4:** These are the existing signals in the baseline flow. They do not provide the proposed explanation-and-next-step interaction. `PAID` is also displayed as uncapped; this must not be interpreted as an unlimited benefit.

### Mock records and allowance tests

**Files:** [aditya_uc6-10_test.dart](../../Project3/test/project1a/aditya_uc6-10_test.dart), [satwi_uc11-15_test.dart](../../Project3/test/project1a/satwi_uc11-15_test.dart), and [apl_service_test.dart](../../Project3/test/services/apl_service_test.dart)

**What they do:** These tests construct sample product, basket, and benefit maps using fake or mocked dependencies instead of a live account. `UC8-T2 exhausted allowance -> unchanged basket and usage` checks a refused new item. `test_uc15_increment_at_cap_creates_separate_paid_line` checks overflow. `substitutes returns eligible products in the same category` checks eligibility filtering.

**Why they matter for M0/M4:** Their setup patterns can support future shared fixtures—fixed sample records used by tests. They do not yet supply the three agreed checkout-help scenarios or enough structured size/freshness evidence.

### Checkout tests

**Files:** [supreme_uc16-20_test.dart](../../Project3/test/project1a/supreme_uc16-20_test.dart), [project1a_coverage_gaps_test.dart](../../Project3/test/active/project1a_coverage_gaps_test.dart), and [qr_checkout_screen_test.dart](../../Project3/test/screens/qr_checkout_screen_test.dart)

**What they do:** `test_uc20_checkout_clears_basket_but_retains_benefit_usage` checks the checkout state change. The coverage-gap tests check that the empty basket is saved and that a save failure leaves the local basket cleared. QR rendering tests check that a QR widget exists.

**Why they matter for M0/M4:** They provide baseline checkout checks. The QR tests do not compare the encoded contents with the basket, despite their names. The inherited `TestAppState.checkout` test replacement resets usage, unlike production checkout; it should not define expected benefit behavior. None of these tests verifies checkout help.

### Basket, scan, and session tests

**Files:** [satwi_uc11-15_test.dart](../../Project3/test/project1a/satwi_uc11-15_test.dart), [basket_screen_test.dart](../../Project3/test/screens/basket_screen_test.dart), [scan_screen_test.dart](../../Project3/test/screens/scan_screen_test.dart), and [abigail_uc1-5_test.dart](../../Project3/test/project1a/abigail_uc1-5_test.dart)

**What they do:** UC12 checks basket display. UC14 checks quantity controls and the “Will add as paid” tooltip. The inherited basket tests cover rendering and quantity changes. `disables "Add" button when category limit is reached` checks the scan warning. `test_uc05_unknown_upc_reports_not_found_and_clears_result` checks an unknown product. UC4 covers a previous-month session reset.

**Why they matter for M0/M4:** They describe existing behavior that should remain understandable after help is added. Monthly reset and clearing an old scan result are not tests of stale-information checkout explanations. These tests were inspected, not run for this documentation task.

## 5. Gap Between Current Behavior and M4

| Current WolfBite | Desired M4 behavior |
| --- | --- |
| No official item rejection response or basket help action | A shopper can open help for an affected basket item using an agreed mock rejection/unsupported scenario. |
| No structured package-size comparison | Show the item's size and the mock permitted size as a possible mismatch. |
| Count limits, warnings, and paid overflow | Explain a possible category shortfall using the amount required and the amount available for the affected item. |
| Timestamps without a checkout freshness rule | Explain uncertainty when mock information is known to be outdated. |
| No checkout-help fallback | Say “Unable to determine” when evidence does not support a known explanation. |
| No cause-specific checkout next step | Provide a reasonable next step for each explanation. |
| Checkout completion clears the basket | Closing help returns to the basket without changing its contents, quantities, payment classification, or benefit usage. |

Proposed flow: **Basket item → scripted rejection or unsupported indication → open checkout help → possible cause → suggested next step → return to unchanged basket.**

Explanations must say “Possible cause” or equivalent. WolfBite must not claim to know the official checkout decision or guarantee that a suggested action will make checkout succeed.

## 6. Shared M0/M4 Scenarios

These are proposed, synthetic examples—not official benefit rules. M0 and M4 should keep the same scenario IDs, item/benefit evidence, and expected next steps. All three begin with the affected item still in the basket. Rejection is supplied by the scenario, because the current app does not receive it from checkout.

For each scenario, the shopper opens the affected item's help, reads the explanation and next step, and returns to the basket. The help interaction itself does not execute the suggested basket change or complete checkout.

### Scenario 1 — Package-Size Mismatch

**Scenario ID:** M0-M4-01

The product category may be covered, but the selected package is a different size from the one listed in the mock benefit information.

**Preconditions:**

* The basket contains one 24 oz cereal package.
* Current mock records say the category is covered, but only an 18 oz package matches this example's benefit rule.
* Balance is sufficient for an otherwise matching item; there is no stale-data condition.
* The scenario supplies a rejection without an official reason.

**Expected explanation:**

* “Possible cause: this package is 24 oz, while the benefit information available here lists an 18 oz package. This may explain the rejection; it is not the checkout system's official reason.”

**Expected next step:**

* Check the package label against current benefit information and look for an otherwise eligible 18 oz package.

**Expected outcome:**

* Help identifies the size difference and suggests checking/selecting the permitted size without promising acceptance.
* Returning from help preserves all basket items, quantities, payment classifications, and benefit usage.

### Scenario 2 — Insufficient Category Balance

**Scenario ID:** M0-M4-02

The product fits the category and size rules, but the available balance cannot cover the affected item.

**Preconditions:**

* The basket contains an affected cereal item requiring one mock benefit unit.
* Current mock records show matching category and package size.
* Zero units remain available for this item after other allocations; this affected item has no covered allocation of its own.
* Its original cereal category is known, even if its basket line is marked `PAID`.
* The scenario supplies a rejection or unsupported indication.

**Expected explanation:**

* “Possible cause: the available cereal balance is 0 units, and this item needs 1 unit. There may not be enough benefit balance to cover it. This is not the checkout system's official reason.”

**Expected next step:**

* Review the current cereal balance and reduce the quantity intended for benefit coverage to fit it. With zero units available for this item, a same-category substitution alone should not be presented as restoring coverage.

**Expected outcome:**

* Help identifies a possible shortfall and suggests reviewing balance and covered quantity.
* It does not automatically remove an item, change quantities, convert a line to paid, or change benefit usage.

### Scenario 3 — Stale Information

**Scenario ID:** M0-M4-03

“Stale” means the available product or benefit information is too old to rely on under an agreed freshness rule. For example, an old benefit record may no longer describe the shopper's current balance. It does not mean the food itself is expired, and it does not prove why checkout rejected the item.

**Preconditions:**

* The affected item remains in the basket after a scripted rejection.
* Mock product or benefit evidence is explicitly outside the freshness window agreed by M0 and M4.
* No verified current replacement information is available.
* The outdated evidence cannot reliably establish a package-size mismatch or balance shortfall.

**Expected explanation:**

* “Possible cause: the product or benefit information available here may be outdated. WolfBite is unable to determine why checkout rejected this item. This is not the checkout system's official reason.”

**Expected next step:**

* Verify current product and benefit information through the shopper's benefit information source, or ask the cashier to check before retrying. This suggestion does not assume that WolfBite already has a refresh feature.

**Expected outcome:**

* Help communicates uncertainty rather than declaring the product ineligible or the balance exhausted.
* Returning from help preserves the basket and benefit usage; no monthly reset is triggered by help.

## 7. Unable-to-Determine Fallback

When item/benefit evidence is missing, ambiguous, or contradictory, WolfBite should not guess. For example, if size rules and balance information are missing and there is no evidence establishing staleness, none of the known explanations is supported.

The shopper should see: “Unable to determine a possible cause from the information available. WolfBite does not have the checkout system's official rejection reason.”

The suggested next step is to ask the cashier to check the item and consult current benefit information before retrying. The shopper can return to the unchanged basket.

This is an additional M4 feature-test case, not a fourth primary M0 evaluation scenario. Missing freshness evidence alone must not be labeled as known stale information.

## 8. What M0 Will Test Later

M0 will compare the same scenario evidence and rejection setup across:

* **Baseline flow:** existing WolfBite behavior, with no new checkout-help explanation. Existing warnings remain part of the baseline.
* **M4 flow:** the shopper can open a possible explanation and suggested next step.

The later scoring checks will use sample trial records to determine whether the expected next step was identified within 60 seconds without outside assistance. The proposed M4 help is part of the feature being evaluated; M0 and M4 should confirm that “without help” means without researcher or other outside assistance.

The milestone targets are 80% success and a 20-percentage-point improvement over baseline. Percentage points mean subtracting the baseline success percentage from the M4 success percentage: 80% minus 60% is 20 percentage points. Known passing and failing sample records will test the scoring rules.

Later work also includes running relevant baseline tests, M4 feature tests, and scoring checks in continuous integration (CI), the automated checks run by GitHub. Those checks can verify software behavior and scoring calculations; they cannot establish user usefulness without participant evidence.

No scoring script was created, no tests were run for this task, and none of these targets is claimed as passed. Participant testing was not conducted, and user usefulness remains unverified.

## 9. What M4 Needs to Implement

* [ ] Agree with M0 on the three scenario records and expected next steps.
* [ ] Provide a checkout-help action on the affected basket item using the agreed mock rejection/unsupported setup.
* [ ] Use simple rules over mock item and benefit evidence.
* [ ] Explain package-size mismatch using comparable sizes and units.
* [ ] Explain insufficient category balance using the item's original category, required amount, and available amount.
* [ ] Explain stale information using an agreed freshness rule.
* [ ] Return “Unable to determine” when evidence does not support a known explanation.
* [ ] Provide a reasonable next step and label every explanation as a possible cause, not an official decision.
* [ ] Return to the basket without changing items, quantities, payment classifications, or benefit usage.
* [ ] Test each explanation and fallback, including the complete basket-item-to-help-and-back interaction.
* [ ] Make feature tests available for M0's later CI checks.

## 10. Important Limitations / Open Questions

1. **Agree on the rejection setup.** There is no official rejection event in the current flow. Will the shared fixture represent a cashier-reported rejection, an unsupported indication, or both? Keep the affected item present so help can be opened.
2. **Confirm package-size evidence.** The inspected basket/import paths do not supply structured size rules. Agree on mock fields, units, and the synthetic 24 oz versus 18 oz example before finalizing it.
3. **Define remaining balance precisely.** Current `used` includes basket activity and survives checkout. Agree on what is already allocated and avoid counting the affected item twice or labeling a covered allocation as a shortfall.
4. **Keep the original category available.** A `PAID` basket category alone does not say which benefit category to examine.
5. **Define staleness.** Agree on the freshness window and a fixed evaluation time for repeatable tests. Product import and user-state write timestamps are not proof of source verification. Keep missing evidence distinct from evidence known to be outdated.
6. **Decide how overlapping causes work.** The three initial examples isolate one cause. Agree on uncertainty or fallback behavior when size, balance, and stale evidence conflict.
7. **Confirm the evaluation wording.** Agree on acceptable next-step answers, the 60-second start point and boundary, and what “without help” means before writing the scoring script.
8. **Keep eligibility claims limited.** The scan flow finds records without requiring `eligible == true`, although badges and alternative filtering use that field. The import script assumes eligibility. Neither proves official checkout acceptance.
9. **Plan the CI correction later.** [flutter-ci.yml](../../.github/workflows/flutter-ci.yml) uses `./Project2`, but the application is in `Project3`. It triggers for pushes to `main` and pull requests targeting `main`, not direct pushes to this M0 branch or PRs targeting `dev`. No CI changes are part of this document.
10. **Review with M4 before calling Task 1 complete.** This is a proposed shared specification, not a confirmed handoff. Agree on the unresolved scenario details and make this same document available to M4. Current findings are based on repository code and test sources, not live Firestore contents or a newly executed test run.
