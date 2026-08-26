# WolfBite: final 20 use cases

Status: reconciled from the Codex, Gemini, GPT-5.6-terra, and local Llama
reviews, then verified against production code. The local model had limited
repository context, so it was used only as corroboration. Repository evidence
settled disagreements. Main success scenarios contain only the happy path;
all branching appears in Extensions.

## UC1: Create account

| Part | Content |
|---|---|
| Name | Create account |
| Primary actor | New shopper |
| Stakeholders & interests | Shopper: obtain a usable account and retain profile information. Service owner: maintain valid, attributable accounts. |
| Preconditions | Shopper is signed out and account services are available. |
| Trigger | Shopper chooses to create an account. |
| Main success scenario | 1. Shopper provides the required account and profile information. 2. System validates the information. 3. System creates the shopper's account. 4. System saves the shopper's profile. 5. System ends the initial session and makes sign-in available. |
| Extensions | 2a: Required information is blank or invalid → system identifies the invalid entry and does not submit. 3a: Account creation is rejected → system reports the failure and keeps account creation available. 4a: Account creation succeeds but profile saving fails → the account and profile are left incomplete, with no reliable recovery in this flow. |
| Postconditions | The account and profile exist, and the shopper can sign in. |

## UC2: Sign in

| Part | Content |
|---|---|
| Name | Sign in |
| Primary actor | Returning shopper |
| Stakeholders & interests | Shopper: gain secure access to saved shopping information. Service owner: reject invalid credentials and protect account data. |
| Preconditions | Shopper is signed out and has an account. |
| Trigger | Shopper chooses to sign in. |
| Main success scenario | 1. Shopper provides account credentials. 2. System validates the credentials. 3. System authenticates the shopper. 4. System makes protected shopping features available. |
| Extensions | 2a: Email format is invalid → system reports the invalid entry without authenticating. 2b: Password is shorter than six characters → system reports the minimum length. 3a: Authentication is rejected or unavailable → system reports the failure and leaves the shopper signed out. 3b: A sign-in request is already active → system prevents another submission until it finishes. |
| Postconditions | Shopper is authenticated and can access protected shopping features. |

## UC3: Sign out

| Part | Content |
|---|---|
| Name | Sign out |
| Primary actor | Authenticated shopper |
| Stakeholders & interests | Shopper: prevent later device users from accessing the account. Service owner: remove account-specific information from the active session. |
| Preconditions | Shopper is signed in. |
| Trigger | Shopper chooses to sign out. |
| Main success scenario | 1. Shopper requests sign-out. 2. System ends the authenticated session. 3. System removes account-specific shopping information from the current session. 4. System makes sign-in available. |
| Extensions | 2a: Sign-out fails → shopper remains signed in and receives no explicit explanation. 4a: Signed-out state is detected before the normal transition finishes → system still returns the shopper to sign-in. |
| Postconditions | No shopper is authenticated locally, and protected features require sign-in. |

## UC4: Resume shopping session

| Part | Content |
|---|---|
| Name | Resume shopping session |
| Primary actor | Returning shopper |
| Stakeholders & interests | Shopper: recover the correct basket and benefit usage. Service owner: keep each shopper's information isolated. |
| Preconditions | Shopper has authenticated and has an account identifier. |
| Trigger | System detects the signed-in shopper. |
| Main success scenario | 1. System identifies the shopper. 2. System retrieves the shopper's saved shopping information. 3. System restores the current basket, quantities, product information, and benefit usage. 4. System confirms that the saved activity belongs to the current benefit month. 5. System makes the restored session available. |
| Extensions | 2a: No saved shopping information exists → system begins a new empty session. 2b: Retrieval fails → system finishes loading but provides no user-facing recovery. 3a: Saved basket or benefit information is missing → system restores available information and substitutes empty values for the rest. 3b: A saved product lacks nutrition information → system substitutes zero-valued nutrition fields. 4a: Saved activity is from an earlier month or year → system clears the basket, resets used benefits, and attempts to save the new-month state. 4b: Saving the monthly reset fails → the visible reset may not be preserved for the next session. |
| Postconditions | The shopper's current-month saved session, or a new empty session, is available. |

## UC5: Identify product

| Part | Content |
|---|---|
| Name | Identify product |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: identify a product without relying on unsupported claims. Product-data owner: receive the intended product code. |
| Preconditions | Shopper is signed in and product lookup is available. |
| Trigger | Shopper provides a product code by barcode capture or manual entry. |
| Main success scenario | 1. Shopper provides a product code. 2. System searches for a matching product record. 3. System identifies the matching product. 4. System presents the product, category, code, and available nutrition summary. 5. System makes any healthier alternatives available for comparison. |
| Extensions | 1a: Barcode capture is cancelled or contains no readable code → system remains ready for another attempt. 1b: Manual entry is empty → system performs no lookup and provides no explanation. 2a: Another lookup is active → system ignores the new request. 2b: No matching product record exists → system reports that the code was not found and clears the current product result. 2c: Lookup fails → system reports the failure. 3a: A matching record is marked ineligible or lacks an eligibility value → system still presents it because direct lookup does not enforce eligibility. |
| Postconditions | A matching product is available for review, and the basket is unchanged. |

## UC6: Review product nutrition

| Part | Content |
|---|---|
| Name | Review product nutrition |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: understand the identified product's nutritional qualities. Nutrition-data owner: have available values interpreted consistently. |
| Preconditions | A product has been identified. |
| Trigger | Shopper reviews the identified product. |
| Main success scenario | 1. System evaluates the available nutrition information. 2. System presents up to three nutritional qualities that apply to the product. 3. Shopper reviews the summary. |
| Extensions | 1a: A nutrient is missing or nonnumeric → system substitutes zero. 1b: A value exactly equals a nutrition threshold → system includes the applicable quality because thresholds are inclusive. 1c: Missing values become zero → system may present low-fat, low-sodium, low-sugar, low-calorie, or heart-healthy qualities even though the values are unknown. 2a: No nutrition rule matches → system presents no quality label. 2b: More than three rules match → system presents only the first three. |
| Postconditions | Shopper has reviewed the available nutrition summary; product and basket are unchanged. |

## UC7: Compare healthier alternatives

| Part | Content |
|---|---|
| Name | Compare healthier alternatives |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: find a healthier eligible option in the same category. Product-data owner: have candidates compared consistently. |
| Preconditions | An identified product has a nonempty category. |
| Trigger | Shopper requests healthier alternatives. |
| Main success scenario | 1. System compares the product with eligible products in the same category. 2. System identifies products with a better nutrition assessment. 3. System ranks the qualifying alternatives. 4. System presents up to five alternatives. 5. Shopper reviews the comparison. |
| Extensions | 1a: Product category is blank → system does not search. 1b: Search fails → system reports the failure. 2a: Candidate nutrition is missing → zero values may make the candidate appear healthier than it is. 2b: Candidate is the original product → system excludes it. 2c: No candidate has a better assessment → system reports that no healthier alternative is available. 4a: More than fifty category candidates exist → displayed alternatives are selected only from the first fifty retrieved. |
| Postconditions | Shopper has reviewed up to five healthier alternatives; basket is unchanged. |

## UC8: Add product to basket

| Part | Content |
|---|---|
| Name | Add product to basket |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: add an identified product. Benefit program: keep covered usage within the category allowance. |
| Preconditions | Shopper is signed in and a product has been identified. |
| Trigger | Shopper chooses to add the identified product. |
| Main success scenario | 1. System confirms that the product is within the current category allowance. 2. System adds one unit to the basket. 3. System increases the category's used benefits. 4. System saves and confirms the addition. |
| Extensions | 1a: Category allowance is exhausted → system disables the covered addition and warns the shopper. 2a: Same product already exists → system follows the quantity-increase flow rather than creating a duplicate covered selection. 2b: Shopper is no longer authenticated → system rejects the addition. 4a: Saving fails → the current session may show the addition even though it was not preserved, and no recovery is shown. |
| Postconditions | One covered unit is represented in the basket and category usage has increased by one. |

## UC9: Choose healthier alternative

| Part | Content |
|---|---|
| Name | Choose healthier alternative |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: choose a healthier product without another lookup. Benefit program: apply the same category allowances to the selected alternative. |
| Preconditions | Healthier alternatives are available and shopper is signed in. |
| Trigger | Shopper selects a healthier alternative. |
| Main success scenario | 1. Shopper chooses an alternative. 2. System confirms that it is within the current category allowance. 3. System adds the alternative to the basket. 4. System updates benefit usage. 5. System saves and confirms the selected alternative. |
| Extensions | 2a: Category allowance is exhausted → system may reject the addition but still report success. 3a: Same alternative is already in the basket → system increases its quantity instead of creating a duplicate selection. 3b: Shopper is no longer authenticated → system rejects the addition but may still report success. 5a: Saving fails → visible and restored basket contents may differ. |
| Postconditions | On actual success, the selected alternative and corresponding benefit usage are saved in the basket. |

## UC10: Scan receipt

| Part | Content |
|---|---|
| Name | Scan receipt |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: identify products recorded on a receipt with less manual entry. Receipt-reading provider: receive a supported image. Product-data owner: validate extracted codes. |
| Preconditions | Shopper is signed in and image, network, receipt-reading, and product-lookup services are available. |
| Trigger | Shopper chooses to scan a receipt. |
| Main success scenario | 1. Shopper supplies a receipt image. 2. System reads the receipt contents. 3. System identifies contiguous 12- to 14-digit product-code candidates. 4. System checks the candidates for matching product records. 5. System presents the unique matching products and a recognition summary. |
| Extensions | 1a: Shopper cancels image selection → system ends the attempt. 2a: Receipt reading fails → system reports the failure. 3a: No 12- to 14-digit candidate exists → system reports that no candidate was found. 3b: Receipt contains spaces or hyphens inside a product code → system does not recognize that code. 4a: A 13- or 14-digit candidate is found → system also checks each 12-digit window until a match is found. 4b: Candidates exist but none match → system reports the candidate count and zero matches. 5a: Same matching code appears repeatedly → system offers the product only once even though the recognition count includes repeated candidates. |
| Postconditions | Zero or more unique matching receipt products are available for review; basket is unchanged. |

## UC11: Add receipt products

| Part | Content |
|---|---|
| Name | Add receipt products |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: transfer recognized products into the basket. Benefit program: apply category allowances. |
| Preconditions | Receipt scanning found at least one matching product and shopper is signed in. |
| Trigger | Shopper chooses to add the recognized products. |
| Main success scenario | 1. System evaluates each unique recognized product against current allowances. 2. System adds each accepted product to the basket. 3. System updates corresponding benefit usage. 4. System reports the accepted additions. 5. System presents the updated basket. |
| Extensions | 1a: Product lacks nutrition values → system substitutes zero values. 2a: Product is already in the basket → system increases its quantity, but the reported addition count omits that increase. 2b: Product category is at its cap → system rejects that product rather than adding it as shopper-paid and continues with the others. 5a: Saving fails → system may still present locally updated basket contents that were not preserved. |
| Postconditions | Every accepted product is represented in the basket and its category usage has been updated. |

## UC12: Review basket

| Part | Content |
|---|---|
| Name | Review basket |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: verify selected products and quantities before checkout. Benefit program: distinguish covered and shopper-paid quantities. |
| Preconditions | Shopper is signed in. |
| Trigger | Shopper requests the current basket. |
| Main success scenario | 1. System presents each selected product, its quantity, category, and nutrition summary. 2. System presents the total selected quantity. 3. Shopper reviews the basket. |
| Extensions | 1a: Basket is empty → system explains that it is empty and offers to begin product identification. 1b: Product lacks nutrition information → system substitutes zero-valued nutrition. 1c: Product has covered and shopper-paid quantities → system presents them as separate selections. |
| Postconditions | Shopper has reviewed the current basket; quantities and benefit usage are unchanged. |

## UC13: Review basket-product nutrition

| Part | Content |
|---|---|
| Name | Review basket-product nutrition |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: inspect detailed nutrition facts for a basket product. Nutrition-data owner: preserve available product values. |
| Preconditions | Basket contains the selected product. |
| Trigger | Shopper requests detailed nutrition for a basket product. |
| Main success scenario | 1. Shopper selects a basket product for nutritional review. 2. System presents calories, total and saturated fat, sodium, total sugars, and protein. 3. Shopper reviews the values. 4. Shopper returns to the basket summary. |
| Extensions | 2a: Stored nutrition information is absent → system displays zero defaults. 2b: One value is absent inside otherwise available nutrition information → system displays `null` rather than identifying it as unknown. 4a: Shopper does not return to the summary → details remain visible while the current product view is retained. |
| Postconditions | Shopper has inspected the selected product's nutrition; basket is unchanged. |

## UC14: Increase product quantity

| Part | Content |
|---|---|
| Name | Increase product quantity |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: add another unit of a selected product. Benefit program: keep covered quantity within its allowance. |
| Preconditions | Basket contains the selected covered product. |
| Trigger | Shopper requests another unit. |
| Main success scenario | 1. System confirms that another covered unit is available. 2. System increases the product quantity by one. 3. System increases the category's used benefits by one. 4. System saves and presents the updated basket. |
| Extensions | 1a: Category allowance is exhausted → continue with UC15, Add shopper-paid quantity. 2a: Matching covered product cannot be found → system makes no quantity change but still behaves as though an update was processed. 4a: Saving fails → displayed and restored quantities may differ. |
| Postconditions | Covered product quantity and corresponding used benefits have each increased by one. |

## UC15: Add shopper-paid quantity

| Part | Content |
|---|---|
| Name | Add shopper-paid quantity |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: obtain another unit after WIC coverage is exhausted. Benefit program: exclude the additional unit from covered usage. Retailer: distinguish shopper-paid quantity. |
| Preconditions | Basket contains the covered product and its category allowance is exhausted. |
| Trigger | Shopper requests another unit of that product. |
| Main success scenario | 1. System identifies the additional unit as shopper-paid. 2. System adds one shopper-paid unit to the basket. 3. System leaves covered benefit usage unchanged. 4. System saves and presents covered and shopper-paid quantities. |
| Extensions | 1a: Shopper attempts to add a different newly identified product after its category is full → system disables the addition instead of making it shopper-paid. 2a: Shopper-paid quantity already exists for the product → system increases it instead of creating a duplicate selection. 2b: Original covered product cannot be found → system adds nothing. 4a: Shopper reviews benefits afterward → shopper-paid quantity appears as an unlimited category even though it is not a WIC benefit. 4b: Saving fails → displayed and restored paid quantities may differ. |
| Postconditions | One additional shopper-paid unit is represented in the basket, and covered benefit usage is unchanged. |

## UC16: Decrease product quantity

| Part | Content |
|---|---|
| Name | Decrease product quantity |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: correct an over-selection. Benefit program: release covered usage only when a covered unit is removed. |
| Preconditions | Basket contains the product. |
| Trigger | Shopper requests removal of one unit. |
| Main success scenario | 1. System identifies the applicable selected quantity. 2. System decreases the quantity by one. 3. System adjusts benefit usage when a covered unit is removed. 4. System removes the selection when its quantity reaches zero. 5. System saves and presents the updated basket. |
| Extensions | 1a: Covered and shopper-paid quantities both exist → system decreases shopper-paid quantity first. 1b: No shopper-paid quantity exists → system decreases the covered quantity. 1c: No matching product exists → system makes no quantity change. 3a: Recorded usage is already zero → system keeps it at zero. 5a: Saving fails → displayed and restored quantities may differ. |
| Postconditions | One matching unit has been removed, and associated usage is not negative. |

## UC17: Clear basket

| Part | Content |
|---|---|
| Name | Clear basket |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: abandon every current selection in one action. Benefit program: release provisional category usage. |
| Preconditions | Basket contains at least one product. |
| Trigger | Shopper chooses to clear the basket. |
| Main success scenario | 1. System asks the shopper to confirm complete removal. 2. Shopper confirms. 3. System removes every basket selection. 4. System reverses the selections' provisional benefit usage without making any category negative. 5. System saves and presents the empty basket. |
| Extensions | 2a: Shopper cancels → system leaves basket and benefit usage unchanged. 4a: Product category is absent from balances → system removes the product without changing a category total. 4b: Recorded usage is smaller than removed quantity → system keeps the resulting usage at zero. 5a: Saving fails → current basket is empty but saved products may remain. |
| Postconditions | Basket is empty and provisional usage from its former selections has been reversed. |

## UC18: Review benefit balances

| Part | Content |
|---|---|
| Name | Review benefit balances |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: know used, allowed, and remaining quantities. Benefit program: communicate category limits accurately. |
| Preconditions | Shopper is signed in and shopping information has loaded. |
| Trigger | Shopper requests current benefit information. |
| Main success scenario | 1. System presents each category's used and allowed quantities. 2. System distinguishes limited and unlimited categories. 3. System presents remaining capacity for limited categories. 4. Shopper reviews the balances. |
| Extensions | 1a: Shopping information is still loading → system presents a loading state. 1b: No categories exist → system reports that benefit data is absent. 2a: Shopper-paid category exists → system presents it as unlimited even though it is not a benefit. 3a: Used quantity reaches or exceeds the allowance → system presents full progress. 3b: Allowance is zero → progress calculation may not produce a meaningful result. |
| Postconditions | Shopper has reviewed current benefit information; basket and balances are unchanged. |

## UC19: Prepare checkout handoff

| Part | Content |
|---|---|
| Name | Prepare checkout handoff |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: present the selected products for checkout. Cashier: receive a scannable representation of the basket. |
| Preconditions | Shopper is signed in and basket is nonempty. |
| Trigger | Shopper declares the basket ready for checkout. |
| Main success scenario | 1. Shopper requests a checkout handoff. 2. System prepares a scannable representation of the current basket. 3. System presents the handoff to the shopper. 4. Shopper presents it to the cashier. |
| Extensions | 2a: Basket information cannot be represented in a usable scannable form → system provides no explicit fallback. 4a: Cashier cannot consume the application-specific representation → system provides no acknowledgement or interoperability check. 4b: Shopper leaves before finishing → basket and benefit usage remain unchanged. |
| Postconditions | The basket remains available and its checkout handoff has been presented; no external acceptance is guaranteed. |

## UC20: Finish shopping session

| Part | Content |
|---|---|
| Name | Finish shopping session |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: finish the current checkout session. Benefit program: retain already-consumed usage. Service owner: save the cleared basket consistently. |
| Preconditions | Shopper is signed in and the checkout handoff is displayed. |
| Trigger | Shopper marks the transaction finished. |
| Main success scenario | 1. Shopper marks checkout finished. 2. System clears the basket. 3. System retains recorded benefit usage. 4. System saves the cleared basket. 5. System confirms completion and returns the shopper to product identification. |
| Extensions | 1a: Shopper marks checkout finished without cashier confirmation → system still proceeds. 4a: Saving fails → current basket remains cleared, no rollback occurs, and completion is not confirmed. |
| Postconditions | Basket is empty in saved state, and recorded benefit usage continues to represent purchased quantities. |

## Production evidence map

| Final use case | Strongest production evidence |
|---|---|
| UC1 | `Project3/lib/screens/signup_page.dart:46–78, 116–199` |
| UC2 | `Project3/lib/screens/login_screen.dart:38–56, 90–142` |
| UC3 | `Project3/lib/app_router.dart:130–183`; `Project3/lib/state/app_state.dart:75–99` |
| UC4 | `Project3/lib/state/app_state.dart:75–86, 195–212, 227–294` |
| UC5 | `Project3/lib/screens/scan_screen.dart:130–162, 405–430, 688–758`; `Project3/lib/services/apl_service.dart:31–35` |
| UC6 | `Project3/lib/utils/nutritional_utils.dart:26–104`; `Project3/lib/widgets/nutritional_badges.dart:103–139` |
| UC7 | `Project3/lib/services/apl_service.dart:139–180`; `Project3/lib/screens/scan_screen.dart:205–403` |
| UC8–UC9 | `Project3/lib/screens/scan_screen.dart:164–203, 360–403`; `Project3/lib/state/app_state.dart:347–405` |
| UC10–UC11 | `Project3/lib/screens/receipt_scanner_screen.dart:29–181` |
| UC12–UC13 | `Project3/lib/screens/basket_screen.dart:98–238, 285–415` |
| UC14–UC17 | `Project3/lib/state/app_state.dart:431–581`; `Project3/lib/screens/basket_screen.dart:368–383` |
| UC18 | `Project3/lib/screens/balances_screen.dart:35–235` |
| UC19–UC20 | `Project3/lib/screens/qr_checkout_screen.dart:12–62`; `Project3/lib/state/app_state.dart:556–563` |

## Reconciliation decisions

- Barcode capture and manual UPC entry were merged into UC5 because both serve
  the same actor goal: identify a product.
- Monthly reset remains an extension of UC4 because it is system-triggered
  during saved-session restoration.
- Direct lookup is described as product identification, not guaranteed WIC
  eligibility, because lookup accepts any existing APL record.
- Product-summary nutrition and detailed basket nutrition remain separate due
  to their different user decisions and observable information.
- Comparing alternatives and choosing one remain separate information and
  action goals; the code adds an alternative but does not swap it atomically.
- Covered increase, shopper-paid overflow, single-unit decrease, and clearing
  the whole basket remain separate due to their distinct outcomes and rules.
- QR preparation and finishing the shopping session are separate. The former
  does not guarantee cashier acceptance; the latter clears the basket locally
  and retains recorded benefit usage.
- Real-time order tracking and food delivery were excluded because no
  production route or module implements them.
