# Codex repository-discovery outputs

These are Codex's outputs. Preserve the prompts and run the same prompts in
the other models before reconciling.

## Starter prompt 1 — First contact (output, 247 words)

The repository is a Flutter application named WolfBite. Its main components
are: (1) Flutter screens for account creation/sign-in, product scanning,
basket management, benefit balances, receipt import, and QR checkout; (2)
`app_router.dart`, which defines navigation and authentication guards; (3)
`AppState`, which owns the signed-in user's basket and category usage and
persists both in Firestore; (4) `AplService` plus nutrition utilities, which
look up approved products and rank healthier same-category alternatives; (5)
Firebase configuration and platform shells for Android, iOS, web, desktop;
and (6) an inherited test suite and CI workflow.

Five most important files, ranked:

1. `Project3/lib/state/app_state.dart` — central business rules for benefit
   limits, paid overflow, basket mutation, persistence, and monthly reset.
2. `Project3/lib/screens/scan_screen.dart` — primary product workflow: camera
   or manual UPC lookup, result presentation, alternatives, and add-to-basket.
3. `Project3/lib/services/apl_service.dart` — defines product lookup and the
   healthier-alternative scoring/query behavior.
4. `Project3/lib/screens/basket_screen.dart` — exposes quantity changes,
   nutritional details, clearing, and checkout entry.
5. `Project3/lib/app_router.dart` — authoritative route inventory and access
   control, useful for separating implemented features from README claims.

The directory safe to ignore this month is `Project3/.idea/`: it contains IDE
metadata, not product behavior. Generated `build/` and `.dart_tool/` content
can also be ignored as design evidence, but should not be mistaken for source.

## Starter prompt 4 — Undocumented product

Ranked hidden or under-documented user-relevant behavior:

1. **Buy quantities beyond a WIC category cap as `PAID`.** Incrementing a
   capped basket item creates or increments a separate paid line
   (`state/app_state.dart:431–486`). This deserves a top-20 use case.
2. **Automatically start a fresh monthly usage period.** Loading a user whose
   last update was in an earlier month resets used counts and clears the basket
   (`state/app_state.dart:195–212, 282–287`). This belongs as an extension of
   restoring a saved session rather than a separate shopper-triggered goal.
3. **Resume a persisted basket and balances after sign-in.** Authentication
   changes trigger a Firestore load (`state/app_state.dart:75–86, 227–294`).
   This deserves a top-20 use case.
4. **Enter a UPC manually on a wide-screen device.** The README emphasizes
   scanning, while the screen includes direct UPC entry and lookup
   (`screens/scan_screen.dart:600–648`). This deserves a top-20 use case.
5. **Remove paid overflow before WIC-covered quantity.** Decrementing a product
   first consumes its `PAID` line (`state/app_state.dart:493–549`). This is an
   important extension of decreasing quantity.

The README also claims real-time order tracking, but the public route and
screen inventory provides no order feature. That is a documentation mismatch,
not a hidden feature and not a valid use case.

## Starter prompt 5 — Fragility ranking

1. **Receipt OCR import.** It was introduced in one 231-line commit and then
   received three rapid fixes (`206eecd`, `68f77f6`, `c74bab7`, `cc22b3c`).
   The 248-line screen performs image selection, base64 conversion, a live
   third-party HTTP call using a public test key, regex parsing, sequential
   database lookups, and state/UI updates. Churn and external dependencies
   make it the most likely first break.
2. **Scanning and swap workflow.** `scan_screen.dart` is 885 lines, grew by 262
   lines in one change (`4ffad84`), then changed repeatedly for web scanning,
   nutrition, paid handling, and receipt navigation. One stateful screen owns
   camera lifecycle, lookup, substitution, nutrition, basket mutation, and two
   responsive layouts.
3. **Basket/benefit state rules.** `app_state.dart` is 584 lines and saw
   overlapping late changes for monthly reset, paid overflow, and nutrition,
   including a 203-line rewrite (`98951bc`). Its methods jointly mutate basket
   lines and balance counters, persist asynchronously in several paths, and
   contain category-specific caps. Small changes can violate cross-field
   invariants.

The existing CI configuration is independently fragile: it still points at
`Project2`, and the missing committed lockfile allowed a test-double/package
interface incompatibility during a fresh dependency resolution.
