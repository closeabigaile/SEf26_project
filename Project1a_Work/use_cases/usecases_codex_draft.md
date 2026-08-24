# WolfBite: 20 main use cases — Codex draft

Status: independent production-code pass, before reading the inherited tests.
This is a draft to reconcile with Claude and Gemini, not the final team list.
The tables follow the course's required `usecases0.md` structure. Main success
scenarios contain only the happy path; all branching is in Extensions.

## UC1: Create account

| Part | Content |
|---|---|
| Name | Create account |
| Primary actor | New shopper |
| Stakeholders & interests | Shopper: obtain a usable account without losing profile details. Firebase administrators: valid, attributable accounts. |
| Preconditions | Shopper is signed out and can reach the registration feature. Authentication and profile services are available. |
| Trigger | Shopper chooses to create an account. |
| Main success scenario | 1. Shopper provides full name, email address, password, and street address. 2. System validates the entries. 3. System creates an authentication account. 4. System stores the shopper profile. 5. System signs the new account out. 6. System returns the shopper to sign-in. |
| Extensions | 2a: Name or address is blank → system identifies the required entry and does not submit. 2b: Email lacks an `@` → system rejects it as invalid. 2c: Password is shorter than six characters → system requests at least six. 3a: Authentication rejects the request (for example, duplicate email) → system displays the provider's failure and keeps the form available. 4a: Profile storage fails after authentication succeeds → account creation is only partial; the current code supplies no user-facing recovery. |
| Postconditions | Authentication account and profile exist; shopper is signed out at the sign-in feature. |

## UC2: Sign in

| Part | Content |
|---|---|
| Name | Sign in |
| Primary actor | Returning shopper |
| Stakeholders & interests | Shopper: secure, prompt access to saved shopping information. Firebase administrators: reject invalid credentials. |
| Preconditions | Shopper is signed out and has an existing account. |
| Trigger | Shopper chooses to sign in. |
| Main success scenario | 1. Shopper provides email and password. 2. System validates the entries. 3. System authenticates the credentials. 4. System opens product lookup. |
| Extensions | 2a: Email format is invalid → system reports an invalid email without authenticating. 2b: Password is shorter than six characters → system reports the minimum length. 3a: Credentials are rejected or authentication is unavailable → system displays the authentication failure and remains at sign-in. 3b: Shopper submits while a request is active → submission control remains unavailable until the request finishes. |
| Postconditions | Shopper is authenticated and can access protected shopping features. |

## UC3: Sign out

| Part | Content |
|---|---|
| Name | Sign out |
| Primary actor | Authenticated shopper |
| Stakeholders & interests | Shopper: prevent later users of the device from seeing the account. System owner: clear user-scoped local data. |
| Preconditions | Shopper is signed in. |
| Trigger | Shopper chooses sign-out from product lookup, basket, or benefits. |
| Main success scenario | 1. Shopper requests sign-out. 2. System ends the authentication session. 3. System clears the in-memory basket and benefit state. 4. System opens sign-in. |
| Extensions | 2a: Sign-out service fails → navigation does not complete and the code provides no explicit failure message. 3a: A route refresh observes the signed-out state before explicit navigation → the route guard still sends the shopper to sign-in. |
| Postconditions | No user is authenticated locally; protected routes redirect to sign-in. |

## UC4: Resume saved shopping session

| Part | Content |
|---|---|
| Name | Resume saved shopping session |
| Primary actor | Returning shopper |
| Stakeholders & interests | Shopper: recover the correct basket and WIC usage for this account. System owner: keep one user's data isolated from another's. |
| Preconditions | Shopper has just authenticated; a user identifier is available. |
| Trigger | Authentication state changes to signed in. |
| Main success scenario | 1. System identifies the shopper. 2. System retrieves the shopper's saved balance and basket record. 3. System normalizes category names. 4. System restores quantities, categories, and nutrition data. 5. System marks benefit data ready for display. |
| Extensions | 2a: No saved record exists → system starts empty and creates a record scaffold. 2b: Saved balances or basket fields are missing → system substitutes empty collections. 4a: A basket item lacks nutrition → system assigns zero-valued nutrition fields. 4b: The saved update is from an earlier month or year → system resets every used count, clears the basket, and persists the reset. 2c: Retrieval fails → loading is marked complete in `finally`, but the exception has no user-facing recovery in this layer. |
| Postconditions | Current-month saved state, or a new empty state, is loaded for the authenticated shopper. |

## UC5: Scan product barcode

| Part | Content |
|---|---|
| Name | Scan product barcode |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: identify a product without typing its code. Retailer: receive an accurate UPC. |
| Preconditions | Shopper is signed in; camera access and approved-product lookup are available. |
| Trigger | Shopper presents a barcode to the camera scanner. |
| Main success scenario | 1. Shopper positions the barcode for capture. 2. System reads the first detected code. 3. System looks up that UPC in the approved product list. 4. System records the matching product. 5. System displays its name, category, UPC, and nutrition badges. 6. System begins looking for healthier alternatives. |
| Extensions | 1a: Shopper opens the wide-screen camera dialog and cancels → system closes it without a lookup. 2a: Detection contains no raw code → system remains ready to scan. 2b: Another scan is already being processed → system ignores the new detection. 3a: UPC has no approved-product record → system reports that it was not found and clears product details. 3b: Lookup throws an error → system displays the error and becomes ready again. |
| Postconditions | A matching product is available for review and possible addition; no basket change has occurred. |

## UC6: Enter product UPC

| Part | Content |
|---|---|
| Name | Enter product UPC |
| Primary actor | Desktop or web shopper |
| Stakeholders & interests | Shopper: check a product when camera scanning is unavailable or inconvenient. Approved-product data owner: receive the intended code. |
| Preconditions | Shopper is signed in and approved-product lookup is available. |
| Trigger | Shopper types a UPC and requests a check. |
| Main success scenario | 1. Shopper enters a UPC. 2. System trims surrounding whitespace. 3. System looks up the UPC in the approved product list. 4. System records the matching product. 5. System displays product and nutrition information. 6. System begins looking for healthier alternatives. |
| Extensions | 1a: Entry is empty → system performs no lookup. 3a: UPC is absent from the approved list → system reports “not found” and shows no product details. 3b: Lookup fails → system reports the error. 3c: A lookup is already active → system ignores the additional request. |
| Postconditions | A matching product is available for review and possible addition; no basket change has occurred. |

## UC7: Review product nutrition

| Part | Content |
|---|---|
| Name | Review product nutrition |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: quickly understand relevant nutritional qualities. Nutrition-data provider: values should be interpreted consistently. |
| Preconditions | A product lookup has returned a record. |
| Trigger | System presents the matched product. |
| Main success scenario | 1. System extracts energy, fats, sodium, sugars, protein, fiber, and WIC eligibility from the product record. 2. System compares values with badge thresholds. 3. System presents up to three applicable compact badges with labels available as tooltips. 4. Shopper reviews the product's nutritional qualities. |
| Extensions | 1a: A nutrient is absent or nonnumeric → system substitutes zero. 2a: No badge rule matches → system displays no badges. 2b: More than three rules match → compact presentation displays only the first three. 1b: Missing values become zero and may therefore earn low-fat, low-sodium, low-sugar, low-calorie, or heart-healthy badges; the current code does not distinguish “unknown” from zero. |
| Postconditions | Shopper has seen the nutrition summary for the selected product; product and basket are unchanged. |

## UC8: Compare healthier alternatives

| Part | Content |
|---|---|
| Name | Compare healthier alternatives |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: find a healthier WIC-eligible option in the same category. Approved-product data owner: comparisons use available nutrient data. |
| Preconditions | A product with a nonempty category has been found. |
| Trigger | Shopper asks to view the available healthier alternatives. |
| Main success scenario | 1. System compares the product with eligible products in the same category. 2. System scores candidates using energy, sugar, sodium, fat, fiber, and protein. 3. System keeps candidates with a lower score than the selected product. 4. System orders candidates from lowest score upward and limits the list to five. 5. System presents each alternative's name, category, UPC, and score. 6. Shopper reviews the comparison. |
| Extensions | 1a: Product category is empty → system does not search. 3a: No candidate has a better score → system reports no healthier alternatives. 1b: Search fails → system reports an error and removes the loading state. 2a: Nutrient data is absent → scoring treats the missing amounts as zero, which may distort the ranking. 5a: No alternatives are loaded → the comparison action is unavailable. |
| Postconditions | Shopper has seen up to five code-ranked healthier alternatives; basket is unchanged. |

## UC9: Add scanned product

| Part | Content |
|---|---|
| Name | Add scanned product |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: place an eligible product in the basket. Benefit program: enforce category allowance. System owner: persist basket and usage together. |
| Preconditions | Shopper is signed in; a product has been found; its category is below the current limit. |
| Trigger | Shopper chooses to add the found product. |
| Main success scenario | 1. System normalizes the product category and initializes its allowance when first encountered. 2. System creates a basket line with UPC, name, category, quantity one, and nutrition. 3. System increments used benefits for the category. 4. System saves basket and balances. 5. System confirms the addition and clears the current lookup. |
| Extensions | 1a: Category limit is already reached → scan-screen add control is unavailable and a warning is shown. 2a: Same UPC already exists → system follows the quantity-increase flow rather than creating a new line. 2b: No product is selected → system reports that nothing has been scanned. 1b: No user is authenticated → state rejects the addition. 4a: Asynchronous persistence fails → the UI has already changed and this path supplies no visible recovery. |
| Postconditions | Product quantity and its category's used count each increase by one and are scheduled to persist. |

## UC10: Add healthier alternative

| Part | Content |
|---|---|
| Name | Add healthier alternative |
| Primary actor | Health-conscious shopper |
| Stakeholders & interests | Shopper: choose a healthier replacement without rescanning. Benefit program: retain category-limit rules. |
| Preconditions | Healthier alternatives have been loaded and displayed; shopper is signed in. |
| Trigger | Shopper chooses the add action beside an alternative. |
| Main success scenario | 1. Shopper selects an alternative. 2. System extracts its UPC, name, category, and nutrition. 3. System adds it to the basket. 4. System updates category usage and persists state. 5. System closes the comparison and confirms the named alternative. |
| Extensions | 3a: Alternative category is already at its cap → state may reject a new line, but the current screen ignores the return value and still reports success. 3b: Same UPC already exists → system increases that product rather than creating a new line. 3c: No authenticated user exists → state rejects the addition, while the screen still reports success. |
| Postconditions | On actual success, selected alternative and corresponding usage are in the shopper's saved basket. |

## UC11: Scan receipt

| Part | Content |
|---|---|
| Name | Scan receipt |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: recover eligible purchases from a receipt with less manual entry. OCR provider: receive a supported image and request. Approved-product data owner: validate extracted codes. |
| Preconditions | Shopper is signed in; an image source, network, OCR service, and approved-product lookup are available. |
| Trigger | Shopper chooses to scan a receipt. |
| Main success scenario | 1. Shopper chooses gallery/upload or camera. 2. Shopper supplies a receipt image. 3. System sends the image for English OCR. 4. System extracts 12–14 digit candidates from recognized text. 5. System checks each candidate, including 12-digit windows of longer candidates, against the approved list. 6. System displays unique matching WIC products and a recognition summary. |
| Extensions | 1a: Shopper closes the source choice → scan is abandoned without changing prior results. 2a: Shopper cancels image selection → scanning stops. 3a: OCR service rejects or fails the request → system displays the exception as status. 4a: Text contains no candidate → system explains that no 12–14 digit code was found. 5a: Candidates exist but none match → system reports candidate count and zero valid items. 5b: Candidate or a 12-digit window duplicates an already found UPC → system lists it only once. |
| Postconditions | Zero or more unique approved products from the receipt are available for review; basket is unchanged. |

## UC12: Add receipt products

| Part | Content |
|---|---|
| Name | Add receipt products |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: transfer recognized purchases into the tracked basket. Benefit program: apply category limits. |
| Preconditions | Receipt scanning found at least one approved product; shopper is signed in. |
| Trigger | Shopper chooses to add the recognized products. |
| Main success scenario | 1. System processes each unique recognized product. 2. System builds nutrition data for it. 3. System adds it to the basket and updates its category usage. 4. System reports how many new lines were added. 5. System opens the basket. |
| Extensions | 3a: A UPC already exists → state increases its quantity, but because `addItem` returns false for that path, the displayed “Added” count excludes the increase. 3b: A category is at its cap → state rejects a new line and processing continues with the remaining products. 3c: Product data lacks nutrition → zero values are used. 3d: State persistence fails asynchronously → screen still navigates to the locally updated basket. |
| Postconditions | Every accepted product is present in the basket and affects its category usage; shopper sees the basket. |

## UC13: Review basket

| Part | Content |
|---|---|
| Name | Review basket |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: verify selected products and quantities before checkout. Benefit program: distinguish WIC and paid quantities. |
| Preconditions | Shopper is signed in. |
| Trigger | Shopper opens the basket. |
| Main success scenario | 1. System retrieves the current basket. 2. System presents each line's quantity, name, category, and compact nutrition badges. 3. System totals quantities across all lines. 4. Shopper reviews the selections and total. |
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
| Main success scenario | 1. System expands the product's nutrition section. 2. System presents calories, total and saturated fat, sodium, total sugars, and protein. 3. Shopper reviews the values. 4. Shopper hides the details when finished. |
| Extensions | 1a: Stored nutrition map is absent → system displays zero defaults. 2a: A particular field is absent inside a present nutrition map → interpolation displays `null` for that field rather than an unknown marker. 4a: Shopper leaves details open → they remain expanded while that line's widget state survives. |
| Postconditions | Shopper has inspected the selected line's stored nutrition; basket is unchanged. |

## UC15: Increase covered quantity

| Part | Content |
|---|---|
| Name | Increase covered quantity |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: add another unit of an existing product. Benefit program: keep covered quantity within the category allowance. |
| Preconditions | Product has a WIC basket line; its category has unused allowance. |
| Trigger | Shopper requests one more unit. |
| Main success scenario | 1. System normalizes and checks the product category. 2. System finds the matching UPC and category line. 3. System increases its quantity by one. 4. System increases the category's used count by one. 5. System persists and displays the updated state. |
| Extensions | 2a: Matching line cannot be found → system makes no quantity change but still schedules persistence and notification. 1a: No shopper is authenticated → request is ignored. 1b: Category allowance has been exhausted → UC16, Buy excess quantity. 5a: Persistence fails → local display may differ from saved state with no explicit recovery. |
| Postconditions | WIC line quantity and corresponding used-benefit count each increase by one. |

## UC16: Buy excess quantity

| Part | Content |
|---|---|
| Name | Buy excess quantity |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: buy another unit after WIC coverage is exhausted. Benefit program: do not count the extra unit as covered. Retailer: treat it as customer-paid. |
| Preconditions | Product already has a WIC basket line; its category allowance is full. |
| Trigger | Shopper requests one more unit of that product. |
| Main success scenario | 1. System detects that the WIC category is full. 2. System establishes an uncapped `PAID` category. 3. System copies the product identity and nutrition to a paid line. 4. System records one paid unit. 5. System persists and displays separate WIC and paid quantities. |
| Extensions | 3a: A paid line for the same UPC already exists → system increments it instead of creating another. 3b: Original WIC line cannot be found → system cannot copy product details and adds nothing. 1a: Shopper attempts to add a different, newly scanned UPC after its category is full → scan UI disables addition rather than creating a paid line. 5a: The benefits screen also lists `PAID` as an unlimited category, even though it is not a WIC benefit. |
| Postconditions | One additional unit exists under `PAID`; the capped WIC category's used count is unchanged. |

## UC17: Decrease product quantity

| Part | Content |
|---|---|
| Name | Decrease product quantity |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: correct an over-selection. Benefit program: release covered usage only when a covered unit is removed. |
| Preconditions | Basket contains the product. |
| Trigger | Shopper requests removal of one unit. |
| Main success scenario | 1. System identifies the product line to reduce. 2. System decreases its quantity. 3. System decreases the corresponding category used count without going below zero. 4. System removes the line when its quantity reaches zero. 5. System persists and displays the update. |
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
| Main success scenario | 1. System asks the shopper to confirm complete removal. 2. Shopper confirms. 3. System subtracts every line's quantity from its category used count without going below zero. 4. System removes all basket lines. 5. System persists and displays the empty basket. |
| Extensions | 2a: Shopper cancels confirmation → system leaves basket and balances unchanged. 3a: A line's category is absent from balances → system removes the line without changing a category counter. 3b: Recorded usage is smaller than removed quantity → system clamps it to zero. 5a: Persistence fails asynchronously → local basket is empty but saved data may remain. |
| Postconditions | Local basket is empty and its provisional WIC/paid usage has been reversed. |

## UC19: Review benefit balances

| Part | Content |
|---|---|
| Name | Review benefit balances |
| Primary actor | WIC shopper |
| Stakeholders & interests | Shopper: know used versus allowed items by category. Benefit program: communicate limits accurately. |
| Preconditions | Shopper is signed in and state loading has completed. |
| Trigger | Shopper opens benefits. |
| Main success scenario | 1. System retrieves current category balances. 2. System presents each category's used and allowed quantities. 3. System presents progress for capped categories. 4. System labels uncapped categories as unlimited. 5. Shopper reviews remaining capacity. |
| Extensions | 1a: State is still loading → system displays progress instead of balances. 1b: No balance categories exist → system reports that benefit data is absent and suggests scanning. 3a: Used count reaches or exceeds allowed → progress is clamped to full. 3b: Allowed value is zero → the current percentage calculation risks division behavior not explicitly handled. 4a: `PAID` is present → it appears as an unlimited entry alongside benefit categories. |
| Postconditions | Shopper has seen the currently loaded balance data; no state changes. |

## UC20: Complete QR checkout

| Part | Content |
|---|---|
| Name | Complete QR checkout |
| Primary actor | Shopper |
| Stakeholders & interests | Shopper: hand the basket to a cashier and finish the shopping session. Cashier: receive a portable representation of every basket line. Benefit program: retain consumed usage after purchase. |
| Preconditions | Shopper is signed in and basket is nonempty. |
| Trigger | Shopper declares the basket ready for checkout. |
| Main success scenario | 1. System serializes the current basket into a QR code. 2. Shopper presents the code to the cashier. 3. Cashier scans or otherwise accepts the handoff. 4. Shopper marks the transaction finished. 5. System clears and persists the basket while retaining category used counts. 6. System confirms completion and returns to product lookup. |
| Extensions | 2a: Shopper leaves the checkout screen before finishing → basket and balances remain unchanged. 1a: Basket payload is too large or cannot be encoded → the current screen provides no explicit fallback. 3a: Cashier cannot consume the app-specific JSON payload → the application provides no acknowledgement or interoperability check. 4a: Shopper marks finished without cashier confirmation → code still clears the basket. 5a: Persistence fails → completion has no caught error and navigation may not occur. |
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
