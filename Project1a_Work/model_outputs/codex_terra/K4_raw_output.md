Model: GPT-5.6-terra
Interface: OpenAI Codex CLI
Nme: Supreme
Date: August 25, 2026
Prompt ID: K2 - State-transition and invariant audit
Repository commit: 03bc584b9a4e03aa8eca51b872435d07b4e7009f

okay i did
•  Claim                               Source making the claim                     Confirming or contradicting          Verdict        Top 20 use case?
                                                                                   evidence
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━
   WolfBite is a food-delivery         README.md:22, README.md:37                  Routes cover login, signup, scan,    misleading     no
   application.                                                                    basket, balances, and receipt
                                                                                   scanning; no restaurant, order-
                                                                                   placement, delivery, driver, or
                                                                                   delivery-status flow exists.
                                                                                   Project3/lib/app_router.dart:65
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   Barcode scanning verifies WIC       README.md:37, README.md:41, README.md:73    Live/manual UPC lookup is            partial        yes
   eligibility in real time.                                                       implemented, but findByUpc
                                                                                   returns any existing APL document
                                                                                   without filtering its eligible
                                                                                   field. Project3/lib/screens/
                                                                                   scan_screen.dart:130; Project3/
                                                                                   lib/services/apl_service.dart:31
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   Firebase provides secure sign-up    README.md:42, README.md:74                  Firebase email/password signup       partial        yes
   and login.                                                                      and login are implemented; code
                                                                                   alone cannot establish the
                                                                                   broader security claim. Project3/
                                                                                   lib/screens/signup_page.dart:46;
                                                                                   Project3/lib/screens/
                                                                                   login_screen.dart:38
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   Swap Coach ranks healthier same-    README.md:55, README.md:57                  Eligible same-category products      implemented    yes
   category alternatives and shows                                                 are scored, sorted, limited to
   them through the leaf control.                                                  five, and exposed through a leaf-
                                                                                   button workflow. Project3/lib/
                                                                                   services/apl_service.dart:139;
                                                                                   Project3/lib/screens/
                                                                                   scan_screen.dart:566
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   Food items display nutrition/WIC    README.md:59, README.md:61                  Nutrition badges appear for          partial        yes
   badges and a nutrition-                                                         scanned and basket products;
   information dropdown.                                                           expanded nutrition facts exist
                                                                                   for basket items. Missing
                                                                                   nutrients default to zero, which
                                                                                   can create misleading “low”
                                                                                   badges. Project3/lib/utils/
                                                                                   nutritional_utils.dart:26;
                                                                                   Project3/lib/widgets/
                                                                                   nutritional_badges.dart:103;
                                                                                   Project3/lib/screens/
                                                                                   basket_screen.dart:387
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   QR checkout generates a             README.md:63, README.md:65                  The basket is JSON-encoded and       partial        yes
   platform-agnostic transaction                                                   rendered as a QR image. No
   representation.                                                                 receiving platform, cashier
                                                                                   acknowledgement, or external
                                                                                   transaction transfer is
                                                                                   implemented. Project3/lib/
                                                                                   screens/
                                                                                   qr_checkout_screen.dart:12
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   Receipt OCR auto-updates            README.md:67, README.md:69                  Receipt OCR finds APL matches;       partial        yes
   category balances and                                                           the shopper must select Add to
   automatically checks out                                                        Basket. That action adds items
   imported items.                                                                 and updates basket/balance state,
                                                                                   but checkout is a separate
                                                                                   operation. Project3/lib/screens/
                                                                                   receipt_scanner_screen.dart:124;
                                                                                   Project3/lib/screens/
                                                                                   receipt_scanner_screen.dart:169;
                                                                                   Project3/lib/state/
                                                                                   app_state.dart:556
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   Shoppers can add and manage a       README.md:75                                Basket lines, quantity controls,     implemented    yes
   cart.                                                                           clearing, and checkout entry are
                                                                                   implemented. Project3/lib/
                                                                                   screens/basket_screen.dart:98;
                                                                                   Project3/lib/screens/
                                                                                   basket_screen.dart:368
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   Users can track orders in real      README.md:76                                The complete production route        absent         no
   time.                                                                           inventory contains no order or
                                                                                   tracking route/module. Project3/
                                                                                   lib/app_router.dart:65
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   The app is optimized for mobile     README.md:77                                The scan screen switches between     partial        no
   and web platforms.                                                              a mobile camera scanner and wide-
                                                                                   layout manual UPC entry; Flutter
                                                                                   platform directories also exist.
                                                                                   Equal feature quality or
                                                                                   successful operation across all
                                                                                   platforms is not established by
                                                                                   source. Project3/lib/screens/
                                                                                   scan_screen.dart:417; Project3/
                                                                                   lib/screens/scan_screen.dart:688
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   The quick start applies to this     README.md:94                                README directs users to Project2,    misleading     no
   repository.                                                                     while the application manifest is
                                                                                   in Project3/pubspec.yaml.
                                                                                   README.md:97; Project3/
                                                                                   pubspec.yaml:1
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   CI builds, analyzes, and tests      .github/workflows/flutter-ci.yml:17         Both CI jobs use ./Project2; the     absent         no
   the current application.                                                        shipped application is in
                                                                                   Project3.  .github/workflows/
                                                                                   flutter-ci.yml:25; .github/
                                                                                   workflows/flutter-ci.yml:70;
                                                                                   Project3/pubspec.yaml:1
  ──────────────────────────────────  ──────────────────────────────────────────  ───────────────────────────────────  ─────────────  ──────────────────
   README dependency versions          README.md:146                               README calls firebase_auth and       misleading     no
   describe the manifest.                                                          cloud_firestore “Latest,” whereas
                                                                                   the manifest uses version
                                                                                   constraints ^6.1.1 and ^6.0.2;
                                                                                   the README also omits
                                                                                   dependencies used for receipt
                                                                                   OCR. README.md:147; Project3/
                                                                                   pubspec.yaml:42; Project3/
                                                                                   pubspec.yaml:46

  Git history supports treating receipt OCR as a recent implemented feature (cc22b3c, “receipt scanner updates”), but commit messages are not functional
  proof; the table relies on current production source.

  The three mistakes an LLM is most likely to make when deriving use cases are:

  1. Promote README-only food delivery or real-time order tracking into use cases despite their absence from production routes and source.
  2. Describe receipt import as automatic checkout, when the code only recognizes products and requires an explicit Add to Basket action.
  3. Overstate WIC verification or QR checkout: direct UPC lookup does not enforce eligible, and the QR is locally generated basket JSON with no
     external handoff confirmation.