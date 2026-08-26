# K4 — Repository claim and evidence audit

**Model:** GPT-5.6-terra  
**Interface:** OpenAI Codex CLI  
**GitHub user:** supreme1022
**Date:** August 25, 2026  
**Prompt ID:** K4 — Repository claim and evidence audit  
**Repository commit:** `03bc584b9a4e03aa8eca51b872435d07b4e7009f`

---

## 1. WolfBite is a food-delivery application

- **Source making the claim:** `README.md:22`, `README.md:37`
- **Evidence:** Routes cover login, signup, scan, basket, balances, and receipt scanning; no restaurant, order-placement, delivery, driver, or delivery-status flow exists.
- **File:line evidence:** `Project3/lib/app_router.dart:65`
- **Verdict:** **Misleading**
- **Top 20 use case?** No

---

## 2. Barcode scanning verifies WIC eligibility in real time

- **Source making the claim:** `README.md:37`, `README.md:41`, `README.md:73`
- **Evidence:** Live/manual UPC lookup is implemented, but `findByUpc` returns any existing APL document without filtering its `eligible` field.
- **File:line evidence:** `Project3/lib/screens/scan_screen.dart:130`, `Project3/lib/services/apl_service.dart:31`
- **Verdict:** **Partial**
- **Top 20 use case?** Yes

---

## 3. Firebase provides secure sign-up and login

- **Source making the claim:** `README.md:42`, `README.md:74`
- **Evidence:** Firebase email/password signup and login are implemented; code alone cannot establish the broader security claim.
- **File:line evidence:** `Project3/lib/screens/signup_page.dart:46`, `Project3/lib/screens/login_screen.dart:38`
- **Verdict:** **Partial**
- **Top 20 use case?** Yes

---

## 4. Swap Coach ranks healthier same-category alternatives and shows them through the leaf control

- **Source making the claim:** `README.md:55`, `README.md:57`
- **Evidence:** Eligible same-category products are scored, sorted, limited to five, and exposed through a leaf-button workflow.
- **File:line evidence:** `Project3/lib/services/apl_service.dart:139`, `Project3/lib/screens/scan_screen.dart:566`
- **Verdict:** **Implemented**
- **Top 20 use case?** Yes

---

## 5. Food items display nutrition/WIC badges and a nutrition-information dropdown

- **Source making the claim:** `README.md:59`, `README.md:61`
- **Evidence:** Nutrition badges appear for scanned and basket products; expanded nutrition facts exist for basket items. Missing nutrients default to zero, which can create misleading “low” badges.
- **File:line evidence:** `Project3/lib/utils/nutritional_utils.dart:26`, `Project3/lib/widgets/nutritional_badges.dart:103`, `Project3/lib/screens/basket_screen.dart:387`
- **Verdict:** **Partial**
- **Top 20 use case?** Yes

---

## 6. QR checkout generates a platform-agnostic transaction representation

- **Source making the claim:** `README.md:63`, `README.md:65`
- **Evidence:** The basket is JSON-encoded and rendered as a QR image. No receiving platform, cashier acknowledgement, or external transaction transfer is implemented.
- **File:line evidence:** `Project3/lib/screens/qr_checkout_screen.dart:12`
- **Verdict:** **Partial**
- **Top 20 use case?** Yes

---

## 7. Receipt OCR auto-updates category balances and automatically checks out imported items

- **Source making the claim:** `README.md:67`, `README.md:69`
- **Evidence:** Receipt OCR finds APL matches; the shopper must select Add to Basket. That action adds items and updates basket/balance state, but checkout is a separate operation.
- **File:line evidence:** `Project3/lib/screens/receipt_scanner_screen.dart:124`, `Project3/lib/screens/receipt_scanner_screen.dart:169`, `Project3/lib/state/app_state.dart:556`
- **Verdict:** **Partial**
- **Top 20 use case?** Yes

---

## 8. Shoppers can add and manage a cart

- **Source making the claim:** `README.md:75`
- **Evidence:** Basket lines, quantity controls, clearing, and checkout entry are implemented.
- **File:line evidence:** `Project3/lib/screens/basket_screen.dart:98`, `Project3/lib/screens/basket_screen.dart:368`
- **Verdict:** **Implemented**
- **Top 20 use case?** Yes

---

## 9. Users can track orders in real time

- **Source making the claim:** `README.md:76`
- **Evidence:** The complete production route inventory contains no order or tracking route/module.
- **File:line evidence:** `Project3/lib/app_router.dart:65`
- **Verdict:** **Absent**
- **Top 20 use case?** No

---

## 10. The app is optimized for mobile and web platforms

- **Source making the claim:** `README.md:77`
- **Evidence:** The scan screen switches between a mobile camera scanner and wide-layout manual UPC entry; Flutter platform directories also exist. Equal feature quality or successful operation across all platforms is not established by source.
- **File:line evidence:** `Project3/lib/screens/scan_screen.dart:417`, `Project3/lib/screens/scan_screen.dart:688`
- **Verdict:** **Partial**
- **Top 20 use case?** No

---

## 11. The quick start applies to this repository

- **Source making the claim:** `README.md:94`
- **Evidence:** README directs users to `Project2`, while the application manifest is in `Project3/pubspec.yaml`.
- **File:line evidence:** `README.md:97`, `Project3/pubspec.yaml:1`
- **Verdict:** **Misleading**
- **Top 20 use case?** No

---

## 12. CI builds, analyzes, and tests the current application

- **Source making the claim:** `.github/workflows/flutter-ci.yml:17`
- **Evidence:** Both CI jobs use `./Project2`; the shipped application is in `Project3`.
- **File:line evidence:** `.github/workflows/flutter-ci.yml:25`, `.github/workflows/flutter-ci.yml:70`, `Project3/pubspec.yaml:1`
- **Verdict:** **Absent**
- **Top 20 use case?** No

---

## 13. README dependency versions describe the manifest

- **Source making the claim:** `README.md:146`
- **Evidence:** README calls `firebase_auth` and `cloud_firestore` “Latest,” whereas the manifest uses version constraints `^6.1.1` and `^6.0.2`; the README also omits dependencies used for receipt OCR.
- **File:line evidence:** `README.md:147`, `Project3/pubspec.yaml:42`, `Project3/pubspec.yaml:46`
- **Verdict:** **Misleading**
- **Top 20 use case?** No

---

## Git-history note

Git history supports treating receipt OCR as a recent implemented feature (`cc22b3c`, “receipt scanner updates”), but commit messages are not functional proof; the audit above relies on current production source.

---

## Three mistakes an LLM is most likely to make when deriving use cases

1. **Promote README-only features into real use cases.**  
   Food delivery and real-time order tracking are described in the README despite being absent from production routes and source.

2. **Describe receipt import as automatic checkout.**  
   The code recognizes products and requires an explicit **Add to Basket** action; checkout is separate.

3. **Overstate WIC verification or QR checkout.**  
   Direct UPC lookup does not enforce `eligible`, and the QR is locally generated basket JSON with no external handoff confirmation.