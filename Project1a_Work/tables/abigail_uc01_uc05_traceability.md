# D4 — Abigail’s UC1–UC5 Traceability and Inherited-Test Assessment

**Author:** Abigail Close  
**Branch:** `tests/abigail-UC1-5`  
**Scope:** UC1–UC5  
**Product:** WolfBite  
**Team-authored test file:** `Project3/test/project1a/abigail_uc1-5_test.dart`  
**Execution evidence:** `Project1a_Work/raw_test_output/abigail_uc01_uc05_2026-08-28.txt`

The tests below were designed from the finalized use cases before assessing
the inherited WolfBite tests. All mappings describe behavior proved by an
assertion or mock verification; they do not infer coverage merely from a test
or file name.

## Team-authored test-to-use-case traceability

| Test | Use case(s) | What it proves |
|---|---|---|
| `test_uc01_valid_registration_creates_account_and_profile` | UC1 | Valid registration sends the exact credentials, saves the shopper profile under the newly created user ID, ends the initial session, and makes login available. |
| `test_uc01_blank_fields_prevent_submission` | UC1, extension 2a | Blank required fields produce validation messages before either account creation or profile persistence is attempted. |
| `test_uc01_invalid_email_prevents_submission` | UC1, extension 2a | Invalid email input is reported locally and does not reach authentication or profile persistence. |
| `test_uc01_rejected_registration_displays_error` | UC1, extension 3a | Authentication rejection is displayed, the signup interface remains available, and no profile save, sign-out, or success navigation occurs. |
| `test_uc01_profile_save_failure_does_not_complete_registration_flow` | UC1, extension 4a | Account creation and profile persistence are distinct stages; if persistence fails, registration must not continue to sign-out or login navigation and should report the failure. The failing assertion exposes missing inherited error handling. |
| `test_uc02_valid_credentials_authenticate_and_open_shopping_features` | UC2 | Valid credentials are passed exactly once to Firebase Authentication and successful authentication opens the protected `/scan` route. |
| `test_uc02_invalid_email_prevents_authentication` | UC2, extension 2a | An invalid email is reported locally, produces no Firebase request, and does not open protected shopping features. |
| `test_uc02_short_password_prevents_authentication` | UC2, extension 2b | A five-character password, immediately below the six-character boundary, is rejected before authentication and protected navigation. |
| `test_uc02_rejected_credentials_leave_shopper_signed_out` | UC2, extension 3a | Firebase credential rejection produces a visible error, retains the login interface, and does not navigate to `/scan`. |
| `test_uc02_second_submission_is_blocked_while_sign_in_is_pending` | UC2, extension 3b | While the first authentication `Future` is pending, loading state disables the actionable sign-in control and Firebase receives exactly one request. |
| `test_uc03_logout_action_requests_authentication_sign_out` | UC3, steps 1–2 | Pressing the visible logout control invokes Firebase Authentication’s `signOut()` operation exactly once. |
| `test_uc03_successful_sign_out_returns_shopper_to_login` | UC3, step 4 and postcondition | Successful sign-out requests the `/login` route, making sign-in available again. |
| `test_uc03_successful_sign_out_removes_account_specific_local_state` | UC3, step 3 and postcondition | When authentication changes to signed out, the real `AppState` clears the previous shopper’s basket and balances and resets its loaded state. |
| `test_uc03_sign_out_failure_leaves_shopper_signed_in` | UC3, extension 2a | A rejected sign-out must not navigate to login as though it succeeded. The failing test additionally exposes that the inherited screen lets the authentication exception escape. |
| `test_uc03_existing_signed_out_state_still_returns_to_login` | UC3, extension 4a | An already signed-out local state is empty, the real login interface is available, and protected product-scanning UI is absent. |
| `test_uc04_current_month_saved_session_restores_basket_and_balances` | UC4 | A current-month session restores benefit usage, product identity, quantity, and saved nutrition into the real `AppState`. |
| `test_uc04_missing_saved_session_starts_empty` | UC4, extension 2a | A shopper without a saved document completes loading with empty basket and balances and receives a persisted empty session scaffold. |
| `test_uc04_partial_saved_session_uses_empty_values_for_missing_sections` | UC4, extension 3a | Available saved balances are restored while an absent basket becomes empty without causing session loading to fail. |
| `test_uc04_missing_nutrition_uses_zero_values` | UC4, extension 3b | A saved product without nutrition data is restored with zero defaults for calories, fat, sodium, sugar, and protein. |
| `test_uc04_previous_month_session_resets_basket_and_used_benefits` | UC4, extension 4a | A prior-year saved session is treated as old activity: its basket is cleared and all restored benefit usage is reset to zero. |
| `test_uc05_matching_upc_displays_product_information` | UC5 | The exact entered UPC is sent to product lookup and the matching name, category, and UPC appear without adding anything to the basket. |
| `test_uc05_empty_manual_entry_performs_no_lookup` | UC5, extension 1b | Empty manual input returns before the product service is called, creates no result, and leaves the basket unchanged. |
| `test_uc05_unknown_upc_reports_not_found_and_clears_result` | UC5, extension 2b | After a successful identification, an unknown UPC displays a not-found message, clears the previous product, and leaves the basket unchanged. |
| `test_uc05_lookup_failure_displays_error` | UC5, extension 2c | A product-service exception is distinguished from “not found,” produces a visible error, presents no product, and leaves the basket unchanged. |
| `test_uc05_second_lookup_is_ignored_while_first_is_pending` | UC5, extension 2a | While one product lookup `Future` remains pending, a repeated Check action does not start a second service request. |

## Bidirectional coverage check

### Use cases to tests

| Assigned use case | Team-authored tests | Use-case-level status |
|---|---:|---|
| UC1 — Create account | 5 | Covered; one test reveals a profile-save error-handling failure. |
| UC2 — Sign in | 5 | Covered; success, validation, rejection, and pending-request behavior are exercised. |
| UC3 — Sign out | 5 | Covered; one test reveals an uncaught sign-out exception. |
| UC4 — Resume shopping session | 5 | Covered; full, missing, partial, defaulted, and old-period states are exercised. |
| UC5 — Identify product | 5 | Covered; success, empty, missing, failed, and concurrent lookups are exercised. |

All five assigned use cases have direct executable evidence. “Covered” here
means that each use case has one or more tests; it does not claim that every
possible input or extension has been exhausted.

### Tests to use cases

All 25 tests map directly to UC1–UC5. There are **no orphan
team-authored tests** in this assigned subset. No test checks an unrelated UI
detail without a traceable use-case purpose.

### Remaining requirement-level opportunities

Although UC1–UC5 have use-case-level coverage, the following lower-priority
paths remain outside the 25 tests:

- UC1: recovery after a partially created account and duplicate signup taps.
- UC2: whitespace/case normalization and an authentication error with no
  human-readable message.
- UC3/UC4: a complete User A sign-out → User B sign-in isolation sequence.
- UC4: retrieval failure and failure while persisting the monthly reset.
- UC5: cancelled barcode capture and direct lookup of products with false or
  missing eligibility.

These are acknowledged extensions or uncertainty areas, not orphaned use
cases.

## Assessment of the inherited WolfBite tests

The following table evaluates the tests that existed before Project 1a.
“Intended source coverage” means an assertion is visible in inherited test
code. “Executed evidence” distinguishes tests that ran from tests blocked by
the dependency compilation problem recorded in `Project1a_Work/baseline.md`.

| Use case | Inherited test evidence | Verdict | Important blind spots |
|---|---|---|---|
| UC1 — Create account | `screens/signup_page_test.dart`: `validates all empty fields`; successful form creates the user, saves the profile, signs out, and navigates to `/login`; auth rejection shows a `SnackBar`; signup loading state is rendered. These signup tests reached passing results in the baseline. | **Partially covered** | No Firestore/profile-save failure after successful account creation; no recovery from an incomplete account/profile; no focused invalid-email boundary beyond the combined empty-field test. |
| UC2 — Sign in | `screens/login_screen_test.dart`: invalid email, short password, successful button and keyboard submissions, rejected credentials, loading state, and navigation to `/scan`. These login tests reached passing results in the baseline. | **Largely covered, not complete** | Loading is shown, but the inherited test does not directly verify that a repeated submission produces only one Firebase request; it also does not establish every protected-route consequence of remaining signed out. |
| UC3 — Sign out | `screens/balances_screen_test.dart`: logout calls `signOut()` and navigates to `/login`; `screens/scan_screen_test.dart` contains an equivalent source-level test. The balances test executed, while the scan test file was among the baseline compilation failures. | **Partially covered** | No sign-out failure/error handling; no assertion that basket and balances are cleared; no already-signed-out path; no cross-user privacy/isolation sequence. Calling `signOut()` alone does not prove UC3’s complete postcondition. |
| UC4 — Resume shopping session | `state/app_state_test.dart`: `updateUser loads user data when logged in` intends to restore one saved balance and basket item. The state test file did not compile in the baseline because of the Firestore/fake-Firestore dependency mismatch. | **Weak source coverage; no executable baseline evidence** | No missing document, partial record, missing nutrition, previous-month/year reset, reset-save failure, retrieval failure, or account-isolation case. |
| UC5 — Identify product | `screens/scan_screen_test.dart`: product found, not found, exception, busy/concurrent scan, and keyboard submission; `services/apl_service_test.dart`: existing and nonexistent UPC service results. Both inherited files were among the baseline compilation failures. | **Relatively strong source intent; no executable baseline evidence** | No successful-result → unknown-result stale-state sequence; no explicit empty manual submission check; no proof that identification alone leaves the basket unchanged; no cancelled barcode capture; no direct-lookup eligibility ambiguity. |

## Inherited-suite execution limitation

The as-is baseline `flutter test` run failed overall. Twenty-two inherited
tests in balances, login, and signup passed before or among the failures, but
five test files—state, basket, scan, QR checkout, and APL service—did not
compile. Fresh dependency resolution selected `cloud_firestore` 6.8.0 and
`fake_cloud_firestore` 4.1.1, whose `WriteBatch.update` interfaces are
incompatible. Therefore, source code in the files shows what the
original team intended to test, but it is not current executable evidence.
This is dependency/code-rot evidence and was reported rather than repaired.

## Overall inherited-test judgment for UC1–UC5

The inherited suite is strongest around visible signup/login validation and
the intended product-lookup paths. It is weakest around multi-stage failures,
persistent session recovery, and complete sign-out postconditions. In
particular, it verifies successful registration but not failure between
account creation and profile persistence, and it verifies calls to Firebase
sign-out without proving safe failure handling or local-data cleanup.

Abigail’s suite exposes both blind spots with honest failures:

1. `test_uc01_profile_save_failure_does_not_complete_registration_flow` — the
   Firestore exception escapes and no recovery message appears.
2. `test_uc03_sign_out_failure_leaves_shopper_signed_in` — login navigation
   does not occur, but the Firebase authentication exception escapes instead
   of being handled safely.

The inherited tests therefore provide partial coverage of UC1–UC5 but do not
establish all five use cases’ complete postconditions. The Project 1a tests
add traceable evidence without modifying the inherited product.

