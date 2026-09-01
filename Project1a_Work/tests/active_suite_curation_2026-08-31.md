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

## Duplicate tests removed from the active suite

The following 21 weaker duplicates were initially removed from Git's active
test discovery and remain recoverable in the local archive:

- Signup: empty-form validation; successful registration workflow.
- Login: invalid-email validation; short-password validation; successful
  button-submitted login.
- Balances: logout action.
- AppState: add, increment, decrement, remove-at-zero, and category-cap cases.
- Scan: found, not-found, exception, concurrent-request, and healthier-item-add
  cases.
- Basket: empty-state/navigation, item rendering, and paid-intent cases.
- UC11: category-cap rejection from Satwi's file.
- UC19: QR-widget existence from Supreme's file.

After review, the team-authored UC19 test was restored so that every finalized
use case retains an active team-designed test. The inherited QR checkout test
also remains active; both currently verify QR-widget presentation, while direct
payload and cashier-interoperability validation remain coverage gaps. Therefore,
20 of the 21 initially removed duplicates remain outside active discovery.
