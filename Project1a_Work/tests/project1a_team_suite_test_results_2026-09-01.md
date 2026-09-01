# Project 1a team-suite test results: 2026-09-01

## Result

- Scope: the four files under `Project3/test/project1a` plus
  `Project3/test/active/project1a_coverage_gaps_test.dart`
- Excluded: inherited tests under `test/screens`, `test/services`, and
  `test/state`
- Flutter: 3.47.2 stable
- Command: `flutter test test/project1a
  test/active/project1a_coverage_gaps_test.dart --concurrency=1 --coverage
  --reporter expanded`
- Executed: 86
- Passed: 82 (95.3%)
- Failed: 4 (4.7%)
- Executable-line coverage: 891 of 1,150 lines (77.5%)

The command exited with status 1 because four intentionally retained tests
exposed application/requirement mismatches. The complete expanded output is
preserved in
`Project1a_Work/raw_test_output/project1a_team_suite_2026-09-01.txt`.

## Failing Project 1a tests

1. `test_uc01_profile_save_failure_does_not_complete_registration_flow`
   (UC1): a Firestore profile-save exception escapes without a visible error.
2. `test_uc03_sign_out_failure_leaves_shopper_signed_in` (UC3): a rejected
   sign-out escapes instead of being handled while preserving the session.
3. `UC7-T6 blank category -> no search results` (UC7): the direct service-level
   test returns a candidate for a blank category, although the production
   screen guards against making that call. This is a test-scope mismatch.
4. `UC9-T2 rejected alternative -> must not report success` (UC9): the UI
   reports that an alternative was added after `AppState.addItem` rejects it.

## Passing evidence

- All 11 post-curation gap tests passed.
- The restored team-authored UC19 QR-rendering test passed.
- No Flutter shader/renderer failures occurred in this team-only run.

## Relationship to inherited tests

The inherited WolfBite tests are reviewed separately for D4. Their execution
results and environment failures are not included in the Project 1a D3 totals
above.
