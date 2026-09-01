# Project 1a Test Execution

Project 1a requires the team-designed tests to be run and reported separately
from the tests inherited with WolfBite. The current team suite contains the
four assigned use-case files plus the post-curation coverage-gap file.

From `Project3`, run only the 86 team-designed Project 1a tests with:

```text
flutter test test/project1a test/active/project1a_coverage_gaps_test.dart --concurrency=1 --coverage --reporter expanded
```

To save the expanded output as submission evidence, add:

```text
--file-reporter expanded:../Project1a_Work/raw_test_output/project1a_team_suite_2026-09-01.txt
```

The inherited tests under `test/screens`, `test/services`, and `test/state`
are assessed separately for D4. They are not part of the Project 1a D3 result.

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

## Team-designed source files

The curated suite includes:

- `test/project1a/abigail_uc1-5_test.dart`
- `test/project1a/aditya_uc6-10_test.dart`
- `test/project1a/satwi_uc11-15_test.dart`
- `test/project1a/supreme_uc16-20_test.dart`
- `test/active/project1a_coverage_gaps_test.dart`.

The single worker is intentional because it minimizes concurrent Flutter
engine and renderer activity on the host.
