# K3 — Boundary and edge-case audit

**Model:** GPT-5.6-terra  
**Interface:** OpenAI Codex CLI  
**GitHub user:** supreme1022
**Date:** August 25, 2026  
**Prompt ID:** K3 — Boundary and edge-case audit  
**Repository commit:** `03bc584b9a4e03aa8eca51b872435d07b4e7009f`

---

## 1. Login email without `@` vs. containing `@`

- **Expected behavior — EVIDENCE:** Invalid email is rejected before authentication; any value containing `@` passes local email validation.
- **Ambiguity or risk:** The local rule accepts many malformed addresses.
- **Candidate use-case extension:** Invalid email → remain on login with field error.
- **File:line evidence:** `Project3/lib/screens/login_screen.dart:99`

---

## 2. Login password length 5 vs. 6

- **Expected behavior — EVIDENCE:** A password shorter than six characters is rejected locally; six characters permits submission.
- **Ambiguity or risk:** Firebase may apply additional password rules not represented locally.
- **Candidate use-case extension:** Short password → block sign-in attempt.
- **File:line evidence:** `Project3/lib/screens/login_screen.dart:120`

---

## 3. Account creation succeeds but profile write fails

- **Expected behavior — EVIDENCE:** Authentication account creation occurs before writing the Firestore profile.
- **Ambiguity or risk:** The catch handles only `FirebaseAuthException`; a profile-write failure can leave a created account without the profile and without the displayed signup error.
- **Candidate use-case extension:** Signup profile-write failure → account/profile state is partial.
- **File:line evidence:** `Project3/lib/screens/signup_page.dart:52`

---

## 4. Whitespace-only UPC vs. nonempty UPC

- **Expected behavior — EVIDENCE:** Empty trimmed UPCs return without an APL request or visible message.
- **Ambiguity or risk:** A shopper receives no explanation for why lookup did not start.
- **Candidate use-case extension:** Empty UPC → remain ready without querying or changing result.
- **File:line evidence:** `Project3/lib/screens/scan_screen.dart:130`

---

## 5. Second barcode arrives while lookup is active

- **Expected behavior — EVIDENCE:** `_busy` prevents concurrent detection/lookup handling.
- **Ambiguity or risk:** A later, distinct barcode can be silently discarded.
- **Candidate use-case extension:** Lookup in progress → ignore subsequent barcode detection.
- **File:line evidence:** `Project3/lib/screens/scan_screen.dart:130`, `Project3/lib/screens/scan_screen.dart:409`

---

## 6. UPC absent from APL

- **Expected behavior — EVIDENCE:** The current product result is cleared and a “not found” snackbar is shown.
- **Ambiguity or risk:** Previously loaded healthier alternatives are not explicitly cleared in this branch.
- **Candidate use-case extension:** Unknown UPC → no addable current product.
- **File:line evidence:** `Project3/lib/screens/scan_screen.dart:139`

---

## 7. Existing APL document has `eligible: false` or no eligibility field

- **Expected behavior — EVIDENCE:** Direct UPC lookup returns any existing document; it does not filter on `eligible`.
- **Ambiguity or risk:** The flow can present a found product as an eligibility result without independently enforcing eligibility.
- **Candidate use-case extension:** Existing but ineligible APL record → distinguish lookup result from WIC eligibility.
- **File:line evidence:** `Project3/lib/services/apl_service.dart:31`, `Project3/lib/screens/scan_screen.dart:130`

---

## 8. Product lacks `foodNutrients`, or nutrient values are nonnumeric

- **Expected behavior — EVIDENCE:** Missing/non-numeric nutrient amounts become `0.0`.
- **Ambiguity or risk:** Unknown nutrition can qualify for low-fat, low-sodium, low-sugar, low-calorie, and heart-healthy badges.
- **Candidate use-case extension:** Missing nutrition → show zero-derived nutrition/badge behavior.
- **File:line evidence:** `Project3/lib/utils/nutritional_utils.dart:29`, `Project3/lib/utils/nutritional_utils.dart:73`

---

## 9. Nutrition value exactly equals a badge threshold

- **Expected behavior — EVIDENCE:** Threshold comparisons are inclusive; for example, fat ≤3, sodium ≤140, and protein ≥10.
- **Ambiguity or risk:** Threshold policy is code-defined rather than explained to shoppers.
- **Candidate use-case extension:** Nutrient exactly at threshold → include the applicable badge.
- **File:line evidence:** `Project3/lib/utils/nutritional_utils.dart:73`

---

## 10. More than three qualifying badges in compact display

- **Expected behavior — EVIDENCE:** Compact badges render only the first three computed badges.
- **Ambiguity or risk:** The order of badge generation can hide later badges, including WIC eligibility.
- **Candidate use-case extension:** Four or more qualifying badges → compact display truncates to three.
- **File:line evidence:** `Project3/lib/widgets/nutritional_badges.dart:103`

---

## 11. Scanned product has blank category

- **Expected behavior — EVIDENCE:** Healthier-alternative lookup returns early for an empty category.
- **Ambiguity or risk:** Existing alternative state may remain until replaced by another successful lookup.
- **Candidate use-case extension:** Blank category → do not request alternatives.
- **File:line evidence:** `Project3/lib/screens/scan_screen.dart:217`

---

## 12. Candidate has same FDC ID or UPC as scanned product

- **Expected behavior — EVIDENCE:** The healthier-alternative query excludes such candidates.
- **Ambiguity or risk:** Missing IDs can weaken self-exclusion, though UPC comparison remains.
- **Candidate use-case extension:** Base product appears in candidate set → omit it.
- **File:line evidence:** `Project3/lib/services/apl_service.dart:154`

---

## 13. More than five better alternatives or more than fifty same-category candidates

- **Expected behavior — EVIDENCE:** The Firestore query reads at most 50 records and the method returns at most five better-scoring records.
- **Ambiguity or risk:** The displayed five are the best among the first 50 fetched, not necessarily all category products.
- **Candidate use-case extension:** Large candidate set → show up to five best queried alternatives.
- **File:line evidence:** `Project3/lib/services/apl_service.dart:145`, `Project3/lib/services/apl_service.dart:177`

---

## 14. Healthier alternative selected when adding is rejected

- **Expected behavior — EVIDENCE:** The UI calls `addItem` and always shows “Added healthier item,” without checking its Boolean result.
- **Ambiguity or risk:** A rejected addition can still receive success feedback.
- **Candidate use-case extension:** Alternative addition rejected → verify displayed result against basket state.
- **File:line evidence:** `Project3/lib/screens/scan_screen.dart:374`, `Project3/lib/state/app_state.dart:353`

---

## 15. New category contains `FRUIT`, `VEGETABLE`, or `CVB`

- **Expected behavior — EVIDENCE:** Such categories receive an uncapped allowance; other recognized categories receive derived caps.
- **Ambiguity or risk:** Substring matching can classify unintended category names as unlimited.
- **Candidate use-case extension:** Produce-like category → show unlimited balance behavior.
- **File:line evidence:** `Project3/lib/state/app_state.dart:122`

---

## 16. New, unrecognized covered category

- **Expected behavior — EVIDENCE:** Its default allowance is two items.
- **Ambiguity or risk:** The cap is derived locally, not sourced from a user’s actual benefit record.
- **Candidate use-case extension:** Unknown category → initialize cap at two and usage at zero.
- **File:line evidence:** `Project3/lib/state/app_state.dart:156`, `Project3/lib/state/app_state.dart:167`

---

## 17. New distinct receipt item arrives after covered category is full

- **Expected behavior — EVIDENCE:** `addItem` rejects a new line when the category cannot accept another item.
- **Ambiguity or risk:** This differs from basket increment behavior, which creates PAID overflow; receipt import can therefore add fewer recognized items than found.
- **Candidate use-case extension:** Receipt item at covered cap → reject rather than create a paid line.
- **File:line evidence:** `Project3/lib/state/app_state.dart:366`, `Project3/lib/screens/receipt_scanner_screen.dart:169`

---

## 18. Same UPC is added again below category cap

- **Expected behavior — EVIDENCE:** `addItem` increments the existing product via `incrementItem` but returns false.
- **Ambiguity or risk:** Callers that interpret false as “not added” can misreport a successful quantity change.
- **Candidate use-case extension:** Duplicate UPC → increase quantity without creating a second covered line.
- **File:line evidence:** `Project3/lib/state/app_state.dart:358`

---

## 19. Existing item incremented exactly at covered-category cap

- **Expected behavior — EVIDENCE:** The app creates or increments a PAID line for the same UPC.
- **Ambiguity or risk:** PAID is tracked in the same balances structure despite not being a benefit category.
- **Candidate use-case extension:** Increment at cap → create paid overflow.
- **File:line evidence:** `Project3/lib/state/app_state.dart:451`

---

## 20. Paid and covered lines both exist; shopper decrements

- **Expected behavior — EVIDENCE:** Decrement targets the paid line first, removes it at zero, and only then can reduce the covered line.
- **Ambiguity or risk:** The caller supplies a category argument, but paid-first selection is driven solely by UPC.
- **Candidate use-case extension:** Mixed covered/paid quantity → remove paid overflow first.
- **File:line evidence:** `Project3/lib/state/app_state.dart:502`

---

## 21. Receipt OCR code-length boundaries

**Boundary:** OCR yields no contiguous 12–14 digits, a 12-digit UPC, or a 13/14-digit candidate.

- **Expected behavior — EVIDENCE:** Only 12–14 contiguous digits are considered; longer candidates are also tested through each 12-digit window.
- **Ambiguity or risk:** Formatted UPCs with spaces/hyphens are missed; longer values cause sequential APL lookups and the first match wins.
- **Candidate use-case extension:** OCR code-length boundary → accept only direct or sliding-window matches.
- **File:line evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:124`

---

## 22. OCR contains the same valid UPC repeatedly

- **Expected behavior — EVIDENCE:** The recognized-items list deduplicates by UPC before rendering.
- **Ambiguity or risk:** `foundCount` still counts every numeric candidate, so its status can exceed the number of offered products.
- **Candidate use-case extension:** Repeated receipt UPC → offer one item despite multiple detections.
- **File:line evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:133`, `Project3/lib/screens/receipt_scanner_screen.dart:151`

---

## 23. Basket mutation succeeds locally but Firestore persistence fails

- **Expected behavior — EVIDENCE:** Add, increment, decrement, and clear call `_persist()` without awaiting it.
- **Ambiguity or risk:** The UI can update and report success before persistence completes or fails.
- **Candidate use-case extension:** Basket persistence failure → compare local visible state with restored state.
- **File:line evidence:** `Project3/lib/state/app_state.dart:400`, `Project3/lib/state/app_state.dart:488`, `Project3/lib/state/app_state.dart:551`

---

## 24. Saved state's `updatedAt` is from a prior month/year

- **Expected behavior — EVIDENCE:** The app sets every used value to zero, clears the basket, and calls persistence.
- **Ambiguity or risk:** Reset persistence is unawaited; a failed write has no recovery path.
- **Candidate use-case extension:** New benefit month → reset usage and discard saved basket.
- **File:line evidence:** `Project3/lib/state/app_state.dart:195`, `Project3/lib/state/app_state.dart:203`, `Project3/lib/state/app_state.dart:282`

---

## 25. Checkout persistence fails after Finish is selected

- **Expected behavior — INFERENCE:** A failed checkout should not be represented as a completed transaction.
- **Ambiguity or risk — EVIDENCE:** Checkout clears the local basket before awaiting persistence; an exception bypasses the success snackbar but there is no rollback.
- **Candidate use-case extension:** Checkout write failure → inspect whether pending basket contents remain available.
- **File:line evidence:** `Project3/lib/state/app_state.dart:556`, `Project3/lib/screens/qr_checkout_screen.dart:34`