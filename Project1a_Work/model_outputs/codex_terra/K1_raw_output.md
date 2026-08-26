# K1 — Evidence-ranked actor goals

**Model:** GPT-5.6-terra  
**Interface:** OpenAI Codex CLI  
**GitHub user:** supreme1022
**Date:** August 25, 2026  
**Prompt ID:** K1 — Evidence-ranked actor goals  
**Repository commit:** `03bc584b9a4e03aa8eca51b872435d07b4e7009f`

> Ranked by apparent end-user value; evidence is production code only (tests excluded).

---

## 1. Look up product eligibility

- **Primary actor:** WIC shopper
- **Trigger:** Scans a barcode or submits a UPC
- **Success outcome:** The app displays the matched APL product or reports that its UPC is absent.
- **Strongest evidence:** `Project3/lib/screens/scan_screen.dart:130`
- **Confidence:** High

## 2. Add product to basket

- **Primary actor:** WIC shopper
- **Trigger:** Selects Add after a product lookup
- **Success outcome:** The product is added with its category, quantity, and nutrition data.
- **Strongest evidence:** `Project3/lib/screens/scan_screen.dart:171`
- **Confidence:** High

## 3. Review benefit balances

- **Primary actor:** WIC shopper
- **Trigger:** Opens WIC Benefits
- **Success outcome:** Per-category used and allowed quantities, including unlimited categories, are shown.
- **Strongest evidence:** `Project3/lib/screens/balances_screen.dart:44`
- **Confidence:** High

## 4. Review shopping basket

- **Primary actor:** Shopper
- **Trigger:** Opens My Basket
- **Success outcome:** Current basket lines and their aggregate item count are displayed.
- **Strongest evidence:** `Project3/lib/screens/basket_screen.dart:98`
- **Confidence:** High

## 5. Adjust product quantity

- **Primary actor:** Shopper
- **Trigger:** Presses a basket line’s plus or minus control
- **Success outcome:** The product quantity and corresponding usage are updated, with zero-quantity lines removed.
- **Strongest evidence:** `Project3/lib/screens/basket_screen.dart:368`
- **Confidence:** High

## 6. Check category capacity

- **Primary actor:** WIC shopper
- **Trigger:** Looks up a product whose category may be at its cap
- **Success outcome:** The app indicates when that product’s category limit has been reached.
- **Strongest evidence:** `Project3/lib/screens/scan_screen.dart:612`
- **Confidence:** High

## 7. Add excess quantity as paid

- **Primary actor:** Shopper
- **Trigger:** Increases an existing item after its WIC category is full
- **Success outcome:** The extra unit is represented in a PAID basket line rather than increasing covered usage.
- **Strongest evidence:** `Project3/lib/state/app_state.dart:451`
- **Confidence:** High

## 8. Clear shopping basket

- **Primary actor:** Shopper
- **Trigger:** Confirms Clear All
- **Success outcome:** All basket items are removed and their recorded category usage is reduced.
- **Strongest evidence:** `Project3/lib/screens/basket_screen.dart:207`
- **Confidence:** High

## 9. Scan receipt

- **Primary actor:** WIC shopper
- **Trigger:** Selects a receipt image from gallery/upload or camera
- **Success outcome:** OCR-extracted 12–14 digit candidates are matched against APL products and shown.
- **Strongest evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:29`
- **Confidence:** High

## 10. Add receipt products

- **Primary actor:** WIC shopper
- **Trigger:** Selects Add to Basket for recognized receipt items
- **Success outcome:** Recognized APL products are added to the basket and the shopper is taken to it.
- **Strongest evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:169`
- **Confidence:** High

## 11. Generate checkout QR code

- **Primary actor:** Shopper
- **Trigger:** Selects Ready to Checkout with a nonempty basket
- **Success outcome:** A QR code encoding the current basket JSON is displayed.
- **Strongest evidence:** `Project3/lib/screens/qr_checkout_screen.dart:12`
- **Confidence:** High

## 12. Complete checkout transaction

- **Primary actor:** Shopper
- **Trigger:** Selects Finish Transaction from the QR screen
- **Success outcome:** The basket is cleared, persisted, and a completion message is shown.
- **Strongest evidence:** `Project3/lib/screens/qr_checkout_screen.dart:34`
- **Confidence:** High

## 13. Review product nutrition

- **Primary actor:** Health-conscious shopper
- **Trigger:** Views a scanned product result
- **Success outcome:** Nutritional badges derived from the product’s nutrients are shown.
- **Strongest evidence:** `Project3/lib/screens/scan_screen.dart:594`
- **Confidence:** High

## 14. Inspect basket-item nutrition

- **Primary actor:** Health-conscious shopper
- **Trigger:** Expands a basket item’s nutritional information
- **Success outcome:** Calories, fats, sodium, sugars, and protein values become visible.
- **Strongest evidence:** `Project3/lib/screens/basket_screen.dart:387`
- **Confidence:** High

## 15. Compare healthier alternatives

- **Primary actor:** Health-conscious shopper
- **Trigger:** Looks up a product with healthier same-category options
- **Success outcome:** Up to five lower-scoring eligible alternatives are offered.
- **Strongest evidence:** `Project3/lib/services/apl_service.dart:139`
- **Confidence:** High

## 16. Add healthier alternative

- **Primary actor:** Health-conscious shopper
- **Trigger:** Selects an alternative’s add control
- **Success outcome:** The chosen alternative is added to the basket.
- **Strongest evidence:** `Project3/lib/screens/scan_screen.dart:367`
- **Confidence:** High

## 17. Create account

- **Primary actor:** New shopper
- **Trigger:** Submits a valid registration form
- **Success outcome:** A Firebase account and Firestore profile containing name, email, and address are created, then the shopper returns to login.
- **Strongest evidence:** `Project3/lib/screens/signup_page.dart:46`
- **Confidence:** High

## 18. Sign in

- **Primary actor:** Returning shopper
- **Trigger:** Submits valid email/password credentials
- **Success outcome:** Firebase authenticates the shopper and opens the scan screen.
- **Strongest evidence:** `Project3/lib/screens/login_screen.dart:38`
- **Confidence:** High

## 19. Resume shopping state

- **Primary actor:** Returning shopper
- **Trigger:** Authentication state changes to signed in
- **Success outcome:** The shopper’s persisted basket and balances are loaded for the authenticated user.
- **Strongest evidence:** `Project3/lib/state/app_state.dart:75`
- **Confidence:** High

## 20. Sign out

- **Primary actor:** Authenticated shopper
- **Trigger:** Presses a logout control
- **Success outcome:** Authentication ends and route/state handling returns the shopper to login.
- **Strongest evidence:** `Project3/lib/screens/balances_screen.dart:35`
- **Confidence:** High

---

# README Claims Unsupported or Overstated by Code

- **“Food delivery application”** is unsupported: the implemented route inventory contains authentication, scan, basket, balances, and receipt features—not restaurant ordering, delivery, drivers, or delivery status.  
  **Evidence:** `README.md:22`, `README.md:37`, `Project3/lib/app_router.dart:65`

- **“Track your orders in real-time”** is unsupported: no order or tracking module/route exists.  
  **Evidence:** `README.md:76`, `Project3/lib/app_router.dart:65`

- Receipt import **“automatically check-out[s] each item”** is unsupported: OCR finds APL products, then the shopper explicitly adds them to the basket; checkout is separate.  
  **Evidence:** `README.md:67`, `Project3/lib/screens/receipt_scanner_screen.dart:169`

- **“WIC eligibility verification”** is overstated: lookup treats an existing APL document as a product result, without checking its `eligible` field in the lookup flow.  
  **Evidence:** `README.md:41`, `Project3/lib/services/apl_service.dart:31`

---

# Implemented User-Visible Behavior Omitted from the README

- WIC category caps, contextual cap warnings, and PAID overflow for additional quantity.  
  **Evidence:** `Project3/lib/state/app_state.dart:122`, `Project3/lib/state/app_state.dart:451`

- Per-category balance cards with usage progress and unlimited-category indicators.  
  **Evidence:** `Project3/lib/screens/balances_screen.dart:64`

- Saved basket/balance restoration and automatic reset of usage/basket when a new month is detected.  
  **Evidence:** `Project3/lib/state/app_state.dart:227`

- Manual UPC entry on wider layouts, alongside camera scanning.  
  **Evidence:** `Project3/lib/screens/scan_screen.dart:688`

- Basket clearing, quantity removal, and explicit sign-out controls.  
  **Evidence:** `Project3/lib/screens/basket_screen.dart:207`, `Project3/lib/screens/balances_screen.dart:53`