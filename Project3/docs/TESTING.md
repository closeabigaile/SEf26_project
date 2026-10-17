# Testing WolfBite

All commands run from `Project3/`. Flutter: `flutter`, or the repo-local SDK.

## Test layers

| Layer | Where | What it drives | Firebase |
| --- | --- | --- | --- |
| Unit | `test/services`, `test/utils`, `test/state` | Services, rules, AppState | fake Firestore |
| Widget | `test/screens`, `test/project1a`, `test/m4_review` | Single screens | mocks / fake |
| End to end (VM) | `test/e2e` | Real screens behind a real GoRouter, one AppState, persistence | fake Firestore seeded with real data |
| On device | `integration_test/journeys_device_test.dart` | The same e2e journeys with real rendering and timers | fake Firestore |
| Visual | `integration_test/m2_flow_visual_test.dart` | M2 flow, saves screenshots | fake Firestore |
| Live | `integration_test/live_app_test.dart` | The whole app via the login screen | **real** `wolfbyte-proj1` |
| Scripts | `scripts/test_*.cjs`, `scripts/test_*.py`, `../Project2_Work/M0` | APL import/convert, nutrition enrichment, M0 scoring | none |

Real data: `test/fixtures/m2_real_sample.json` holds real NC APL records
(2026-09-02 import) and validated Open Food Facts nutrition, so the e2e tests
exercise real product names, categories (including spelling variants) and
nutrient values.

## End-to-end journeys

`test/e2e/shopping_journeys_e2e_test.dart`

- J1 full category: scan disables Add for a new product, "+" overflows to a
  PAID line, checkout help explains the full allowance, Benefits shows 0 left.
- J2 healthier alternative from the scan screen (from `nutrition/`) is added.
- J3 two APL spellings of one category share one allowance (scan to Benefits).
- J4 checkout: basket, QR handoff, Finish clears the basket and keeps usage.
- J5 clear cart: Cancel keeps everything, Clear All releases usage.
- J6 quantity +/- across WIC and PAID lines stays consistent with storage.
- J7 a session saved last month resets usage and clears the basket.
- J8 resume: a saved basket reloads with real nutrition and M2 still works.

`test/e2e/m2_scan_to_swap_test.dart`: scan, nutrition panel, basket balance,
"Not now", confirmed swap, persistence, and abstaining on unknown data.
`test/e2e/m2_basket_balance_e2e_test.dart` and `test/e2e/milestones_e2e_test.dart`
cover M2 with synthetic data and the M0-M4 cross-milestone flows.

## Commands

```sh
flutter test                                   # everything in test/
flutter test --coverage && node scripts/coverage_summary.cjs
flutter test integration_test/journeys_device_test.dart -d windows
flutter test integration_test/m2_flow_visual_test.dart -d windows   # screenshots in build/e2e_screenshots
node --test scripts/test_import.cjs scripts/test_enrich_nutrition_off.cjs
python -m unittest discover -s scripts -p "test_*.py"
(cd ../Project2_Work/M0 && python -m unittest discover -s . -p "test_*.py")
```

Live run (writes to the real project; the account's `users/{uid}` document
is backed up first and restored afterwards):

```sh
# credentials file outside the repo: %USERPROFILE%\.wolfbite_e2e.json
# {"email": "...", "password": "..."}
flutter test integration_test/live_app_test.dart -d windows
```

Desktop builds need Visual Studio C++ build tools (Windows). Device tests
poll for results (`test/e2e/e2e_helpers.dart`) because lookups take real time.

## Current numbers (2026-10-17)

- `flutter test`: 377 passed, 0 failed.
- On device (Windows): 11 of 11 journeys passed; M2 visual flow passed.
- Node script tests: 13 passed. Python APL tests and M0 scoring tests pass.
- Line coverage: 90.8% overall. M2: `basket_balance_service.dart` 100%,
  `app_state.dart` 98.7%, `apl_service.dart` 97.9%, `nutritional_utils.dart`
  96.6%, `basket_balance_sheet.dart` 94.5%. Lowest: `nutritional_badges.dart`
  64.8%, `receipt_scanner_screen.dart` 68.3%, `qr_checkout_screen.dart` 70%.

## Known gaps

- CI (`.github/workflows/flutter-ci.yml`, main only) runs `flutter analyze
  --fatal-infos --fatal-warnings` and a format check; 21 analyzer issues and
  14 unformatted files (none in M2 code) would fail it today.
- The live test has not been run yet (needs the credentials file).
- Receipt scanning (camera + ML Kit OCR) is not covered end to end.
- Scan screen: when a category is full the Add button is disabled, so the
  "Paid" fallback inside `_addToBasket` is unreachable; overflow to PAID only
  happens through "+" on an existing basket line (J1 documents this).
