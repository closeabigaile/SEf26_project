# WolfBite: 20 main use cases — Codex draft

Status: independent production-code pass, before reading the inherited tests.
This is the historical Codex working draft, not the final team list. The reconciled,
code-verified set is maintained in `usecases_final.md`.
The tables follow the course's required `usecases0.md` structure. Main success
scenarios contain only the happy path; all branching is in Extensions.

## Reconciliation notes: overlaps and weak names

The draft retains exactly 20 candidates until the cross-model review is
complete. The following pairs are plausible variants of one broader actor goal
and should be reconsidered before the final list is frozen:

- UC5 and UC6 both serve **Identify product**; barcode capture and manual UPC
  entry may be alternate flows rather than separate top-level goals.
- UC9 and UC10 both serve **Add product to basket**; choosing a healthier
  alternative may be an extension or specialization of adding a product.
- UC7 and UC14 both serve **Review product nutrition** from different contexts.
- UC15 and UC16 both serve **Increase product quantity**; self-paid overflow is
  triggered only when the WIC allowance is exhausted.
- UC17 and UC18 both remove basket quantities, but UC18 remains more defensible
  as a separate bulk-removal goal because it affects every selection at once.

Weak implementation-centered names were revised: “Add scanned product” became
“Add product to basket,” “Increase covered quantity” became “Increase product
quantity,” and “Complete QR checkout” became “Prepare checkout handoff.” The
last change avoids claiming that the code verifies cashier acceptance or a
completed external transaction.

## UC1: Create account

| Part | Content |
|---|---|
| Name | Create account |
| Primary actor | New shopper |
| Stakeholders & interests | Shopper: obtain a usable account without losing profile details. Service owner: maintain valid, attributable accounts. |
| Preconditions | Shopper is signed out and can reach the registration feature. Authentication and profile services are available. |
| Trigger | Shopper chooses to create an account. |
| Main success scenario | 1. Shopper provides the required account and profile information. 2. System validates the information. 3. System creates the shopper's account. 4. System saves the shopper's profile. 5. System ends the initial session. 6. System makes sign-in available. |
| Extensions | 2a: Name or address is blank → system identifies the required entry and does not submit. 2b: Email lacks an `@` → system rejects it as invalid. 2c: Password is shorter than six characters → system requests at least six. 3a: Authentication rejects the request (for example, duplicate email) → system displays the provider's failure and keeps the form available. 4a: Profile storage fails after authentication succeeds → account creation is only partial; the current code supplies no user-facing recovery. |
| Postconditions | Authentication account and profile exist; shopper is signed out at the sign-in feature. |

## UC2: Sign in

| Part | Content |
|---|---|
| Name | Sign in |
| Primary actor | Returning shopper |
| Stakeholders & interests | Shopper: secure, prompt access to saved shopping information. Service owner: reject invalid credentials and protect account data. |
| Preconditions | Shopper is signed out and has an existing account. |
| Trigger | Shopper chooses to sign in. |
| Main success scenario | 1. Shopper provides account credentials. 2. System validates the credentials. 3. System authenticates the shopper. 4. System makes the shopper's protected shopping features available. |
| Extensions | 2a: Email format is invalid → system reports an invalid email without authenticating. 2b: Password is shorter than six characters → system reports the minimum length. 3a: Credentials are rejected or authentication is unavailable → system displays the authentication failure and remains at sign-in. 3b: Shopper submits while a request is active → submission control remains unavailable until the request finishes. |
| Postconditions | Shopper is authenticated and can access protected shopping features. |

## UC3: Sign out

| Part | Content |
|---|---|
| Name | Sign out |
| Primary actor | Authenticated shopper |
| Stakeholders & interests | Shopper: prevent later users of the device from seeing the account. System owner: clear user-scoped local data. |
| Preconditions | Shopper is signed in. |
| Trigger | Shopper chooses to sign out. |
| Main success scenario | 1. Shopper requests sign-out. 2. System ends the authenticated session. 3. System removes the shopper's account-specific information from the current session. 4. System makes sign-in available. |
| Extensions | 2a: Sign-out fails → the shopper remains signed in and receives no explicit explanation. 4a: The signed-out state is detected before the normal transition completes → system still makes sign-in available. |
| Postconditions | No user is authenticated locally; protected routes redirect to sign-in. |

## UC4: Resume saved shopping session

| Part | Content |
|---|---|
| Name | Resume saved shopping session |
| Primary actor | Returning shopper |
| Stakeholders & interests | Shopper: recover the correct basket and WIC usage for this account. System owner: keep one user's data isolated from another's. |
| Preconditions | Shopper has just authenticated; a user identifier is available. |
| Trigger | Authentication state changes to signed in. |
| Main success scenario | 1. System identifies the returning shopper. 2. System retrieves the shopper's saved basket and benefit usage. 3. System restores the shopper's current selections and quantities. 4. System restores the associated product and benefit information. 5. System makes the restored shopping session available. |
| Extensions | 2a: No saved information exists → system starts a new empty shopping session. 2b: Saved balances or basket information is missing → system restores the available information and substitutes empty values for the rest. 2c: Retrieval fails → system finishes loading but provides no user-facing recovery. 4a: A saved product lacks nutrition information → system substitutes zero-valued nutrition fields. 4b: The saved activity is from an earlier month or year → system clears the basket, resets used benefits, and saves the new-month state. |
| Postconditions | Current-month saved state, or a new empty state, is loaded for the authenticated shopper. |

## UC5: Identify product by barcode

| Part | Content |
|---|---|
| Name | Identify product by barcode |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: identify a product without typing its code. Retailer: receive an accurate UPC. |
| Preconditions | Shopper is signed in; camera access and product lookup are available. |
| Trigger | Shopper presents a product barcode for identification. |
| Main success scenario | 1. Shopper presents the product barcode. 2. System reads the product code. 3. System searches for a matching product record. 4. System identifies the matching product. 5. System presents the product and its available nutrition information. 6. System makes healthier alternatives available for comparison. |
| Extensions | 1a: Shopper cancels barcode capture → system ends the attempt without identifying a product. 2a: No readable code is detected → system remains ready for another attempt. 2b: Another product identification is already being processed → system ignores the new detection. 3a: Product code has no matching record → system reports that it was not found and clears prior product details. 3b: Product lookup fails → system reports the failure and becomes ready again. |
| Postconditions | A matching product is available for review and possible addition; no basket change has occurred. |

## UC6: Identify product by UPC

| Part | Content |
|---|---|
| Name | Identify product by UPC |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: check a product when camera scanning is unavailable or inconvenient. Product-data owner: receive the intended code. |
| Preconditions | Shopper is signed in and product lookup is available. |
| Trigger | Shopper types a UPC and requests a check. |
| Main success scenario | 1. Shopper provides a product code. 2. System searches for a matching product record. 3. System identifies the matching product. 4. System presents the product and its available nutrition information. 5. System makes healthier alternatives available for comparison. |
| Extensions | 1a: Entry is empty → system performs no lookup. 2a: Product code has no matching record → system reports “not found” and shows no product details. 2b: Lookup fails → system reports the error. 2c: Another lookup is already active → system ignores the additional request. |
| Postconditions | A matching product is available for review and possible addition; no basket change has occurred. |

## UC7: Review product nutrition

| Part | Content |
|---|---|
| Name | Review product nutrition |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: quickly understand relevant nutritional qualities. Nutrition-data provider: values should be interpreted consistently. |
| Preconditions | A product lookup has returned a record. |
| Trigger | Shopper reviews an identified product. |
| Main success scenario | 1. System evaluates the product's available nutrition information. 2. System presents the nutritional qualities that apply to the product. 3. Shopper reviews the summary. |
| Extensions | 1a: A nutrient is absent or nonnumeric → system substitutes zero. 1b: Missing values become zero and may therefore produce a low-fat, low-sodium, low-sugar, low-calorie, or heart-healthy assessment even though the value is unknown. 2a: No nutrition rule matches → system displays no nutritional-quality label. 2b: More than three rules match → system presents only the first three in the summary. |
| Postconditions | Shopper has seen the nutrition summary for the selected product; product and basket are unchanged. |

## UC8: Compare healthier alternatives

| Part | Content |
|---|---|
| Name | Compare healthier alternatives |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: find a healthier WIC-eligible option in the same category. Approved-product data owner: comparisons use available nutrient data. |
| Preconditions | A product with a nonempty category has been found. |
| Trigger | Shopper asks to view the available healthier alternatives. |
| Main success scenario | 1. Shopper requests healthier alternatives for the identified product. 2. System compares it with eligible products in the same category. 3. System identifies products with a better nutrition assessment. 4. System ranks the qualifying alternatives. 5. System presents up to five alternatives. 6. Shopper reviews the comparison. |
| Extensions | 1a: Product category is empty → system does not search. 3a: No candidate has a better score → system reports no healthier alternatives. 1b: Search fails → system reports an error and removes the loading state. 2a: Nutrient data is absent → scoring treats the missing amounts as zero, which may distort the ranking. 5a: No alternatives are loaded → the comparison action is unavailable. |
| Postconditions | Shopper has seen up to five code-ranked healthier alternatives; basket is unchanged. |

## UC9: Add product to basket

| Part | Content |
|---|---|
| Name | Add product to basket |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: place an eligible product in the basket. Benefit program: enforce category allowance. System owner: persist basket and usage together. |
| Preconditions | Shopper is signed in; a product has been found; its category is below the current limit. |
| Trigger | Shopper chooses to add the found product. |
| Main success scenario | 1. Shopper chooses an identified product. 2. System confirms that the product can be added under the shopper's current benefit allowance. 3. System adds one unit to the basket. 4. System updates the shopper's benefit usage. 5. System saves and confirms the addition. |
| Extensions | 1a: No product is selected → system reports that no product is available to add. 2a: Category limit is already reached → system prevents the covered addition and warns the shopper. 3a: The same product is already in the basket → system follows the quantity-increase flow instead of creating a duplicate selection. 5a: Saving fails → the current session may show the addition even though it was not preserved, and the shopper receives no recovery guidance. |
| Postconditions | Product quantity and its category's used count each increase by one and are scheduled to persist. |

## UC10: Add healthier alternative

| Part | Content |
|---|---|
| Name | Add healthier alternative |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: choose a healthier replacement without rescanning. Benefit program: retain category-limit rules. |
| Preconditions | Healthier alternatives have been loaded and displayed; shopper is signed in. |
| Trigger | Shopper chooses the add action beside an alternative. |
| Main success scenario | 1. Shopper selects a healthier alternative. 2. System confirms that the alternative can be added under the shopper's current benefit allowance. 3. System adds the alternative to the basket. 4. System updates the shopper's benefit usage. 5. System saves and confirms the addition. |
| Extensions | 2a: Alternative category is already at its cap → system may reject the addition but still report success. 3a: The same alternative is already in the basket → system increases its quantity rather than creating a duplicate selection. 3b: The shopper is no longer authenticated → system rejects the addition but may still report success. |
| Postconditions | On actual success, selected alternative and corresponding usage are in the shopper's saved basket. |

## UC11: Scan receipt

| Part | Content |
|---|---|
| Name | Scan receipt |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: identify recorded products from a receipt with less manual entry. Receipt-reading provider: receive a supported image and request. Product-data owner: validate extracted codes. |
| Preconditions | Shopper is signed in; an image source, network, receipt-reading service, and product lookup are available. |
| Trigger | Shopper chooses to scan a receipt. |
| Main success scenario | 1. Shopper chooses to provide a receipt image. 2. Shopper supplies the image. 3. System reads the receipt contents. 4. System identifies potential product codes. 5. System checks the codes for matching product records. 6. System presents the unique matching products and a recognition summary. |
| Extensions | 1a: Shopper closes the source choice → scan is abandoned without changing prior results. 2a: Shopper cancels image selection → scanning stops. 3a: OCR service rejects or fails the request → system displays the exception as status. 4a: Text contains no candidate → system explains that no 12–14 digit code was found. 5a: Candidates exist but none match → system reports candidate count and zero valid items. 5b: Candidate or a 12-digit window duplicates an already found UPC → system lists it only once. |
| Postconditions | Zero or more unique matched products from the receipt are available for review; basket is unchanged. |

## UC12: Add receipt products

| Part | Content |
|---|---|
| Name | Add receipt products |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: transfer recognized purchases into the tracked basket. Benefit program: apply category limits. |
| Preconditions | Receipt scanning found at least one matching product; shopper is signed in. |
| Trigger | Shopper chooses to add the recognized products. |
| Main success scenario | 1. Shopper requests that the recognized products be added. 2. System evaluates each unique recognized product against the shopper's current allowances. 3. System adds each accepted product to the basket. 4. System updates the corresponding benefit usage. 5. System reports the accepted additions and presents the updated basket. |
| Extensions | 2a: Product information lacks nutrition values → system substitutes zero values. 3a: A recognized product is already in the basket → system increases its quantity, but the reported addition count omits that increase. 3b: A product category is at its cap → system rejects that product and continues with the remaining products. 5a: Saving fails → system may still present the locally updated basket without explaining that the changes were not preserved. |
| Postconditions | Every accepted product is present in the basket and affects its category usage; shopper sees the basket. |

## UC13: Review basket

| Part | Content |
|---|---|
| Name | Review basket |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: verify selected products and quantities before checkout. Benefit program: distinguish WIC and paid quantities. |
| Preconditions | Shopper is signed in. |
| Trigger | Shopper opens the basket. |
| Main success scenario | 1. Shopper requests the current basket. 2. System presents each selected product, its quantity, category, and available nutrition summary. 3. System presents the total selected quantity. 4. Shopper reviews the basket. |
| Extensions | 1a: Basket is empty → system explains that it is empty and offers to start scanning. 2a: Nutrition is missing from a line → system substitutes zero-valued nutrition. 2b: One UPC has both WIC and `PAID` lines → system presents them as separate category lines. |
| Postconditions | Shopper has seen the current basket; no quantity or balance changes. |

## UC14: Review basket nutrition

| Part | Content |
|---|---|
| Name | Review basket nutrition |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: inspect numerical nutrition facts for a selected basket product. Nutrition-data provider: preserve the stored values. |
| Preconditions | Basket contains the product. |
| Trigger | Shopper asks to show nutritional information for a basket line. |
| Main success scenario | 1. Shopper selects a basket product for nutritional review. 2. System presents the product's available nutrition facts. 3. Shopper reviews the values. 4. Shopper returns to the basket summary. |
| Extensions | 2a: Stored nutrition information is absent → system displays zero defaults. 2b: A particular nutrition value is absent → system displays `null` rather than identifying the value as unknown. 4a: Shopper does not return to the summary → nutrition details remain visible while the current product view is retained. |
| Postconditions | Shopper has inspected the selected line's stored nutrition; basket is unchanged. |

## UC15: Increase product quantity

| Part | Content |
|---|---|
| Name | Increase product quantity |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: add another unit of an existing product. Benefit program: keep covered quantity within the category allowance. |
| Preconditions | Product has a WIC basket line; its category has unused allowance. |
| Trigger | Shopper requests one more unit. |
| Main success scenario | 1. Shopper requests another unit of a basket product. 2. System confirms that the product remains within the shopper's benefit allowance. 3. System increases the selected quantity by one. 4. System updates the shopper's benefit usage. 5. System saves and presents the updated basket. |
| Extensions | 1a: Shopper is no longer authenticated → system ignores the request. 2a: Category allowance has been exhausted → continue with UC16, Buy excess quantity. 3a: Matching product cannot be found → system makes no quantity change but still behaves as though an update was processed. 5a: Saving fails → the displayed quantity may differ from the saved quantity with no explicit recovery. |
| Postconditions | WIC line quantity and corresponding used-benefit count each increase by one. |

## UC16: Buy excess quantity

| Part | Content |
|---|---|
| Name | Buy excess quantity |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: buy another unit after WIC coverage is exhausted. Benefit program: do not count the extra unit as covered. Retailer: treat it as customer-paid. |
| Preconditions | Product already has a WIC basket line; its category allowance is full. |
| Trigger | Shopper requests one more unit of that product. |
| Main success scenario | 1. Shopper requests another unit after the product's WIC allowance is exhausted. 2. System identifies the additional unit as shopper-paid. 3. System adds one shopper-paid unit to the basket. 4. System leaves the covered benefit usage unchanged. 5. System saves and presents the covered and shopper-paid quantities. |
| Extensions | 1a: Shopper attempts to add a different product after its category is full → system prevents the addition instead of treating it as shopper-paid. 3a: A shopper-paid quantity for the same product already exists → system increases it instead of creating a duplicate selection. 3b: The original covered product cannot be found → system adds nothing. 5a: Shopper reviews benefits after adding the unit → the shopper-paid quantity appears as an unlimited category even though it is not a WIC benefit. |
| Postconditions | One additional unit exists under `PAID`; the capped WIC category's used count is unchanged. |

## UC17: Decrease product quantity

| Part | Content |
|---|---|
| Name | Decrease product quantity |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: correct an over-selection. Benefit program: release covered usage only when a covered unit is removed. |
| Preconditions | Basket contains the product. |
| Trigger | Shopper requests removal of one unit. |
| Main success scenario | 1. Shopper requests removal of one unit of a basket product. 2. System identifies the applicable selected quantity. 3. System decreases that quantity by one. 4. System adjusts benefit usage when a covered unit is removed. 5. System saves and presents the updated basket. |
| Extensions | 1a: A paid line exists for that UPC → system reduces or removes paid quantity before touching the WIC line. 1b: No paid line exists → system reduces the requested WIC-category line. 1c: Neither matching line exists → no quantity changes. 3a: Recorded used count is already zero → clamping keeps it at zero. 5a: Persistence fails → local and saved state may diverge without a visible error. |
| Postconditions | Exactly one matching unit is removed when found; associated usage is not negative. |

## UC18: Clear basket

| Part | Content |
|---|---|
| Name | Clear basket |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: abandon every current selection in one action. Benefit program: release provisional category usage. |
| Preconditions | Basket contains at least one product. |
| Trigger | Shopper chooses to clear the basket and confirms. |
| Main success scenario | 1. Shopper requests removal of all basket selections. 2. System asks the shopper to confirm. 3. Shopper confirms the request. 4. System removes all selected products and reverses their provisional benefit usage. 5. System saves and presents the empty basket. |
| Extensions | 3a: Shopper cancels confirmation → system leaves the basket and benefit usage unchanged. 4a: A product category is absent from the shopper's balances → system removes the product without changing a category total. 4b: Recorded usage is smaller than the removed quantity → system keeps the resulting usage at zero. 5a: Saving fails → the current basket is empty but saved products may remain. |
| Postconditions | Local basket is empty and its provisional WIC/paid usage has been reversed. |

## UC19: Review benefit balances

| Part | Content |
|---|---|
| Name | Review benefit balances |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: know used versus allowed items by category. Benefit program: communicate limits accurately. |
| Preconditions | Shopper is signed in and state loading has completed. |
| Trigger | Shopper opens benefits. |
| Main success scenario | 1. Shopper requests current benefit information. 2. System presents each category's used and allowed quantities. 3. System distinguishes limited and unlimited categories. 4. System presents the shopper's remaining capacity. 5. Shopper reviews the balances. |
| Extensions | 1a: State is still loading → system displays progress instead of balances. 1b: No balance categories exist → system reports that benefit data is absent and suggests scanning. 3a: Used count reaches or exceeds allowed → progress is clamped to full. 3b: Allowed value is zero → the current percentage calculation risks division behavior not explicitly handled. 4a: `PAID` is present → it appears as an unlimited entry alongside benefit categories. |
| Postconditions | Shopper has seen the currently loaded balance data; no state changes. |

## UC20: Prepare checkout handoff

| Part | Content |
|---|---|
| Name | Prepare checkout handoff |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: hand the basket to a cashier and finish the shopping session. Cashier: receive a portable representation of every basket line. Benefit program: retain consumed usage after purchase. |
| Preconditions | Shopper is signed in and basket is nonempty. |
| Trigger | Shopper declares the basket ready for checkout. |
| Main success scenario | 1. Shopper requests a checkout handoff for the current basket. 2. System prepares a scannable representation of the selected products. 3. System presents the checkout handoff to the shopper. 4. Shopper presents it to the cashier. 5. Shopper marks the handoff as finished. 6. System clears the basket, retains consumed benefit usage, and confirms completion. |
| Extensions | 2a: Basket information cannot be represented in a scannable form → system provides no explicit fallback. 4a: Cashier cannot accept the handoff → system provides no acknowledgement or interoperability check. 5a: Shopper leaves before marking the handoff finished → basket and benefit usage remain unchanged. 5b: Shopper marks the handoff finished without cashier confirmation → system still clears the basket. 6a: Saving fails → the basket may be cleared only for the current session, and completion may not be confirmed. |
| Postconditions | Basket is empty in saved state; category used counts continue to represent purchased quantities. |

## Production evidence map

This map is for checking the draft, not an extra use-case field.

| Use cases | Strongest evidence |
|---|---|
| UC1 | `Project3/lib/screens/signup_page.dart:46–78, 116–199` |
| UC2 | `Project3/lib/screens/login_screen.dart:38–56, 90–142` |
| UC3 | `Project3/lib/app_router.dart:130–183`; `Project3/lib/state/app_state.dart:75–99` |
| UC4 | `Project3/lib/state/app_state.dart:75–86, 195–212, 227–294` |
| UC5–UC6 | `Project3/lib/screens/scan_screen.dart:67–100, 121–162, 600–648` |
| UC7 | `Project3/lib/utils/nutritional_utils.dart:18–106`; `Project3/lib/widgets/nutritional_badges.dart:100–139` |
| UC8 | `Project3/lib/services/apl_service.dart:64–181`; `Project3/lib/screens/scan_screen.dart:205–360` |
| UC9–UC10 | `Project3/lib/screens/scan_screen.dart:164–203, 328–349`; `Project3/lib/state/app_state.dart:321–405` |
| UC11–UC12 | `Project3/lib/screens/receipt_scanner_screen.dart:25–213` |
| UC13–UC14 | `Project3/lib/screens/basket_screen.dart:91–390` |
| UC15–UC18 | `Project3/lib/state/app_state.dart:418–581`; `Project3/lib/screens/basket_screen.dart:289–331` |
| UC19 | `Project3/lib/screens/balances_screen.dart:35–237` |
| UC20 | `Project3/lib/screens/qr_checkout_screen.dart:12–62`; `Project3/lib/state/app_state.dart:556–563` |

## Known documentation contradiction excluded from the 20

The root README advertises “Track your orders in real-time.” No production
route, screen, state object, endpoint, or service for orders appears in this
commit. It must not become a use case unless another model finds concrete code
evidence that this pass missed.
