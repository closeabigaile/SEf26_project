# M4 Issue 4: Local Test Results

> Historical results before the implementation fixes. See
> [current implementation and validation](implementation_results.md): the
> six M4 review failures are resolved and the basket interface is implemented.

On 2026-09-27, **102 checkout-help service tests and all 50 M0 baseline tests
passed locally**. No tests were skipped in these runs. Service and test-file
analysis also passed. **Issue 4 is still incomplete:** checkout-help widget
and application-state preservation tests depend on Issue 3's interface.

## Results and Evidence

| Selection | Passed | Failed | Evidence |
| --- | ---: | ---: | --- |
| Final checkout-help service suite | 102 | 0 | [Service output](test_results/service_final_2026-09-27.txt) |
| M0 team checkout/basket tests | 38 | 0 | [Team output](test_results/baseline_team_2026-09-27.txt) |
| M0 selected UC8 allowance tests | 5 | 0 | [Allowance output](test_results/baseline_allowance_2026-09-27.txt) |
| M0 inherited QR and basket tests | 7 | 0 | [Inherited output](test_results/baseline_inherited_2026-09-27.txt) |

[Dart analysis](test_results/analysis_2026-09-27.txt) found no issues in the
service or its tests. These are results for the local working tree on
`M4_implementation_CHeckout_help`, based on HEAD
`76d50a2dd137afd11c9e8a4b24bd841640b8b641`, including the uncommitted service,
tests, and fixture wording update. The existing analyzer exclusions were retained.
These results do not describe a clean checkout or a GitHub Actions run.

## Service Coverage

The [service suite](../../Project3/test/services/checkout_help_service_test.dart)
uses fresh Issue 1 records for each test. All four shared scenarios compare the
complete possible-cause label, explanation, and suggested next step against
`expected_help`. The approved general package-size wording is stored directly
in the fixture; tests do not rewrite expected answers to match actual output.

The additional cases cover:

* Missing or unknown freshness versus explicitly outdated product or benefit
  evidence, including one outdated record while the other is unknown.
* Conflicting causes and categories, unavailable evidence, unsupported
  replacements or allocations, and incompatible package-size units.
* Original benefit category on a `PAID` line, equal and sufficient balances,
  whole-line required amounts, and dynamic category/size/balance messages.
* Smaller-than-permitted packages, whole-number doubles, whitespace and case
  differences in category/unit text, empty text, malformed maps and lists,
  boolean values, numeric strings, negative values, NaN, and infinity.
* Negative floating-point zero and very large finite numbers. The latter are
  numeric-safety cases, not claims about realistic product or benefit rules.
* Unchanged records on valid and ambiguous paths, nested read-only inputs,
  repeated calls, alternating scenarios on one service instance, and results
  that remain unchanged when the caller later edits its original input.

The suite exercises the service's public behavior. It does not use live
Firebase records or participants.

## Failures Encountered and Resolved

1. The [initial expanded run](test_results/service_initial_edge_run_2026-09-27.txt)
   passed 99 tests and failed 1. Formatting `1e20` with `toInt()` changed the
   displayed size to `9223372036854775807`. The service now removes a trailing
   `.0` from the string representation instead of converting the number to an
   integer, and displays floating-point negative zero as `0`.
2. The [follow-up run](test_results/service_notation_check_2026-09-27.txt)
   passed 100 tests and failed 2. The number was now correct, but two test
   assertions unnecessarily required scientific notation (`1e+20`) instead of
   allowing the equivalent decimal text (`100000000000000000000`). Those
   assertions now parse the displayed amount and compare its numeric value.
   They still detect the original overflow bug.
3. The final service run passed all 102 tests. No M0 baseline failures or
   regressions were observed. The baseline test selections and source files
   were unchanged, and the original M0 result logs were preserved.

Flutter needed permission to write its SDK cache outside the workspace. The
earlier sandboxed test launch stopped before executing tests; this was an
environment restriction, not a test failure. The runs recorded here used the
approved Flutter invocation and existing dependencies (`--no-pub`).

## Commands

Run from `Project3`, with dependencies installed. Use a new filename when
recording a later run so these results remain available.

```bash
mkdir -p ../Project2_Work/M4/test_results

flutter test test/services/checkout_help_service_test.dart \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/service_final_2026-09-27.txt

flutter test test/project1a/supreme_uc16-20_test.dart \
  test/project1a/satwi_uc11-15_test.dart \
  test/active/project1a_coverage_gaps_test.dart \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/baseline_team_2026-09-27.txt

flutter test test/project1a/aditya_uc6-10_test.dart \
  --plain-name 'UC8 - Add product to basket' \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/baseline_allowance_2026-09-27.txt

flutter test test/screens/qr_checkout_screen_test.dart \
  test/screens/basket_screen_test.dart \
  --no-pub --concurrency=1 --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/baseline_inherited_2026-09-27.txt

dart analyze lib/services/checkout_help_service.dart \
  test/services/checkout_help_service_test.dart
```

The two development runs used the same service-test command with the output
filenames linked above and the code/test versions described in the failure
notes. Formatting was checked with `dart format` on the service and test file;
`git diff --check` also passed.

## Remaining Work and Limits

* **Widget tests: not implemented or run.** After Issue 3, test all four cases
  through the actual “Get checkout help” action. Verify the selected item,
  uncertainty/possible-cause wording, full explanation and next step, close
  behavior, and return to the basket.
* **Application-state preservation through help: not yet verified.** Compare
  all basket items, quantities, payment classifications, and benefit balances
  before opening and after closing help. Verify that neither checkout nor a
  benefit reset is invoked. Preserving service input maps alone does not prove
  this interface behavior.
* **M0 regression: 50/50 passed.** This preserves the documented baseline
  selection, not the entire app test suite. Its existing QR and persistence
  limitations still apply; see the [M0 baseline report](../M0/m0_baseline_checkout_results.md).
  The service is not wired into the basket yet, so rerun this baseline after
  Issue 3's integration.
* **Real-data integration: unverified.** The service still uses mock benefit
  units and conservative fallback for unsupported allocations/replacements.
  Numeric edge tests do not establish real benefit eligibility.
* **CI: not run for these local changes.** This report provides no M4 CI
  evidence. CI verification remains pending; no workflow was changed.
* **Participant testing and user usefulness: unverified.** Automated tests
  establish code behavior, not whether shoppers find the feature useful.
