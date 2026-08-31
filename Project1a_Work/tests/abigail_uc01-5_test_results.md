# Abigail’s UC1–UC5 Test Results

**Author:** Abigail Close  
**Branch:** `tests/abigail-UC1-5`  
**Scope:** UC1–UC5  
**Product:** WolfBite  
**Execution date:** August 28, 2026  
**Command:** `flutter test test/project1a/abigail_uc1-5_test.dart --reporter expanded`  
**Result:** 25 tests executed: 23 passed and 2 failed because of inherited error-handling behavior.

These tests were designed from the finalized use cases before assessing the
project’s inherited tests. Expected results were recorded before test
implementation and execution. The two failing expectations were retained
rather than weakened to match the inherited implementation.

## UC1 — Create account

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc01_valid_registration_creates_account_and_profile` | UC1 main scenario requires valid information to create both an authentication account and shopper profile | Account creation is requested, the profile is saved under the new user ID, the initial session ends, and login becomes available | **PASS** — the exact credentials were sent once, the profile was saved under `test-user-123`, sign-out was requested, and navigation to `/login` occurred. |
| `test_uc01_blank_fields_prevent_submission` | UC1 extension 2a says blank or invalid required information must not be submitted | Validation messages identify the invalid fields, and no account-creation or profile-save request occurs | **PASS** — all four required-field messages appeared; neither account creation nor profile persistence was called. |
| `test_uc01_invalid_email_prevents_submission` | UC1 extension 2a requires invalid account information to be rejected | An email-validation message appears, and Firebase account creation is not requested | **PASS** — “Enter a valid email” appeared; no authentication or profile-save request occurred. |
| `test_uc01_rejected_registration_displays_error` | UC1 extension 3a says an account-creation rejection must be reported while signup remains available | A visible error appears, no profile is saved, and the shopper remains on the signup screen | **PASS** — “Email already in use” appeared, signup remained visible, and no profile save, sign-out, or login navigation occurred. |
| `test_uc01_profile_save_failure_does_not_complete_registration_flow` | UC1 extension 4a identifies a failure after the authentication account is created but before the profile is saved | The account-creation request succeeds, profile saving fails, an error is reported, and the application does not claim that registration completed | **FAIL** — account creation succeeded and profile saving was attempted, but the Firestore exception was uncaught and no error `SnackBar` appeared. Sign-out and login navigation did not occur. This is an inherited implementation mismatch. |

## UC2 — Sign in

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc02_valid_credentials_authenticate_and_open_shopping_features` | UC2 main scenario and postcondition require valid credentials to authenticate the shopper and provide protected access | Firebase authentication is requested with the entered credentials, and WolfBite navigates to the protected shopping interface | **PASS** — the exact credentials were sent once and navigation to `/scan` occurred. |
| `test_uc02_invalid_email_prevents_authentication` | UC2 extension 2a says an invalid email format must be reported without authenticating | An invalid-email message appears, and Firebase authentication is not requested | **PASS** — “Invalid email” appeared; authentication and protected navigation were not requested. |
| `test_uc02_short_password_prevents_authentication` | UC2 extension 2b says passwords shorter than six characters must be rejected | A minimum-length message appears, and Firebase authentication is not requested | **PASS** — a five-character password produced “Min 6 chars”; authentication and protected navigation were not requested. |
| `test_uc02_rejected_credentials_leave_shopper_signed_out` | UC2 extension 3a says rejected authentication must be reported and the shopper must remain signed out | A visible authentication error appears, and the application does not navigate to protected shopping features | **PASS** — “Invalid credentials” appeared, the login interface remained visible, and `/scan` navigation did not occur. |
| `test_uc02_second_submission_is_blocked_while_sign_in_is_pending` | UC2 extension 3b says another submission must be prevented while a sign-in request is active | While the first request is pending, a second action does not create another Firebase authentication request | **PASS** — the pending request displayed a progress indicator and removed the active Sign In button; Firebase received exactly one request. |

## UC3 — Sign out

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc03_logout_action_requests_authentication_sign_out` | UC3 main scenario steps 1–2 require the shopper’s logout action to end the authenticated session | Pressing the logout control calls Firebase Authentication’s sign-out operation exactly once | **PASS** — pressing the logout icon called `signOut()` exactly once. |
| `test_uc03_successful_sign_out_returns_shopper_to_login` | UC3 main scenario step 4 and postcondition require sign-in to become available after sign-out | After authentication ends, the protected interface is no longer available and the login interface is made available | **PASS** — successful sign-out requested navigation to `/login`. |
| `test_uc03_successful_sign_out_removes_account_specific_local_state` | UC3 main scenario step 3 says account-specific shopping information must be removed from the current session | The current basket, balances, and account-specific shopping information are unavailable locally after sign-out | **PASS** — changing the production state manager to a signed-out user cleared the basket and balances and reset the loaded flag. |
| `test_uc03_sign_out_failure_leaves_shopper_signed_in` | UC3 extension 2a says the shopper remains signed in when sign-out fails | A failed Firebase sign-out operation does not transition the application into a signed-out state | **FAIL** — the screen did not navigate to `/login`, but the Firebase authentication exception was uncaught instead of being handled safely. This is an inherited implementation mismatch. |
| `test_uc03_existing_signed_out_state_still_returns_to_login` | UC3 extension 4a says an already-detected signed-out state must still return the shopper to sign-in | When authentication state already contains no user, WolfBite presents the login interface instead of protected shopping features | **PASS** — the signed-out state was empty, the real login interface appeared, and the protected Scan Product interface was absent. |

## UC4 — Resume shopping session

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc04_current_month_saved_session_restores_basket_and_balances` | UC4 main scenario requires the shopper’s saved basket, quantities, product data, and benefit usage to be restored | The saved basket and balances are loaded for the authenticated shopper and marked available | **PASS** — the MILK usage, product, quantity, name, and saved nutrition value were restored. |
| `test_uc04_missing_saved_session_starts_empty` | UC4 extension 2a says a shopper with no saved shopping information must receive a new empty session | Loading completes with an empty basket and default or empty shopping information | **PASS** — loading completed with empty basket and balances, and a new empty Firestore scaffold was persisted. |
| `test_uc04_partial_saved_session_uses_empty_values_for_missing_sections` | UC4 extension 3a says available information is restored while missing basket or benefit data is replaced with empty values | Existing saved information is restored, missing sections do not crash loading, and missing collections become empty | **PASS** — the available MILK balance was restored and the absent basket became empty without a loading failure. |
| `test_uc04_missing_nutrition_uses_zero_values` | UC4 extension 3b says missing product nutrition must be replaced with zero-valued nutrition fields | The product is restored successfully and its missing nutrition fields contain zero defaults | **PASS** — restoration succeeded and calories, total fat, sodium, sugar, and protein all defaulted to `0.0`. |
| `test_uc04_previous_month_session_resets_basket_and_used_benefits` | UC4 extension 4a says activity from an earlier month or year must be reset | The old basket is cleared, used benefits return to their reset values, and the new-month state is made available | **PASS** — a prior-year session produced an empty active basket and reset MILK and CEREAL usage to zero. |

## UC5 — Identify product

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `test_uc05_matching_upc_displays_product_information` | UC5 main scenario requires a matching product’s name, category, code, and available nutrition summary to be presented | A lookup request is made for the entered UPC, and the matching product information appears without changing the basket | **PASS** — the exact UPC was looked up, product name/category/code appeared, and no basket addition occurred. |
| `test_uc05_empty_manual_entry_performs_no_lookup` | UC5 extension 1b says empty manual entry must not perform a lookup | The product service is not called, no product result appears, and the basket remains unchanged | **PASS** — the service was never called, no product appeared, and the basket remained empty. |
| `test_uc05_unknown_upc_reports_not_found_and_clears_result` | UC5 extension 2b says an unmatched code must be reported and the current product result cleared | A not-found message appears, no product remains selected, and the basket is unchanged | **PASS** — after an initial successful result, the unknown UPC produced the not-found message, cleared the previous product, and left the basket empty. |
| `test_uc05_lookup_failure_displays_error` | UC5 extension 2c says a product-lookup failure must be reported | A visible error message appears, no matching product is presented, and the basket remains unchanged | **PASS** — the simulated service exception produced a visible lookup error; no product appeared and the basket remained empty. |
| `test_uc05_second_lookup_is_ignored_while_first_is_pending` | UC5 extension 2a says a new request must be ignored while another lookup is active | Repeated submission during a pending lookup does not start a second product-service request | **PASS** — while the controlled first lookup `Future` was pending, a second press did not produce another service call. |

## Findings summary

- **UC1 extension 4a:** WolfBite catches `FirebaseAuthException` during signup,
  but does not catch a Firestore profile-save exception. The exception escapes
  and the shopper receives no recovery message.
- **UC3 extension 2a:** the sign-out screen awaits Firebase directly without
  catching authentication errors. Navigation correctly does not occur, but the
  exception escapes rather than being handled.

