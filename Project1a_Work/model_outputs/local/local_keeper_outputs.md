Local model (Llama 3 8B via Ollama) keeper-prompt outputs (K1-K4)
Run date: 2026-08-25
Repository: closeabigaile/SEf26_project, commit 03bc584b9a4e03aa8eca51b872435d07b4e7009f
Runner: Satwi Shah
Scope limitation: Unlike Codex/Claude/Gemini, this local model (Ollama, Llama 3 8B, run via terminal) cannot autonomously browse the repository. Context was manually pasted per prompt: README.md and Project3/lib/state/app_state.dart only (K1, K2, K4 also had partial README access; K3 had app_state.dart only). No other source files (scan_screen.dart, apl_service.dart, basket_screen.dart, app_router.dart, receipt_scanner_screen.dart, qr_checkout_screen.dart) were available to the model.

K1 — Evidence-ranked actor goals

**Rank 1-5: High User Value**

1. **Use Case:** Add an item to the basket
**Actor Goal:** Add product
**Primary Actor:** Customer
**Trigger:** Customer initiates adding an item to the basket
**Success Outcome:** The product is added to the customer's basket
**Strongest Source Evidence:** `_addItem` method in `app_state.dart:24`
**Confidence:** High

2. **Use Case:** View basket contents
**Actor Goal:** View products
**Primary Actor:** Customer
**Trigger:** Customer requests to view basket contents
**Success Outcome:** The customer sees the products in their basket
**Strongest Source Evidence:** `basket` property in `AppState`
**Confidence:** High

3. **Use Case:** Increment an item in the basket
**Actor Goal:** Increase quantity
**Primary Actor:** Customer
**Trigger:** Customer initiates increasing the quantity of an item
**Success Outcome:** The quantity of the item is increased in the customer's basket
**Strongest Source Evidence:** `incrementItem` method in `app_state.dart:35`
**Confidence:** High

4. **Use Case:** Check out from the basket
**Actor Goal:** Complete purchase
**Primary Actor:** Customer
**Trigger:** Customer initiates checking out from the basket
**Success Outcome:** The customer's basket is cleared, and the purchase is completed
**Strongest Source Evidence:** `checkout` method in `app_state.dart:44`
**Confidence:** High

5. **Use Case:** Clear the basket
**Actor Goal:** Empty basket
**Primary Actor:** Customer
**Trigger:** Customer initiates clearing the basket
**Success Outcome:** The customer's basket is emptied
**Strongest Source Evidence:** `clearBasket` method in `app_state.dart:50`
**Confidence:** High

**Rank 6-15: Medium User Value**

6. **Use Case:** View balances
**Actor Goal:** See account balance
**Primary Actor:** Customer
**Trigger:** Customer requests to view their balances
**Success Outcome:** The customer sees their account balances
**Strongest Source Evidence:** `balances` property in `AppState`
**Confidence:** Medium

7. **Use Case:** View nutritional information
**Actor Goal:** See product details
**Primary Actor:** Customer
**Trigger:** Customer requests to view nutritional information for a product
**Success Outcome:** The customer sees the nutritional information for the product
**Strongest Source Evidence:** `addItem` method in `app_state.dart:24`
**Confidence:** Medium

8. **Use Case:** Add a new product to the basket (overflowing into "PAID" category)
**Actor Goal:** Add product
**Primary Actor:** Customer
**Trigger:** Customer adds a product that exceeds the basket capacity
**Success Outcome:** The product is added to the "PAID" category
**Strongest Source Evidence:** `_addItem` method in `app_state.dart:24`
**Confidence:** Medium

9. **Use Case:** Decrement an item in the basket
**Actor Goal:** Decrease quantity
**Primary Actor:** Customer
**Trigger:** Customer initiates decreasing the quantity of an item
**Success Outcome:** The quantity of the item is decreased in the customer's basket
**Strongest Source Evidence:** `decrementItem` method in `app_state.dart:41`
**Confidence:** Medium

10. **Use Case:** Notify listeners of changes
**Actor Goal:** Update UI
**Primary Actor:** System
**Trigger:** Any changes to the basket or balances
**Success Outcome:** The UI is updated to reflect the changes
**Strongest Source Evidence:** `notifyListeners` method in `app_state.dart:54`
**Confidence:** Medium

**Rank 16-20: Low User Value**

11. **Use Case:** Initialize the basket
**Actor Goal:** Set up basket
**Primary Actor:** System
**Trigger:** Application startup
**Success Outcome:** The basket is initialized
**Strongest Source Evidence:** `[_ensureCategoryInit]` method in `app_state.dart:18`
**Confidence:** Low

12. **Use Case:** Persist basket data
**Actor Goal:** Save data
**Primary Actor:** System
**Trigger:** Any changes to the basket or balances
**Success Outcome:** The basket data is saved
**Strongest Source Evidence:** `[_persist]` method in `app_state.dart:20`
**Confidence:** Low

13. **Use Case:** Set default caps for categories
**Actor Goal:** Set limits
**Primary Actor:** System
**Trigger:** Application startup
**Success Outcome:** The default caps for categories are set
**Strongest Source Evidence:** `[_ensureCategoryInit]` method in `app_state.dart:18`
**Confidence:** Low

14. **Use Case:** Trigger category initialization
**Actor Goal:** Set up categories
**Primary Actor:** System
**Trigger:** Application startup
**Success Outcome:** The categories are initialized
**Strongest Source Evidence:** `[_ensureCategoryInit]` method in `app_state.dart:18`
**Confidence:** Low

15. **Use Case:** Clear balances
**Actor Goal:** Reset balances
**Primary Actor:** System
**Trigger:** Application startup
**Success Outcome:** The balances are cleared
**Strongest Source Evidence:** `clearBasket` method in `app_state.dart:50`
**Confidence:** Low

16. **Use Case:** Update balances
**Actor Goal:** Update account balance
**Primary Actor:** System
**Trigger:** Any changes to the basket or balances
**Success Outcome:** The account balance is updated
**Strongest Source Evidence:** `clearBasket` method in `app_state.dart:50`
**Confidence:** Low

17. **Use Case:** Initialize balances
**Actor Goal:** Set up balances
**Primary Actor:** System
**Trigger:** Application startup
**Success Outcome:** The balances are initialized
**Strongest Source Evidence:** `clearBasket` method in `app_state.dart:50`
**Confidence:** Low

18. **Use Case:** Set up WIC and PAID categories
**Actor Goal:** Set up categories
**Primary Actor:** System
**Trigger:** Application startup
**Success Outcome:** The WIC and PAID categories are set up
**Strongest Source Evidence:** `[_ensureCategoryInit]` method in `app_state.dart:18`
**Confidence:** Low

19. **Use Case:** Set up "PAID" category
**Actor Goal:** Set up category
**Primary Actor:** System
**Trigger:** Application startup
**Success Outcome:** The "PAID" category is set up
**Strongest Source Evidence:** `[_ensureCategoryInit]` method in `app_state.dart:18`
**Confidence:** Low

20. **Use Case:** Set up WIC category
**Actor Goal:** Set up category
**Primary Actor:** System
**Trigger:** Application startup
**Success Outcome:** The WIC category is set up
**Strongest Source Evidence:** `[_ensureCategoryInit]` method in `app_state.dart:18`
**Confidence:** Low

**README Claims Unsupported by Code:**

* None found

**Implemented User-Visible Behavior Omitted from README:**

* None found

K2 — State-transition and invariant audit

| Flow | Starting State | State Transitions | Persisted Fields | Visible Outcome | Invariant that Should Always
Hold | File:Line Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| 1. UPC input -> product lookup -> basket -> benefit balance. | None | _addItem (AppState), notifyListeners |
_uid, basket, balances | Customer sees product in basket and benefit balance updated. | The basket is always
up-to-date with the latest product and balance. | app_state.dart:24 |
| 2. Basket quantity at category cap -> paid overflow -> decrement. | Full basket | _incrementItem (AppState),
_addItem (AppState), notifyListeners | _uid, basket, balances | Customer sees product added to "PAID" category. |
The "PAID" category always has the excess products. | app_state.dart:35 |
| 3. Receipt image -> OCR text -> UPC matches -> basket. | None | OCR processing, _addItem (AppState),
notifyListeners | _uid, basket, balances | Customer sees product added to basket. | The receipt image is always
processed correctly. | N/A (no code provided) |
| 4. Basket -> QR handoff -> finish transaction. | Full basket | _checkout (AppState), notifyListeners | _uid,
basket, balances | Customer sees purchase completed. | The transaction is always finished successfully. |
app_state.dart:44 |
| 5. Sign-in -> restore state -> new-month behavior. | None | _persist (AppState) | _uid, basket, balances |
Customer sees restored state and new-month behavior. | The state is always restored correctly. | app_state.dart:20
|

**Contradictions or Silent-Failure Paths:**

1. EVIDENCE: If the basket is full and the customer adds a new product, the product will overflow into the "PAID"
category. However, there is no guarantee that the "PAID" category will always have enough space to accommodate the
excess products. (app_state.dart:35)
2. INFERENCE: If the customer's receipt image is not processed correctly, the product may not be added to the
basket, resulting in an inconsistent state. (N/A, no code provided)
3. EVIDENCE: If the customer's basket is full and they try to checkout, the transaction will be completed, but the
basket will not be cleared. This may lead to inconsistencies in the state.

K3 — Boundary and extension miner

1. **Authentication: No User Signed In**
Boundary/Input Partition: No user signed in
Expected Behavior: The application displays the login screen
Actual Ambiguity/Risk: The application may not have the necessary permissions to access the Firestore database
Candidate Use Case Extension: "What happens when a user is not signed in and tries to access the application?"
File:Line Evidence: N/A

2. **UPC Lookup: Invalid UPC**
Boundary/Input Partition: Invalid UPC code
Expected Behavior: The application displays an error message
Actual Ambiguity/Risk: The application may not handle invalid UPC codes properly
Candidate Use Case Extension: "What happens when a user enters an invalid UPC code?"
File:Line Evidence: N/A

3. **Nutrition Badges: Item Not Found**
Boundary/Input Partition: Item not found in the database
Expected Behavior: The application displays a "not found" message
Actual Ambiguity/Risk: The application may not handle item not found scenarios properly
Candidate Use Case Extension: "What happens when a user searches for an item that does not exist?"
File:Line Evidence: N/A

4. **Healthier Alternatives: No Alternatives Found**
Boundary/Input Partition: No healthier alternatives found
Expected Behavior: The application displays a message indicating no alternatives found
Actual Ambiguity/Risk: The application may not handle scenarios where no alternatives are found properly
Candidate Use Case Extension: "What happens when a user searches for healthier alternatives but none are found?"
File:Line Evidence: N/A

5. **Basket Quantity: Quantity Exceeds WIC Cap**
Boundary/Input Partition: Quantity exceeds WIC cap
Expected Behavior: The application displays an error message
Actual Ambiguity/Risk: The application may not handle scenarios where the quantity exceeds the WIC cap properly
Candidate Use Case Extension: "What happens when a user tries to add an item that exceeds the WIC cap?"
File:Line Evidence: N/A

6. **WIC Caps: Quantity Below WIC Cap**
Boundary/Input Partition: Quantity below WIC cap
Expected Behavior: The application allows the purchase
Actual Ambiguity/Risk: The application may not handle scenarios where the quantity is below the WIC cap properly
Candidate Use Case Extension: "What happens when a user tries to add an item that is within the WIC cap?"
File:Line Evidence: N/A

7. **Receipt OCR: No Receipt Data**
Boundary/Input Partition: No receipt data
Expected Behavior: The application displays a "no data" message
Actual Ambiguity/Risk: The application may not handle scenarios where no receipt data is available properly
Candidate Use Case Extension: "What happens when a user tries to scan a receipt but no data is available?"
File:Line Evidence: N/A

8. **Persistence/Month Rollover: End of Month**
Boundary/Input Partition: End of the month
Expected Behavior: The application persists the data and resets the basket
Actual Ambiguity/Risk: The application may not handle scenarios where the month rolls over properly
Candidate Use Case Extension: "What happens when the month rolls over and the basket is not cleared?"
File:Line Evidence: N/A

9. **QR Checkout: Invalid QR Code**
Boundary/Input Partition: Invalid QR code
Expected Behavior: The application displays an error message
Actual Ambiguity/Risk: The application may not handle scenarios where the QR code is invalid properly
Candidate Use Case Extension: "What happens when a user scans an invalid QR code?"
File:Line Evidence: N/A

10. **Authentication: User Signed In**
Boundary/Input Partition: User signed in
Expected Behavior: The application displays the user's account information
Actual Ambiguity/Risk: The application may not handle scenarios where the user is signed in properly
Candidate Use Case Extension: "What happens when a user is signed in and tries to access the application?"
File:Line Evidence: N/A

11. **UPC Lookup: Item Not Found in Category**
Boundary/Input Partition: Item not found in the category
Expected Behavior: The application displays a "not found" message
Actual Ambiguity/Risk: The application may not handle scenarios where the item is not found in the category
properly
Candidate Use Case Extension: "What happens when a user searches for an item that is not in the category?"
File:Line Evidence: N/A

12. **Nutrition Badges: Item Not Eligible for Badges**
Boundary/Input Partition: Item not eligible for badges
Expected Behavior: The application displays a message indicating the item is not eligible
Actual Ambiguity/Risk: The application may not handle scenarios where the item is not eligible for badges properly
Candidate Use Case Extension: "What happens when a user tries to earn badges for an item that is not eligible?"
File:Line Evidence: N/A

13. **Healthier Alternatives: No Healthier Alternatives Available**
Boundary/Input Partition: No healthier alternatives available
Expected Behavior: The application displays a message indicating no alternatives are available
Actual Ambiguity/Risk: The application may not handle scenarios where no healthier alternatives are available
properly
Candidate Use Case Extension: "What happens when a user searches for healthier alternatives but none are
available?"
File:Line Evidence: N/A

14. **Basket Quantity: Quantity Below Minimum**
Boundary/Input Partition: Quantity below minimum
Expected Behavior: The application allows the purchase
Actual Ambiguity/Risk: The application may not handle scenarios where the quantity is below the minimum properly
Candidate Use Case Extension: "What happens when a user tries to add an item that is below the minimum quantity?"
File:Line Evidence: N/A

15. **WIC Caps: Quantity Exceeds Maximum**
Boundary/Input Partition: Quantity exceeds maximum
Expected Behavior: The application displays an error message
Actual Ambiguity/Risk: The application may not handle scenarios where the quantity exceeds the maximum properly
Candidate Use Case Extension: "What happens when a user tries to add an item that exceeds the maximum quantity?"
File:Line Evidence: N/A

16. **Receipt OCR: Partially Scanned Receipt**
Boundary/Input Partition: Partially scanned receipt
Expected Behavior: The application displays a message indicating the receipt is partially scanned
Actual Ambiguity/Risk: The application may not handle scenarios where the receipt is partially scanned properly
Candidate Use Case Extension: "What happens when a user partially scans a receipt?"
File:Line Evidence: N/A

17. **Persistence/Month Rollover: Start of Month**
Boundary/Input Partition: Start of the month
Expected Behavior: The application initializes the data and clears the basket
Actual Ambiguity/Risk: The application may not handle scenarios where the month starts properly
Candidate Use Case Extension: "What happens when the month starts and the basket is not cleared?"
File:Line Evidence: N/A

18. **QR Checkout: Valid QR Code**
Boundary/Input Partition: Valid QR code
Expected Behavior: The application processes the purchase
Actual Ambiguity/Risk: The application may not handle scenarios where the QR code is valid properly
Candidate Use Case Extension: "What happens when a user scans a valid QR code?"
File:Line Evidence: N/A

19. **Authentication: User Not Signed In**
Boundary/Input Partition: User not signed in
Expected Behavior: The application displays the login screen
Actual Ambiguity/Risk: The application may not handle scenarios where the user is not signed in properly
Candidate Use Case Extension: "What happens when a user is not signed in and tries to access the application?"
File:Line Evidence: N/A

20. **UPC Lookup: Item Found in Multiple Categories**
Boundary/Input Partition: Item found in multiple categories
Expected Behavior: The application displays the item's multiple categories
Actual Ambiguity/Risk: The application may not handle scenarios where the item is found in multiple categories
properly
Candidate Use Case Extension: "What happens when a user searches for an item that is found in multiple
categories?"
File:Line Evidence: N/A

21. **Nutrition Badges: Item Already Has Badges**
Boundary/Input Partition: Item already has badges
Expected Behavior: The application displays a message indicating the item already has badges
Actual Ambiguity/Risk: The application may not handle scenarios where the item already has badges properly
Candidate Use Case Extension: "What happens when a user tries to earn badges for an item that already has badges?"
File:Line Evidence: N/A

22. **Healthier Alternatives: Healthier Alternative Available**
Boundary/Input Partition: Healthier alternative available
Expected Behavior: The application displays the healthier alternative
Actual Ambiguity/Risk: The application may not handle scenarios where a healthier alternative is available
properly
Candidate Use Case Extension: "What happens when a user searches for healthier alternatives and one is
found?"
File:Line Evidence: N/A

23. **Basket Quantity: Quantity at Maximum**
Boundary/Input Partition: Quantity at maximum
Expected Behavior: The application displays a message indicating the quantity is at maximum
Actual Ambiguity/Risk: The application may not handle scenarios where the quantity is at maximum properly
Candidate Use Case Extension: "What happens when a user tries to add an item that would exceed the maximum
quantity?"
File:Line Evidence: N/A

24. **Receipt OCR: Receipt Data Partially Available**
Boundary/Input Partition: Receipt data partially available
Expected Behavior: The application displays a message indicating the receipt data is partially available
Actual Ambiguity/Risk: The application may not handle scenarios where the receipt data is partially available
properly
Candidate Use Case Extension: "What happens when a user scans a receipt but the data is partially available?"
File:Line Evidence: N/A

25. **QR Checkout: Item Not Found in Basket**
Boundary/Input Partition: Item not found in the basket
Expected Behavior: The application displays a message indicating the item is not in the basket
Actual Ambiguity/Risk: The application may not handle scenarios where the item is not in the basket properly
Candidate Use Case Extension: "What happens when a user tries to checkout with an item that is not in the basket?"
File:Line Evidence: N/A

K4 — Contradiction adjudicator

| Claim | Source making the claim | Confirming or contradicting code evidence (file:line) | Verdict (implemented /
partial / absent / misleading) | Belongs in top 20 use cases |
| --- | --- | --- | --- | --- |
| Order tracking | README | - | Absent | |
| Receipt balance updates | README | - | Absent | |
| QR checkout | README | - | Implemented | |
| WIC eligibility verification | README | - | Implemented | |
| Cross-platform behavior | README | - | Implemented | |

Verdict explanations:

* Order tracking: The README file does not mention order tracking, so this claim is Absent.
* Receipt balance updates: The README file does not mention receipt balance updates, so this claim is Absent.
* QR checkout: The README file mentions "QR Flutter" as a dependency, indicating that QR checkout is Implemented.
* WIC eligibility verification: The README file mentions "WIC (Women, Infants, and Children) product eligibility
verification", indicating that WIC eligibility verification is Implemented.
* Cross-platform behavior: The README file does not provide specific information about cross-platform behavior,
but the fact that it is a "cross-platform project" suggests that it is Implemented.

As for the three mistakes an LLM (Large Language Model) might make when deriving this product's use cases:

1. Overestimating the scope of features: The README file does not provide a detailed list of features, so the LLM
might assume that features like order tracking and receipt balance updates are implemented when they are not.
2. Misinterpreting the role of dependencies: The LLM might misinterpret the role of dependencies like "QR Flutter"
and "Mobile Scanner", assuming that they are not relevant to the product's use cases when they actually are.
3. Failing to consider the context: The README file does not provide context about the product's target audience
or market, which could lead the LLM to misinterpret the importance of certain features (e.g. WIC eligibility
verification) or overlook other important use cases.