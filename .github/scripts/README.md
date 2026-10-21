# CI badge evidence

The [Flutter CI workflow](../workflows/flutter-ci.yml) retains the existing
build, test, formatter, and analyzer checks. Reporting consumes their actual
step outcomes plus the Flutter JSON test report and LCOV output. It does not
change a failed check into a passing one.

## What the badges mean

| Badge | Evidence |
| --- | --- |
| Web build | `flutter build web --release --no-pub` outcome |
| Flutter tests | Visible test results from the JSON reporter, excluding hidden successful loading/setup events; skipped tests shown separately |
| Dart line coverage | Unique covered/total DA lines in the generated `lcov.info`; no additional exclusions |
| Style and syntax | Both show the **same** strict `flutter analyze` result using `Project2/analysis_options.yaml`; they are not separate tools or independent checks |
| Dart format | `dart format --output=none --set-exit-if-changed lib test tool` outcome |
| Firebase config | `verify_firebase_config.py` outcome; local config consistency, not database access |
| Python checks | Python job result, including M0/APL tests and reporting tests |
| JS tests | Node importer and evidence-publisher test job result |

No passing test percentage is inferred from an overall workflow badge. Test
counts exclude skips from the denominator, report late errors as failures, and
mark incomplete runs. Missing reports are unavailable. Coverage is unavailable
unless the Flutter test run completes successfully. LCOV does not measure
Python/JavaScript or all repository lines; a blue coverage badge is a measured
number, not a coverage-threshold pass.

## Publication

After a branch-push run, a separate job writes generated SVGs, a readable
README, metadata, test output, and LCOV to the `ci-evidence` branch under the
source branch's name. It needs `contents: write` through GitHub's built-in
`GITHUB_TOKEN`; no personal token or third-party account is needed. Repository
or organization rules can still prohibit publication and must be checked in
the first run. Testing jobs retain read-only permissions. Pull requests never
run the publishing job.

The publisher uses a normal, non-forced commit, preserves other source branch
reports, and replaces the current report directory to prevent stale input
files surviving a failed run. A single publication queue prevents concurrent
writes. Runs for an obsolete source commit or older rerun do not overwrite a
newer report. A cancelled run or failed publisher can leave the last report
visible, so the report identifies its commit, run, attempt, and timestamp.

The README's nine generated badges link to `ci-evidence/main`, and its
combined-workflow badge is filtered to pushes to `main`. Each report identifies
the source commit and CI run that produced it. Before submission, verify that
the published report matches the intended submission commit; a successful push
alone does not confirm that report publication has finished.

This reporting branch is separate from GitHub Pages and does not publish Dart
documentation. The existing docs deployment remains restricted to pushes to
`main`, as before. Zenodo still requires the actual release DOI; this workflow
does not create one.

## Local verification

From the repository root:

```sh
python3 -m unittest discover -s .github/scripts -p 'test_*.py' -v
node --test .github/scripts/test_publish_ci_evidence.cjs
```

The parser uses Python's standard library and the publisher uses the
`github-script` action's existing GitHub client. Generated outputs belong in
a temporary directory locally; CI publishes them to the evidence branch.

Protocol references: [Dart JSON test reporter](https://github.com/dart-lang/test/blob/master/pkgs/test/doc/json_reporter.md)
and [GitHub token permissions](https://docs.github.com/en/actions/tutorials/authenticate-with-github_token).
