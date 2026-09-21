# M0/M4 Shared Checkout-Help Use Cases

**Status:** Scenarios accepted by Abigail, owner of M0 and M4. Shared specification ready for M4 implementation; feature behavior and user usefulness remain unverified.

**Related findings:** [M0 Checkout-Help Findings](m0_checkout_help_findings.md)

## Purpose and Scope

M4 builds straightforward help for a rejected basket item. M0 later evaluates whether that help makes the expected next step easier to identify. This companion document provides the use cases M4 can use for implementation and feature tests, using the same scenario IDs and evidence as the M0 findings.

**Primary actor:** A shopper reviewing an affected item in their basket.

The examples use synthetic product and benefit records, not official benefit rules. The current application does not receive official checkout rejection reasons. Each scenario therefore supplies a scripted rejection or unsupported-item indication while keeping the affected item in the basket.

For every use case, help provides information only. Opening help, reading it, and returning must preserve all basket items, quantities, payment classifications, and benefit usage. The shopper may act on the suggestion afterward; help must not automatically change the basket or finish checkout.

## Use Case: Package-Size Mismatch

**Scenario ID:** M0-M4-01

**Goal:** Help the shopper understand that the package size may explain why an otherwise eligible product was rejected.

**Preconditions:**

* The basket contains one 24 oz cereal package.
* Current mock records identify the cereal category as covered but permit only an 18 oz package in this example.
* Balance is sufficient for an otherwise matching item, and the records are not stale.
* A scripted rejection has occurred; no official rejection reason is available.

**Trigger:** The shopper chooses checkout help for the affected cereal item.

**Main Flow:**

1. The shopper locates the affected item in the basket.
2. The shopper opens that item's checkout-help action.
3. WolfBite shows the 24 oz package size, the mock 18 oz permitted size, a possible explanation, and a suggested next step.
4. The shopper closes help and returns to the basket.

**Expected Explanation:**

“Possible cause: this package is 24 oz, while the benefit information available here lists an 18 oz package. This may explain the rejection; it is not the checkout system's official reason.”

**Expected Next Step:**

Check the package label against current benefit information and look for an otherwise eligible 18 oz package.

**Expected Outcome:**

The explanation identifies the size difference without promising that another item will be accepted. The shopper returns to the unchanged basket, with unchanged benefit usage.

## Use Case: Insufficient Category Balance

**Scenario ID:** M0-M4-02

**Goal:** Help the shopper understand that the remaining category balance may not cover the affected item.

**Preconditions:**

* The basket contains an affected cereal item requiring one mock benefit unit.
* Current mock product and benefit records show a matching category and package size.
* Zero units remain available for this item after other allocations. The affected item has no covered allocation of its own.
* The original cereal category is known, even if the basket line is marked `PAID`.
* The scenario supplies a rejection or unsupported indication; no official rejection reason is available.

**Trigger:** The shopper chooses checkout help for the affected cereal item.

**Main Flow:**

1. The shopper locates the affected item in the basket.
2. The shopper opens that item's checkout-help action.
3. WolfBite shows that the item needs one unit and has zero units available, with a possible explanation and suggested next step.
4. The shopper closes help and returns to the basket.

**Expected Explanation:**

“Possible cause: the available cereal balance is 0 units, and this item needs 1 unit. There may not be enough benefit balance to cover it. This is not the checkout system's official reason.”

**Expected Next Step:**

Review the current cereal balance and reduce the quantity intended for benefit coverage to fit it. With zero units available for this item, a same-category substitution alone should not be presented as restoring coverage.

**Expected Outcome:**

The explanation identifies a possible shortfall. Returning from help does not remove an item, change quantities, convert a line to paid, or change benefit usage.

## Use Case: Stale Information

**Scenario ID:** M0-M4-03

**Goal:** Help the shopper recognize that outdated information prevents a confident explanation of the rejection.

“Stale” means the available product or benefit information is too old to rely on under the shared mock freshness rule. It does not mean the food is expired or prove why checkout rejected it.

**Preconditions:**

* The affected item remains in the basket after a scripted rejection.
* Mock product or benefit evidence has an explicit `outdated` freshness status. `current` means usable for this example; `unknown` or a missing status does not establish staleness. These are fixture statuses, not a live timestamp policy.
* No verified current replacement information is available.
* The outdated evidence cannot reliably establish a package-size mismatch or balance shortfall.

**Trigger:** The shopper chooses checkout help for the affected item.

**Main Flow:**

1. The shopper locates the affected item in the basket.
2. The shopper opens that item's checkout-help action.
3. WolfBite explains that the information may be outdated and shows a next step for checking current information.
4. The shopper closes help and returns to the basket.

**Expected Explanation:**

“Possible cause: the product or benefit information available here may be outdated. WolfBite is unable to determine why checkout rejected this item. This is not the checkout system's official reason.”

**Expected Next Step:**

Verify current product and benefit information through the shopper's benefit information source, or ask the cashier to check before retrying. This does not assume WolfBite already provides a refresh feature.

**Expected Outcome:**

The explanation communicates uncertainty rather than declaring the product ineligible or the balance exhausted. Returning from help preserves the basket and benefit usage and does not trigger a monthly reset.

## Alternate Flow: Unable to Determine

**Test reference:** M0-M4-F01. This is a fallback feature-test case, not a fourth primary M0 evaluation scenario.

**Condition:** The shopper opens help, but the mock evidence is missing, ambiguous, or contradictory and does not support a known explanation. For example, package-size rules and balance details are missing, and no evidence establishes staleness.

**Expected Explanation:**

“Unable to determine a possible cause from the information available. WolfBite does not have the checkout system's official rejection reason.”

**Expected Next Step:**

Ask the cashier to check the item and consult current benefit information before retrying.

**Expected Outcome:**

WolfBite does not guess a cause. The shopper can return to the basket with all items, quantities, payment classifications, and benefit usage unchanged. Missing freshness evidence alone must not be labeled as known stale information.

## Acceptance Criteria for M4 Feature Tests

These are requirements for future tests, not reported test results. The example wording may be adjusted for clarity as long as its meaning, uncertainty, and expected next step remain consistent with M0.

* [ ] The checkout-help action opens help for the selected basket item.
* [ ] M0-M4-01 shows the package-size difference and the size-related next step.
* [ ] M0-M4-02 shows the required and available category amounts and the balance-related next step.
* [ ] M0-M4-03 identifies outdated information and recommends verification without asserting a definite rejection cause.
* [ ] M0-M4-F01 returns “Unable to determine” when evidence cannot support a known explanation.
* [ ] Every explanation is identified as a possible cause or an inability to determine one, never an official checkout decision or guarantee of acceptance.
* [ ] Each scenario and the fallback are tested through the complete basket-item → help → return-to-basket flow.
* [ ] Basket contents, quantities, payment classifications, and benefit usage are unchanged after opening and closing help in every case.

## Shared Scenario Decisions

* **Rejection:** Supply a scripted rejection or unsupported indication with the affected item still in the basket. No live checkout response is required.
* **Package size:** Use 24 oz selected versus 18 oz permitted, with matching units, sufficient balance, and current evidence. These are synthetic rules.
* **Balance:** Use one unit required and zero available after other allocations. The affected item has no covered allocation; retain its original benefit category even if marked `PAID`.
* **Freshness:** Mock records use `current`, `outdated`, or `unknown`. Only explicit `outdated` evidence supports the stale-information explanation. This scope does not require an age threshold or live source verification.
* **Fallback:** Missing or conflicting evidence that cannot support one clear explanation produces “Unable to determine.” Outdated evidence must not support a definite package-size or balance diagnosis.
* **Shared reference:** This document is the specification for both M4 feature tests and M0's later evaluation. Keep scenario IDs and next steps aligned with the [M0 findings](m0_checkout_help_findings.md).

M0 owns the later baseline comparison and scoring checks. Their timing and scoring details are outside Task 1 and do not block implementation of these use cases.

Participant testing was not conducted, and user usefulness remains unverified. This document does not establish that M4 is implemented, its tests pass, or the M0 evaluation targets have been met.
