# M4 Issue 5: Integration and CI Verification

**Result: the Issue 5 acceptance checks passed for the agreed synthetic-data
scope on September 29, 2026.** Participant testing was not conducted. Actual
user usefulness remains unverified.

**Tested implementation/workflow commit:**
`c442dca7966543088623a4cbabcfdb68103ea829`, on
`M4_implementation_CHeckout_help`. This includes the completed implementation
and tests from `2a882ec`. Later documentation commits record this evidence;
they must not be confused with the tested implementation SHA.

## Local and GitHub results

Local tests ran from a fresh `git archive` of the tested commit, using Flutter
3.47.2 / Dart 3.13.2 and `flutter pub get --enforce-lockfile`. The commands
completed with exit code 0. **202 tests passed, 0 failed, 0 skipped.**

| Check | Local result | GitHub result on tested commit |
| --- | --- | --- |
| M4 service, precision, repository, adversarial unit checks | 118 passed | [Unit job: success](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638/job/109695724170) |
| M4 widget/state and basket-action checks | 21 passed | [Widget job: success](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638/job/109695723997) |
| Existing M0 checkout baseline | 50 passed (38 + 5 + 7) | [Baseline job: success](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638/job/109695724475) |
| M0 scoring instrument | 13 passed | [Scoring job: success](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638/job/109695724277) |
| Known passing scoring example | PASS: 60% baseline, 80% M4, +20 points | Demonstration step succeeded |
| Known failing scoring example | FAIL as expected: 60%, 60%, +0 points | Demonstration step succeeded |

The widget/state selection contains 20 widget tests and one state persistence
test. The 139 M4 tests are the first two rows combined, not an additional count.
The failing synthetic example tests the scorer's ability to report an unmet
target; it is not a failed automated check or measured participant outcome.

The combined [M4 verification run 36654481638](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481638)
completed successfully. Each of its four jobs reports the exact SHA above.
Dependency installation and artifact-upload steps succeeded. Uploaded artifacts:
`m4-unit-results`, `m4-widget-results`, and `m0-checkout-baseline-results`.

The separate [M0 baseline run 36654481328](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481328)
and [M0 scoring run 36654481298](https://github.com/closeabigaile/SEf26_project/actions/runs/36654481298)
also succeeded on that SHA. The saved [run records](test_results/issue5_2026-09-29/github_runs.json),
[job/step records](test_results/issue5_2026-09-29/github_jobs.json), and
[artifact metadata](test_results/issue5_2026-09-29/github_artifacts.json)
were retrieved from the GitHub Actions API. CI test counts above are the
matching local selections; remote job and step conclusions were independently
verified. Remote artifact contents were not downloaded for this report.

## Workflow configuration

[m4-checkout-help.yml](../../.github/workflows/m4-checkout-help.yml) runs on
pushes and pull requests changing `Project3/**`, `Project2_Work/M0/**`,
`Project2_Work/M4/**`, or `.github/workflows/**`, and supports manual dispatch.
These paths include code, fixtures, tests, dependency files, and workflows.

The M4 unit/widget jobs use Ubuntu, pinned Flutter 3.47.2, locked dependencies,
and independent matrix jobs with fail-fast disabled. Reports upload even after
test failure. No tests are skipped and no failure is converted into success.
The workflow calls the existing M0 baseline and scoring workflows through
`workflow_call`, preserving their original checks. The scorer uses Python 3.12
in GitHub CI. All four groups run on the caller's commit.

## Feature walkthrough

The committed [walkthrough entry point](../../Project3/tool/m4_scenario_walkthrough.dart)
was launched from the same clean copy as the local tests. It initializes
explicit synthetic fixtures and local fake-Firestore state, then opens the
production `BasketScreen`. No service or dialog is replaced with a fake answer.

For every row, the intended basket card's **Get checkout help** was selected;
the displayed item, explanation, and suggested next step were inspected;
**Close** returned to **My Basket** with the same four items and total quantity 4.

| Scenario | Observed explanation and next step | Result |
| --- | --- | --- |
| M0-M4-01 | Possible 24 oz versus permitted 18 oz mismatch; check the label/current information and look for an otherwise eligible 18 oz package. | Pass |
| M0-M4-02 | Possible cereal shortfall: 0 available, 1 required; review balance and covered quantity. A same-category swap alone does not restore coverage. The item remains PAID. | Pass |
| M0-M4-03 | Information may be outdated; rejection cause remains uncertain. Verify current information or ask the cashier before retrying. | Pass |
| M0-M4-F01 | Unable to determine a possible cause; ask the cashier to check the item and consult current benefit information. | Pass |

Each dialog displayed **“This is guidance, not an official checkout decision.”**
and the synthetic-example notice. Messages match the
[shared M0/M4 specification](../M0/m4_checkout_help_use_cases.md), including
the already documented equivalent “permitted package size” wording for case 01.
Automated tests additionally compare complete fixture messages, not just labels.

## State preservation

The final observed walkthrough result was:

> PASS: basket and balances unchanged. Checkout calls: 0; reload calls: 0; clear calls: 0. CEREAL used: 3; PAID used: 1.

The walkthrough compares the full before/after basket and balances, including
item IDs, names, quantities, payment classifications, and original categories.
All four lines stayed at quantity 1; the balance-case line stayed PAID, the
other three stayed CEREAL. No products were replaced or removed, and neither
benefit allowance nor usage changed. Instrumented methods retain the real
AppState behavior and counted no checkout, reload, or clear calls.

The browser comparison covers the complete walkthrough. Separately, the
[screen/state tests](../../Project3/test/screens/checkout_help_screen_test.dart)
verify those properties **for each scenario**, both while help is open and after
closing. They also compare saved fake-Firestore data and deliberately set its
timestamp to a previous month after loading: an accidental reload would execute
the actual monthly reset and fail the assertions. This supports the no-reset
check beyond simply observing no visible quantity change.

The [walkthrough record](test_results/issue5_2026-09-29/walkthrough.txt)
records each observed result. It is a developer walkthrough, not participant testing.

## Commands and local evidence

The [actual local command script](test_results/issue5_2026-09-29/local_commands.sh)
was run at the root of a clean archive containing `Project3` and
`Project2_Work/M0`, with an adjacent `evidence` directory. Its relative paths
assume that archive layout; it is preserved as the execution record.

From `Project3`, the M4 commands were:

```bash
flutter pub get --enforce-lockfile
flutter test test/services/checkout_help_service_test.dart \
  test/services/checkout_help_precision_test.dart \
  test/services/checkout_help_repository_test.dart \
  test/m4_review/checkout_help_adversarial_test.dart \
  --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../evidence/m4_unit.txt
flutter test test/screens/checkout_help_screen_test.dart \
  test/m4_review/checkout_help_basket_acceptance_test.dart \
  --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../evidence/m4_widget.txt
flutter run -d web-server -t tool/m4_scenario_walkthrough.dart \
  --web-hostname 127.0.0.1 --web-port 8083 --no-pub
```

The script includes the exact three baseline commands, scorer tests, and both
examples. Local outputs: [unit](test_results/issue5_2026-09-29/m4_unit.txt),
[widget/state](test_results/issue5_2026-09-29/m4_widget.txt),
[baseline team](test_results/issue5_2026-09-29/m0_team.txt),
[allowance](test_results/issue5_2026-09-29/m0_allowance.txt),
[inherited](test_results/issue5_2026-09-29/m0_inherited.txt),
[scorer](test_results/issue5_2026-09-29/m0_scoring.txt),
[passing example](test_results/issue5_2026-09-29/scoring_passing_example.txt),
[failing example](test_results/issue5_2026-09-29/scoring_failing_example.txt),
and [dependency setup](test_results/issue5_2026-09-29/pub_get.txt).

## Failures and limitations

- No acceptance-test or CI failures occurred in this verification. Initial
  sandboxed GitHub access was blocked by DNS restrictions; approved access
  succeeded. Workflow YAML parsing and walkthrough static analysis passed.
- Flutter's dependency setup automatically added build/platform exclusions to
  the archived analyzer configuration. Application logic/tests stayed at the
  recorded commit. Dependency resolution used the committed lockfile.
- The recorded full-app run from September 27 still has four unrelated failures
  in alternatives/signup/logout. This selected acceptance run does not claim
  the full app is green, and those tests were not removed or weakened. Details
  remain in [Issue 4's report](issue4_test_results.md).
- The legacy full-app workflow still targets `Project2`; this workflow uses
  `Project3`. Repairing the legacy workflow is separate work.
- The feature uses synthetic product/benefit evidence. No live checkout reason,
  official eligibility decision, participant benefit account, or real cashier
  integration is established. Ordinary items without supported evidence fall back.
- Widget persistence assertions use fake Firestore. The browser walkthrough
  uses in-memory synthetic state, with no signed-in user. Physical-device and
  manual screen-reader testing were not performed. Browser interaction is not
  a full web-target numeric test suite.
- Participant testing was not conducted. The 60-second outcome, 80% success,
  20-percentage-point improvement, and actual user usefulness remain unverified.

The [M0 evaluation results](../M0/m0_evaluation_results.md) reference these
verified M4 checks while preserving that distinction.
