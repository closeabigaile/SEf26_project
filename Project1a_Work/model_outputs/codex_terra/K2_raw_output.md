# K2 — State-transition and invariant audit

**Model:** GPT-5.6-terra  
**Interface:** OpenAI Codex CLI  
**GitHub user:** supreme1022
**Date:** August 25, 2026  
**Prompt ID:** K2 — State-transition and invariant audit  
**Repository commit:** `03bc584b9a4e03aa8eca51b872435d07b4e7009f`

---

## Flow 1 — UPC → lookup → basket → balance

- **Starting state — EVIDENCE:** Authenticated user; no active lookup; a scanned or entered UPC is available.
- **State transitions — EVIDENCE:** UPC is trimmed, looked up in APL, stored as the current result, then Add constructs nutrition and calls `addItem`; a new line increments that category’s used count.
- **Persisted fields — EVIDENCE:** Balances, basket, and server `updatedAt` are written to `users/{uid}`.
- **Visible outcome — EVIDENCE:** A missing UPC produces a snackbar; Add always displays an “Added …” snackbar and clears the current result.
- **Invariant — INFERENCE:** For each category, used should equal the quantity represented by its basket lines and should not exceed a capped category’s allowance.
- **File:line evidence:** `Project3/lib/screens/scan_screen.dart:130`, `Project3/lib/screens/scan_screen.dart:171`, `Project3/lib/state/app_state.dart:347`, `Project3/lib/state/app_state.dart:303`

---

## Flow 2 — Quantity at cap → paid overflow → decrement

- **Starting state — EVIDENCE:** Authenticated user has an existing product line and its original category is at its limit.
- **State transitions — EVIDENCE:** Increment detects the full original category and creates/increments a same-UPC PAID line; decrement searches for and reduces the paid line before the covered line.
- **Persisted fields — EVIDENCE:** Updated basket, balances, and `updatedAt` are persisted after each operation.
- **Visible outcome — EVIDENCE:** Basket controls remain enabled at the cap and change their tooltip to “Will add as paid.”
- **Invariant — INFERENCE:** Covered usage should remain at or below its cap, and a decrement should remove paid overflow before reducing WIC-covered quantity.
- **File:line evidence:** `Project3/lib/screens/basket_screen.dart:368`, `Project3/lib/state/app_state.dart:431`, `Project3/lib/state/app_state.dart:502`, `Project3/lib/state/app_state.dart:303`

---

## Flow 3 — Receipt image → OCR → UPC matches → basket

- **Starting state — EVIDENCE:** Authenticated user selects the receipt route and has a receipt image available from gallery/upload or camera.
- **State transitions — EVIDENCE:** The image is base64-encoded, posted to OCR.space, parsed for contiguous 12–14 digit candidates, matched against APL records, deduplicated, and passed to `addItem` only after the shopper selects Add to Basket.
- **Persisted fields — EVIDENCE:** OCR itself persists nothing; Add to Basket persists the normal basket/balance state.
- **Visible outcome — EVIDENCE:** The UI displays recognition status and matched products, then reports Added N items and opens the basket.
- **Invariant — INFERENCE:** Each unique recognized UPC should be offered once, and the displayed added count should equal the number of successful basket additions.
- **File:line evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:29`, `Project3/lib/screens/receipt_scanner_screen.dart:124`, `Project3/lib/screens/receipt_scanner_screen.dart:169`, `Project3/lib/state/app_state.dart:303`

---

## Flow 4 — Basket → QR handoff → finish transaction

- **Starting state — EVIDENCE:** Authenticated user has a nonempty basket and opens checkout.
- **State transitions — EVIDENCE:** The current basket is JSON-encoded into a QR image; Finish calls checkout, which clears the in-memory basket and awaits persistence.
- **Persisted fields — EVIDENCE:** The persisted basket becomes empty; balances are retained; `updatedAt` is refreshed.
- **Visible outcome — EVIDENCE:** The app displays a green completion snackbar and returns to Scan after checkout resolves.
- **Invariant — INFERENCE:** Checkout should retain already-recorded benefit usage while removing only pending basket lines.
- **File:line evidence:** `Project3/lib/screens/qr_checkout_screen.dart:12`, `Project3/lib/screens/qr_checkout_screen.dart:34`, `Project3/lib/state/app_state.dart:556`, `Project3/lib/state/app_state.dart:303`

---

## Flow 5 — Sign-in → restore state → new month

- **Starting state — EVIDENCE:** A shopper submits valid credentials; Firebase returns a user.
- **State transitions — EVIDENCE:** Login navigates to Scan; the auth-state provider calls `updateUser`, which asynchronously loads `users/{uid}`, canonicalizes saved balances/basket, and resets usage plus basket when `updatedAt` belongs to a prior month or year.
- **Persisted fields — EVIDENCE:** Restored state is read from balances, basket, and `updatedAt`; a first-time user scaffold and a monthly reset are persisted.
- **Visible outcome — EVIDENCE:** Login opens Scan; balance-dependent views remain loading until `balancesLoaded` becomes true.
- **Invariant — INFERENCE:** State shown after loading should belong only to the signed-in UID; after a month/year boundary every used value should be zero and the basket empty.
- **File:line evidence:** `Project3/lib/screens/login_screen.dart:38`, `Project3/lib/main.dart:93`, `Project3/lib/state/app_state.dart:75`, `Project3/lib/state/app_state.dart:227`, `Project3/lib/state/app_state.dart:195`

---

# Contradictions or Silent-Failure Paths

### 1. Eligibility value is not checked

**EVIDENCE:** UPC lookup does not check an APL record’s `eligible` value; it accepts any existing document, despite UI/docs framing the result as WIC eligibility.

**Evidence:** `Project3/lib/services/apl_service.dart:31`, `Project3/lib/screens/scan_screen.dart:130`

### 2. Scan-based Add always reports success

**EVIDENCE:** Scan-based Add ignores `addItem`’s Boolean result and always shows a success snackbar.

**Evidence:** `Project3/lib/screens/scan_screen.dart:188`, `Project3/lib/screens/scan_screen.dart:195`

### 3. Basket persistence is not awaited

**EVIDENCE:** Basket mutations except checkout invoke persistence without awaiting it, so UI state and success feedback can precede—or survive—a failed Firestore write.

**Evidence:** `Project3/lib/state/app_state.dart:400`, `Project3/lib/state/app_state.dart:488`, `Project3/lib/state/app_state.dart:551`

### 4. Receipt import does not perform checkout

**EVIDENCE:** Receipt import adds matched products to the basket; it does not execute checkout.

**Evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:169`, `Project3/lib/state/app_state.dart:556`

### 5. Receipt added-item count can be inaccurate

**EVIDENCE:** If a receipt item already exists, `addItem` increments it but returns false, so the receipt’s “Added N items” count can be zero even though basket state changed.

**Evidence:** `Project3/lib/state/app_state.dart:358`, `Project3/lib/screens/receipt_scanner_screen.dart:171`

### 6. Checkout can clear local state before persistence succeeds

**EVIDENCE:** Checkout clears the local basket before awaiting persistence and has no rollback in checkout; an exception prevents the success UI but leaves the in-memory basket cleared.

**Evidence:** `Project3/lib/state/app_state.dart:556`, `Project3/lib/screens/qr_checkout_screen.dart:34`

### 7. Failed state loading can still mark balances as loaded

**EVIDENCE:** `loadUserState` has no catch; its `finally` marks balances as loaded even if the Firestore read fails.

**Evidence:** `Project3/lib/state/app_state.dart:234`, `Project3/lib/state/app_state.dart:290`

### 8. Monthly reset persistence failure is unhandled

**EVIDENCE:** Monthly reset persists without awaiting or handling failure.

**Evidence:** `Project3/lib/state/app_state.dart:203`

### 9. Login can briefly display incomplete state

**INFERENCE:** Login can reach Scan before background state restoration finishes, creating a transient empty or stale-looking UI state until the asynchronous load completes.

**Evidence:** `Project3/lib/screens/login_screen.dart:43`, `Project3/lib/state/app_state.dart:82`