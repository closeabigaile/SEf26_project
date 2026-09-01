# Project 1a team-suite coverage: 2026-09-01

Coverage applies only to the 86 team-designed Project 1a tests. Inherited tests
under `test/screens`, `test/services`, and `test/state` were excluded.

## Instrumented code coverage

| Metric | Covered | Total | Percentage |
|---|---:|---:|---:|
| Executable lines | 891 | 1,150 | 77.5% |

Flutter's LCOV output did not contain branch records, so a numeric source-code
branch percentage cannot honestly be derived from that file.

## Use-case coverage audit

These values come from mapping test preconditions, actions, and assertions to
the written UC1-UC20 scenarios. They are not substitutions for LCOV line
coverage.

| Criterion | Covered | Total | Percentage | Assessment |
|---|---:|---:|---:|---|
| Main use-case outcomes | 18 | 20 | 90.0% | Good |
| Requirement and extension paths | 69 | 106 | 65.1% | Needs improvement |
| Branch/decision outcomes | 55 | 84 | 65.5% | Needs improvement |
| Exception paths | 7 | 19 | 36.8% | Priority gap |
| Persistence outcomes | 10 | 23 | 43.5% | Priority gap |
| State-transition paths | 69 | 106 | 65.1% | Needs improvement |

There are also 18 distinct meaningful boundary checks. A percentage is not
reported because the use cases do not define a finite denominator for every
possible input boundary.

The 77.5% executable-line result is acceptable for a student project and is
more informative than targeting 100% blindly. New work should prioritize the
specific exception and persistence gaps above; reaching 100% line coverage
would not prove correct requirements, assertions, or state transitions.
