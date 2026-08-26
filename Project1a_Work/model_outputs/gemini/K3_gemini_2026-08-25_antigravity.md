Model: Gemini 3.1 Pro High
Runner: Antigravity
Date: 2026-08-25
Repository commit: 03bc584b9a4e03aa8eca51b872435d07b4e7009f
Prompt ID: K3

# K3 — Boundary and extension miner

| Boundary / Input Partition | Expected Behavior | Actual Ambiguity / Risk | Candidate Use Case Extension | File:Line Evidence |
|---|---|---|---|---|
| 1. Authentication: Login redirect latency | Authenticated users cannot access `/login` | `FirebaseAuth.currentUser` can be null immediately after login, redirecting valid users to `/login` momentarily. | Handle loading state in GoRouter guard. | `Project3/lib/app_router.dart:177` (EVIDENCE) |
| 2. UPC Lookup: Exact 12 vs 13 vs 14 digits | UPC is found if it matches exactly. | Receipt scanner uses regex `\b\d{12,14}\b` and tries all 12-char substrings. Manual entry has no length validation. | Trim manual UPC to 12 digits or validate length. | `Project3/lib/screens/receipt_scanner_screen.dart:138` (EVIDENCE) |
| 3. Nutrition Badges: totalFat = 3.0g | Gets Low Fat badge (<= 3). | Equality boundary works, but missing `totalFat` defaults to 0.0, falsely assigning Low Fat to empty data. | Graceful fallback for missing nutrition facts. | `Project3/lib/utils/nutritional_utils.dart:74` (EVIDENCE) |
| 4. Nutrition Badges: sodium = 140mg | Gets Low Sodium & Heart Healthy. | Missing sodium defaults to 0, falsely triggering Heart Healthy. | Add `hasNutritionData` flag. | `Project3/lib/utils/nutritional_utils.dart:79` (EVIDENCE) |
| 5. Nutrition Badges: wicEligible = null | Evaluates to false, badge hidden. | Correctly handled by `?? false`. | Display 'Eligibility Unknown' badge. | `Project3/lib/utils/nutritional_utils.dart:69` (EVIDENCE) |
| 6. Healthier Alts: Penalty score calculation | Higher penalty = worse score. | Trans fats carry 2.0 multiplier, saturated 1.0. Missing data defaults to 0, artificially lowering scores of foods with missing data. | Exclude foods with missing critical data from healthier alternatives. | `Project3/lib/services/apl_service.dart:111` (EVIDENCE) |
| 7. Healthier Alts: Base score equality | Only returns items strictly `< baseScore`. | If two items are identical in nutrition, no alternative is shown. | Include equal-score items if they cost less or have a different flavor. | `Project3/lib/services/apl_service.dart:162` (EVIDENCE) |
| 8. Healthier Alts: Self-match | Current product is excluded from alternatives. | Excludes by `fdcId` or `upc`. What if fdcId is null? | Ensure fdcId null check is robust. | `Project3/lib/services/apl_service.dart:156` (EVIDENCE) |
| 9. Basket Quantity: Category limit reached (Scan) | Cannot add item from Scan screen. | `canAdd` returns false, disabling Add button. | Inform user they can increment via basket to use PAID logic. | `Project3/lib/screens/scan_screen.dart:435` (EVIDENCE) |
| 10. Basket Quantity: Category limit reached (Basket) | Overflows to 'PAID' category. | Item splits into two lines (WIC + PAID). Decrement removes PAID first. | Combine view of WIC and PAID lines into one visual item. | `Project3/lib/state/app_state.dart:452` (EVIDENCE) |
| 11. WIC Caps: Case sensitivity | Caps check string contains (e.g. 'MILK'). | `_canon` converts to uppercase, but 'MILK' vs 'MILKS' is risky if pluralized. | Use strict taxonomy IDs instead of string parsing. | `Project3/lib/state/app_state.dart:133` (EVIDENCE) |
| 12. WIC Caps: 'PAID' category limits | `_deriveAllowed` returns null for 'PAID'. | 'PAID' is uncapped. | Allow user to set a budget limit on PAID items. | `Project3/lib/state/app_state.dart:124` (EVIDENCE) |
| 13. WIC Caps: Unknown categories | Falls through to return 2 items. | Some unexpected categories (e.g., 'CANDY') will default to 2 WIC allowed items. | Default to 0 (disallowed) for unknown categories. | `Project3/lib/state/app_state.dart:157` (EVIDENCE) |
| 14. Receipt OCR: API limits | Parses image > 25kb. | Code comments say API limits to 25kb sometimes. May fail silently or throw exception. | Add local image compression before sending to OCR. | `Project3/lib/screens/receipt_scanner_screen.dart:91` (INFERENCE) |
| 15. Receipt OCR: Multiple identical UPCs | Should add each to basket. | `_parseUPCs` only adds unique UPCs per receipt (`!validItems.any`). Ignores duplicates. | Increment quantity for duplicate UPCs found on receipt. | `Project3/lib/screens/receipt_scanner_screen.dart:151` (EVIDENCE) |
| 16. Persistence Rollover: Timezone shifts | Checks `last.month != now.month`. | If user travels across timezones, `now.month` can roll over early/late. | Use UTC for rollover checks instead of local time. | `Project3/lib/state/app_state.dart:199` (EVIDENCE) |
| 17. Persistence Rollover: Checkout timestamp | `updatedAt` set via `serverTimestamp()`. | `serverTimestamp` is asynchronous and uses server time, preventing client spoofing. | Sync UI to server time during rollover. | `Project3/lib/state/app_state.dart:308` (EVIDENCE) |
| 18. QR Checkout: Max data limit | Generates QR from JSON basket. | Large baskets will create a dense QR code that standard scanners cannot read. | Pass a transaction ID instead of JSON array. | `Project3/lib/screens/qr_checkout_screen.dart:14` (INFERENCE) |
| 19. QR Checkout: State clearing | Clears basket, persists, does NOT reset `used`. | Items are permanently "checked out" for the month. | Add a "History" view to show checked-out items. | `Project3/lib/state/app_state.dart:559` (EVIDENCE) |
| 20. Clear Basket: State clearing | Restores `used` balance. | Decrements `used` by item `qty`, clamping at 0. | Handle PAID category separately when clearing basket. | `Project3/lib/state/app_state.dart:574` (EVIDENCE) |
| 21. Decrement: Zero boundary | Removes item from array. | Item vanishes from UI instead of remaining at 0 quantity. | Keep item at 0 qty with a greyed-out state. | `Project3/lib/state/app_state.dart:524` (EVIDENCE) |
| 22. Basket: Missing Nutrition Data | Graceful degradation. | UI builds dummy nutrition map with 0.0s for missing data. | Display N/A for missing facts instead of 0g. | `Project3/lib/screens/basket_screen.dart:321` (EVIDENCE) |
| 23. AppState: _balancesLoaded flag | Controls spinner visibility. | Flag is only set true in `finally` block of `loadUserState`. If first load fails, spinner spins forever? No, `finally` executes. But UI shows empty data on error. | Show specific error state if load throws exception. | `Project3/lib/state/app_state.dart:291` (EVIDENCE) |
| 24. APL Service: findByUpc timeout | Document fetch takes too long. | Default Firestore timeout (10s) applies. Will freeze scan screen `_busy = true`. | Add manual timeout to `findByUpc` with fallback. | `Project3/lib/services/apl_service.dart:32` (INFERENCE) |
| 25. Healthier Alts: Max limit | Sorts by score, limits to `max` (5). | List sublist is safe due to `> max` check. | Paginate healthier options if many exist. | `Project3/lib/services/apl_service.dart:178` (EVIDENCE) |
