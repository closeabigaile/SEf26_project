# Active Test Suite

The active suite is every test under `Project3/test`. Duplicate cases were
removed from the repository after their original source files were copied,
unchanged, to the local-only archive outside the Git worktree.

## Newly added active coverage

`project1a_coverage_gaps_test.dart` adds:

- UC14: a real under-cap quantity and covered-usage transition;
- UC14: a missing covered product leaves state unchanged;
- UC15: a missing original product cannot create a paid line;
- UC17: clear confirmation and cancellation through the real basket widget;
- UC8, UC14, UC16, and UC17: successful mutation persistence;
- UC20: checkout persists an empty basket while retaining benefit usage; and
- UC20: a save exception propagates while local state remains cleared.

## Selection rules

An existing test remains active when it supplies at least one unique:

- requirement or extension path;
- branch or decision outcome;
- exception path;
- state transition;
- meaningful boundary;
- widget/integration assertion; or
- persistence assertion.

When tests overlap, the active suite keeps the test with the stronger
postconditions. A historical test is not excluded merely because it fails.

## Active source files

The curated suite includes:

- `test/project1a/abigail_uc1-5_test.dart`
- `test/project1a/aditya_uc6-10_test.dart`
- `test/project1a/satwi_uc11-15_test.dart`
- `test/project1a/supreme_uc16-20_test.dart`
- the inherited tests under `test/screens`, `test/services`, and `test/state`;
- `test/active/project1a_coverage_gaps_test.dart`.

Run the suite from `Project3` with `flutter test --concurrency=1`. The single
worker is intentional because it minimizes concurrent Flutter engine and
renderer activity on the host.
