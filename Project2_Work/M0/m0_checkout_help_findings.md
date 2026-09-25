# M0 Checkout-Help Findings

## 1. Purpose and Status

M0 evaluates whether checkout help improves a shopper's ability to identify the expected next step after an item is rejected. M4 builds that help.

### Measurable Hypothesis

Compared with the current WolfBite checkout flow, M4 checkout help will enable at least 80% of evaluation trials to identify the expected next step after a rejected item within 60 seconds and without outside assistance. This success rate will be at least 20 percentage points higher than the baseline rate.

The metric is the percentage of successful trials. The current WolfBite checkout flow is the baseline condition, and the M4 checkout-help flow is the comparison condition. A successful trial requires the expected next step to be identified within an inclusive 60-second limit and without outside assistance.

**Task 1 documentation is complete:** Abigail, owner of both milestones, accepted the three shared scenarios below. The companion [M0/M4 use-case specification](m4_checkout_help_use_cases.md) provides the detailed interaction flows and M4 acceptance criteria.

The current final evaluation status, including passed checks, unverified targets, limitations, and needed changes, is recorded in [M0 Evaluation Results and Limitations](m0_evaluation_results.md).

These scenarios use mock records and simulated rejection. A live Approved Product List (APL) or working scanner is not required to define them.

## 2. Current Behavior and What M4 Adds

Application code lives in `Project3`. The following findings explain why checkout help is needed:

| Area | Current behavior | What M4 adds |
| --- | --- | --- |
| Product lookup | [ScanScreen._checkEligibility](../../Project3/lib/screens/scan_screen.dart) looks up a UPC through [AplService.findByUpc](../../Project3/lib/services/apl_service.dart). An unknown code produces a not-found message. Manual entry is available at widths of at least 600 pixels; narrower layouts use the camera. | Help for a selected basket item using mock product and benefit evidence. A missing APL record alone is not an official rejection or proof of ineligibility. |
| Category balance | [AppState.canAdd and addItem](../../Project3/lib/state/app_state.dart) check allowed/used item counts. The scan page blocks a new addition when the category is full. Increasing an existing item can create a `PAID` line. | An explanation of the amount required versus the amount available for the affected item's original benefit category. |
| Basket | [BasketScreen](../../Project3/lib/screens/basket_screen.dart) shows items, quantities, categories, and a “Will add as paid” tooltip at the limit. No checkout-help action exists. | An item-level help action with a possible cause, suggested next step, and return to the unchanged basket. |
| Checkout | [QRCheckoutScreen](../../Project3/lib/screens/qr_checkout_screen.dart) displays basket data as a QR code. “Finish Transaction” calls `AppState.checkout`, which clears the basket and retains usage. No official rejection response is received. | A separate help interaction that does not finish checkout or clear the basket. |
| Size and freshness evidence | [normalizeRecord](../../Project3/scripts/import.js) imports product identity/category, assumed eligibility, and an import timestamp. Basket records do not retain structured size restrictions. User-state timestamps in `AppState` support monthly resets, not source freshness checks. | Explicit mock package-size rules and freshness statuses. Neither an eligibility badge nor a write/import timestamp proves checkout acceptance or current source information. |

## 3. Shared M0/M4 Scenarios

These are accepted synthetic scenarios, not official benefit rules. M0 and M4 should keep the same scenario IDs, item/benefit evidence, and expected next steps. All three begin with the affected item still in the basket. Rejection is supplied by the scenario, because the current app does not receive it from checkout.

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

“Stale” means the available product or benefit information is too old to rely on under the shared mock freshness rule. For example, an old benefit record may no longer describe the shopper's current balance. It does not mean the food itself is expired, and it does not prove why checkout rejected the item.

**Preconditions:**

* The affected item remains in the basket after a scripted rejection.
* Mock product or benefit evidence has an explicit `outdated` freshness status. `current` means the record is usable for this example; `unknown` or a missing status does not establish staleness. These are fixture statuses, not a live timestamp policy.
* No verified current replacement information is available.
* The outdated evidence cannot reliably establish a package-size mismatch or balance shortfall.

**Expected explanation:**

* “Possible cause: the product or benefit information available here may be outdated. WolfBite is unable to determine why checkout rejected this item. This is not the checkout system's official reason.”

**Expected next step:**

* Verify current product and benefit information through the shopper's benefit information source, or ask the cashier to check before retrying. This suggestion does not assume that WolfBite already has a refresh feature.

**Expected outcome:**

* Help communicates uncertainty rather than declaring the product ineligible or the balance exhausted.
* Returning from help preserves the basket and benefit usage; no monthly reset is triggered by help.

## 4. Unable-to-Determine Fallback

When item/benefit evidence is missing, ambiguous, or contradictory, WolfBite should not guess. For example, if size rules and balance information are missing and there is no evidence establishing staleness, none of the known explanations is supported.

The shopper should see: “Unable to determine a possible cause from the information available. WolfBite does not have the checkout system's official rejection reason.”

The suggested next step is to ask the cashier to check the item and consult current benefit information before retrying. The shopper can return to the unchanged basket.

This is an additional M4 feature-test case, not a fourth primary M0 evaluation scenario. Missing freshness evidence alone must not be labeled as known stale information.

## 5. Later M0 Work

M0 will compare the existing flow with the M4 help flow using the same scenarios. The milestone targets are an expected next step within 60 seconds without outside assistance, 80% success, and a 20-percentage-point improvement over baseline. Confirm the timing boundaries, accepted answers, and assistance definition when preparing the scoring script.

Relevant baseline checks include:

* [aditya_uc6-10_test.dart](../../Project3/test/project1a/aditya_uc6-10_test.dart): UC8-T2 checks refusal of a new item when allowance is exhausted.
* [satwi_uc11-15_test.dart](../../Project3/test/project1a/satwi_uc11-15_test.dart): UC12–UC15 cover basket display, quantity controls, and paid overflow.
* [supreme_uc16-20_test.dart](../../Project3/test/project1a/supreme_uc16-20_test.dart): UC20 checks basket clearing with retained usage.
* [project1a_coverage_gaps_test.dart](../../Project3/test/active/project1a_coverage_gaps_test.dart): checkout tests check saved state and persistence failure behavior.

Run relevant baseline, M4 feature, and scoring checks during later tasks. The [CI workflow](../../.github/workflows/flutter-ci.yml) currently points at `Project2` rather than `Project3` and targets `main`; review this when setting up automated checks.

**Evaluation status:** Relevant baseline tests passed locally. The Task 3 scoring script and synthetic fixtures produce the expected passing and failing calculations, and the scorer's automated tests pass locally. A scoring-specific GitHub Actions workflow has been added; its remote run remains pending until these changes are pushed. Participant testing was not conducted, user usefulness remains unverified, and M4 has not been implemented.
