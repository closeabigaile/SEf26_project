# WolfBite CI evidence

Branch: `dev`  
Commit: [`390fd25caef627f2da418060c298742ecb09f1e9`](https://github.com/closeabigaile/SEf26_project/commit/390fd25caef627f2da418060c298742ecb09f1e9)  
[GitHub Actions run](https://github.com/closeabigaile/SEf26_project/actions/runs/39520047867)  
Generated: 2026-10-21T00:17:41.729817+00:00

| Check | Result |
| --- | --- |
| Web build | success |
| Style (analysis) | success |
| Dart format | success |
| Syntax (analysis) | success |
| Python checks | success |
| JS tests | success |
| Firebase config | success |
| Flutter tests | 377/377 passing |
| Dart line coverage | 92.0% |

Style and syntax badges both report the same strict `flutter analyze` run,
configured by `Project3/analysis_options.yaml`. They are not independent checks.
Python checks include M0/APL tests, badge-report tests, and Firebase configuration validation.
The Firebase badge reports local configuration consistency, not live database access.

The test count covers visible Flutter tests; hidden successful loading/setup events
are excluded, skipped tests are listed separately, and late errors count as failures.
Coverage is the proportion of unique DA source lines hit in Flutter's LCOV file,
with no extra exclusions. It does not measure Python, JavaScript, or every repository line.
A failed/incomplete test run does not publish a passing coverage percentage.

Covered lines: **2388/2596**.

- [summary.json](summary.json)
- [steps.json](steps.json)
- [flutter-tests.jsonl](flutter-tests.jsonl)
- [lcov.info](lcov.info)


Reports update after completed branch-push runs; reruns and source commit are
recorded above. A cancelled run or failed publisher can leave the previous report
visible. Check the linked run and commit before citing a result.
