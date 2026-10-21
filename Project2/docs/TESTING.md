# Testing WolfBite

All commands run from `Project2/`. Flutter: `flutter`, or the repo-local SDK.

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

## Verified CI results (2026-10-20)

The [Flutter CI run](https://github.com/closeabigaile/SEf26_project/actions/runs/39493687299)
and [published dev report](https://github.com/closeabigaile/SEf26_project/blob/ci-evidence/dev/README.md)
identify commit `e8228543ed3950d32a26736b06b90e3a9d14d47b`:

- Flutter suite: **377 passed, 0 failed, 0 skipped**.
- Dart line coverage: **92.0%** (2,388 of 2,596 measured lines).
- Release web build, strict Dart analysis, formatting, Firebase configuration,
  Python checks, and JavaScript tests: **passed**.
- The [M0 baseline workflow](https://github.com/closeabigaile/SEf26_project/actions/runs/39493687288)
  and [M4 verification workflow](https://github.com/closeabigaile/SEf26_project/actions/runs/39493687491)
  also passed for this commit.

These are recorded GitHub results, not a new local test run. The `dev` report
updates on later pushes; use the linked run for this particular commit.
Coverage measures Dart lines in the Flutter test report, not live Firebase,
device-camera behavior, or participant outcomes.

[Flutter CI](../../.github/workflows/flutter-ci.yml) runs on pushes to every
branch except the generated `ci-evidence` branch, on pull requests, and when
manually dispatched. It checks formatting without rewriting files and runs
`flutter analyze --no-pub --fatal-infos --fatal-warnings`.
Badge evidence publishes on branch pushes; documentation deploys only after
successful checks on a push to `main`.

## Recorded manual and device checks

- The [October 19 fresh-clone record](../../Project2_Work/installation/2026-10-19/README.md)
  documents macOS setup, 377 passing Flutter tests, a release web build, and
  Abigail Close's successful live sign-in, product lookup, and add-to-basket
  check at commit `3f1379ec15be9b7b093e5a291c6e05a9c50bf603`.
- The October 17 version of this document reported 11/11 Windows device
  journeys and an M2 visual-flow pass. Those are historical team-reported
  results, not a fresh device verification of the October 20 commit.

## Video evidence

The [teaser](videos/Wolfbite%20Teaser%20Video.mov) is 18.2 seconds and the
[walkthrough](videos/WolfBite%20Walkthrough.mov) is 3 minutes, 26 seconds,
within the Project 2 duration limits. The files are publicly accessible on
GitHub; its file viewer does not provide an inline player for these files.
Use **View raw** or **Download raw file** to open them in a video player.

Frames reviewed at one-second intervals across the full walkthrough timeline
show lookup, alternatives, nutrition details, basket quantities, benefits, and
QR checkout. This visual check did not assess narration. Coverage of the M2 basket-balance suggestion and
confirmed swap, and the M4 checkout-help dialog, still needs verification.
Opening the receipt screen does not demonstrate successful OCR import.

## Known gaps

- No completed run of `integration_test/live_app_test.dart` is recorded here;
  it needs the credentials file. The manual fresh-clone check above is separate.
- Receipt scanning uses `image_picker` and the remote OCR.space API through
  `http`, not ML Kit. Successful camera/image-to-OCR-to-basket behavior has not
  been verified end to end in the recorded checks.
- Scan screen: when a category is full the Add button is disabled, so the
  "Paid" fallback inside `_addToBasket` is unreachable; overflow to PAID only
  happens through "+" on an existing basket line (J1 documents this).
