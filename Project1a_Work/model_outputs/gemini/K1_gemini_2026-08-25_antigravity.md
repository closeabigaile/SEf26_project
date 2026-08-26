Model: Gemini 3.1 Pro High
Runner: Antigravity
Date: 2026-08-25
Repository commit: 03bc584b9a4e03aa8eca51b872435d07b4e7009f
Prompt ID: K1

# K1 — Evidence-ranked actor goals

## Top 20 Candidate Use Cases

1. **Check WIC eligibility by scanning barcode**
   - **Primary actor:** Shopper
   - **Trigger:** Camera detects a barcode inside the square
   - **Success outcome:** The item's WIC eligibility and details are displayed on screen.
   - **Evidence:** `Project3/lib/screens/scan_screen.dart:413`
   - **Confidence:** High

2. **Check WIC eligibility by manual UPC**
   - **Primary actor:** Shopper
   - **Trigger:** User enters a 12-14 digit UPC and presses 'Check'
   - **Success outcome:** The item's WIC eligibility and details are retrieved.
   - **Evidence:** `Project3/lib/screens/scan_screen.dart:714`
   - **Confidence:** High

3. **Add scanned item to basket**
   - **Primary actor:** Shopper
   - **Trigger:** User clicks "Add to Basket" on a checked item
   - **Success outcome:** The item is added to the user's basket and their category usage is incremented.
   - **Evidence:** `Project3/lib/screens/scan_screen.dart:188`
   - **Confidence:** High

4. **View healthier alternatives**
   - **Primary actor:** Shopper
   - **Trigger:** User clicks the green leaf/eco icon on a scanned product
   - **Success outcome:** A list of nutritionally superior substitutes is displayed.
   - **Evidence:** `Project3/lib/screens/scan_screen.dart:586`
   - **Confidence:** High

5. **Swap for healthier alternative**
   - **Primary actor:** Shopper
   - **Trigger:** User clicks the add icon on a healthier substitute option
   - **Success outcome:** The healthier substitute is added to the basket instead of the originally scanned item.
   - **Evidence:** `Project3/lib/screens/scan_screen.dart:374`
   - **Confidence:** High

6. **Upload receipt image for parsing**
   - **Primary actor:** Shopper
   - **Trigger:** User clicks "Select Image" and selects an image source
   - **Success outcome:** Image is uploaded and analyzed for 12-14 digit UPC codes.
   - **Evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:214`
   - **Confidence:** High

7. **Add receipt items to basket**
   - **Primary actor:** Shopper
   - **Trigger:** User clicks "Add to Basket" after receipt OCR results are shown
   - **Success outcome:** All successfully parsed WIC items are added to the shopping basket.
   - **Evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:173`
   - **Confidence:** High

8. **Increase basket item quantity**
   - **Primary actor:** Shopper
   - **Trigger:** User clicks the '+' icon next to a basket item
   - **Success outcome:** The item's quantity and the category usage are incremented.
   - **Evidence:** `Project3/lib/screens/basket_screen.dart:381`
   - **Confidence:** High

9. **Decrease basket item quantity**
   - **Primary actor:** Shopper
   - **Trigger:** User clicks the '-' icon next to a basket item
   - **Success outcome:** The item's quantity is decreased, and removed from the basket if quantity reaches zero.
   - **Evidence:** `Project3/lib/screens/basket_screen.dart:372`
   - **Confidence:** High

10. **View basket summary**
    - **Primary actor:** Shopper
    - **Trigger:** User navigates to the Basket tab
    - **Success outcome:** The user sees a list of all basket items and the total item count.
    - **Evidence:** `Project3/lib/screens/basket_screen.dart:103`
    - **Confidence:** High

11. **Clear all basket items**
    - **Primary actor:** Shopper
    - **Trigger:** User clicks "Clear Cart" and confirms
    - **Success outcome:** All items are removed from the basket and category usages are restored.
    - **Evidence:** `Project3/lib/screens/basket_screen.dart:223`
    - **Confidence:** High

12. **View expanded nutritional facts**
    - **Primary actor:** Shopper
    - **Trigger:** User clicks "Show Nutritional Info" on a basket item
    - **Success outcome:** Detailed nutrition facts (calories, fat, sodium, sugar, etc.) are displayed.
    - **Evidence:** `Project3/lib/screens/basket_screen.dart:389`
    - **Confidence:** High

13. **Generate QR checkout code**
    - **Primary actor:** Shopper
    - **Trigger:** User clicks "Ready to Checkout" in the basket screen
    - **Success outcome:** A QR code representing the JSON-encoded basket is displayed.
    - **Evidence:** `Project3/lib/screens/qr_checkout_screen.dart:14`
    - **Confidence:** High

14. **Complete transaction / checkout**
    - **Primary actor:** Shopper
    - **Trigger:** User clicks "Finish Transaction" on the QR checkout screen
    - **Success outcome:** The basket is cleared and the transaction is committed permanently for the month.
    - **Evidence:** `Project3/lib/screens/qr_checkout_screen.dart:35`
    - **Confidence:** High

15. **View WIC benefit balances**
    - **Primary actor:** Shopper
    - **Trigger:** User navigates to the Benefits tab
    - **Success outcome:** A color-coded progress bar indicates usage against limits for each category.
    - **Evidence:** `Project3/lib/screens/balances_screen.dart:44`
    - **Confidence:** High

16. **Auto-reset monthly balances**
    - **Primary actor:** System
    - **Trigger:** User state is loaded and last update timestamp is in a previous month
    - **Success outcome:** Usage balances are reset to 0 and the basket is cleared.
    - **Evidence:** `Project3/lib/state/app_state.dart:285`
    - **Confidence:** High

17. **Overflow category limits to Paid**
    - **Primary actor:** System
    - **Trigger:** User increments an item quantity when the WIC category cap is reached
    - **Success outcome:** A new item is added under the "PAID" category instead of the original WIC category.
    - **Evidence:** `Project3/lib/state/app_state.dart:452`
    - **Confidence:** High

18. **Log out of account**
    - **Primary actor:** Shopper
    - **Trigger:** User clicks the logout icon in the app bar
    - **Success outcome:** The session is terminated and the user is redirected to the login screen.
    - **Evidence:** `Project3/lib/screens/balances_screen.dart:35`
    - **Confidence:** High

19. **Sign up for new account**
    - **Primary actor:** Shopper
    - **Trigger:** User submits the registration form (assumed)
    - **Success outcome:** A new Firebase authentication record is created and user enters the app.
    - **Evidence:** `Project3/lib/app_router.dart:78`
    - **Confidence:** Medium

20. **Login to account**
    - **Primary actor:** Shopper
    - **Trigger:** User submits credentials (assumed)
    - **Success outcome:** User is authenticated and navigated to the main scan shell.
    - **Evidence:** `Project3/lib/app_router.dart:72`
    - **Confidence:** Medium

## Unsupported Claims & Omitted Behaviors

**(a) README claims unsupported by code**
- **"Order Management: Track your orders in real-time"** — There is no order tracking interface, order status repository, or real-time map in the source code.

**(b) Implemented user-visible behavior omitted from the README**
- **Manual UPC input entry** — Desktop/web versions provide a manual text field for entering 12-14 digit UPC codes when a camera is not available.
- **Monthly Balance Auto-Rollover** — The app silently checks if the user's `updatedAt` timestamp is from a previous month upon login, automatically resetting their category usages to 0 if so.
- **Paid Overflow Mechanics** — When a user exceeds their WIC limit for a specific category, the app quietly categorizes the excess items as "PAID" rather than blocking the addition outright.
