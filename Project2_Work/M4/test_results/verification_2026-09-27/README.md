# Full test rerun — 2026-09-27

Fresh verification of the current working tree. No production code or tests
were changed for this run.

| Suite | Passed | Failed |
| --- | ---: | ---: |
| All Project3 Flutter tests | 273 | 4 |
| M4 subset (included above) | 134 | 0 |
| M0 checkout baseline subset (included above) | 50 | 0 |
| Python M0 scoring tests | 13 | 0 |

**Overall: 286 passed, 4 failed across 290 tests.** The two subsets must not be
added to the total again. The four Flutter failures match the previous run:

- UC7-T6: a blank category returns healthier alternatives rather than none.
- UC9-T2: a rejected alternative still produces an added-success message.
- UC1: profile-save failure raises an unhandled error during signup.
- UC3: sign-out failure raises an unhandled error.

See [Flutter output](full_suite.txt) and [Python output](m0_scoring.txt).
All automated test files discovered in this repository are covered by these
commands. This was local validation, not a CI or physical-device run.

From `Project3`:

```bash
flutter test --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/verification_2026-09-27/full_suite.txt
```

From the repository root:

```bash
python3 -m unittest discover -s Project2_Work/M0 -p 'test_*.py' -v
```

Flutter was invoked using the installed SDK at
`/Users/abigailclose/Documents/Flutter SDK/flutter/bin/flutter` with permission
to access its cache. Python output was redirected to `m0_scoring.txt`.
