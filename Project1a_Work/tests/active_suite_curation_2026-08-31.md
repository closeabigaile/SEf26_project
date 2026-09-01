# Active-suite curation record: 2026-08-31

The branch-original Project 1a files were copied unchanged to the local-only
directory `C:\Users\adity\Coding\SEProject1\local_test_archive\project1a_branch_originals`.
That directory is outside this Git worktree and will not be pushed.

## Tests added to the active suite

`project1a_coverage_gaps_test.dart` adds 11 tests:

- UC14: under-cap increment and missing-product no-op;
- UC15: missing original product cannot create a paid line;
- UC8, UC14, UC16, and UC17: successful Firestore persistence;
- UC17: cancel and confirm paths through the clear-basket dialog; and
- UC20: successful checkout persistence and persistence-failure behavior.

## Team-designed suite curation

The four assigned Project 1a files originally contained 76 tests. Two
team-designed tests were initially removed as overlaps:

- UC11: category-cap rejection from Satwi's file.
- UC19: QR-widget existence from Supreme's file.

After review, the team-authored UC19 test was restored so that every finalized
use case retains an active team-designed test. The current D3 suite is therefore
76 original tests minus one UC11 overlap plus 11 gap tests: 86 tests total.

The local archive preserves the four original assigned files unchanged.

## Inherited-suite review

During curation, 19 overlapping tests from the prior project's inherited suite
were temporarily removed from broad Flutter discovery:

- Signup: empty-form validation; successful registration workflow.
- Login: invalid-email validation; short-password validation; successful
  button-submitted login.
- Balances: logout action.
- AppState: add, increment, decrement, remove-at-zero, and category-cap cases.
- Scan: found, not-found, exception, concurrent-request, and healthier-item-add
  cases.
- Basket: empty-state/navigation, item rendering, and paid-intent cases.

All 19 were subsequently restored to their original files exactly as they
existed before commit `8461250`. This leaves the inherited suite unchanged for
D4 assessment. It does not affect D3 because the documented Project 1a command
selects only `test/project1a` and the 11-test gap file; inherited directories are
not selected. The inherited QR test remains alongside the restored team-authored
UC19 test; both verify QR presentation, while payload and cashier
interoperability remain coverage gaps.
