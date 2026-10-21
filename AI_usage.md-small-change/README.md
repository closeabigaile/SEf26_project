# WolfBite CI evidence

Branch: `AI_usage.md-small-change`  
Commit: [`feec2f1d0b8b4f51f34fd69b61d70b5d3917731b`](https://github.com/closeabigaile/SEf26_project/commit/feec2f1d0b8b4f51f34fd69b61d70b5d3917731b)  
[GitHub Actions run](https://github.com/closeabigaile/SEf26_project/actions/runs/39524662050)  
Generated: 2026-10-21T01:02:52.939983+00:00

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
