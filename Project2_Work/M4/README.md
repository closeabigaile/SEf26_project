# M4 Checkout Help

**Current implementation:** see the [Issue 3 frontend and demo guide](issue3_frontend.md).
The basket provides per-item help and a separate read-only sample basket using
the same action and dialog. All 139 M4 tests pass locally. Real evidence-provider integration and CI verification
remain outstanding.

Issue 1 prepared **mock data and expected messages only**. The four records are in
[checkout_help_scenarios.json](../../Project3/assets/mock/checkout_help_scenarios.json)
and follow the accepted [M0/M4 shared use cases](../M0/m4_checkout_help_use_cases.md).
The three primary scenario IDs and the additional fallback ID are unchanged.

**All items, benefit rules, balances, and rejection circumstances are synthetic.**
The scenario supplies a scripted rejection while the affected item remains in
the basket. These records are not real checkout responses, official benefit
rules, participant observations, or evidence that M4 is useful. The app is not
detecting a real checkout rejection.

## Issue 1 Completion

* Prepared all four cases: `M0-M4-01`, `M0-M4-02`, `M0-M4-03`, and
  `M0-M4-F01`.
* Included mock item identity, original benefit category, package-size
  information, benefit balances, and freshness. Unavailable evidence is
  explicitly represented as `null` or `unknown`.
* Documented the expected explanation and next step for every case, along with
  the synthetic-data and scenario-supplied rejection limitations.
* Validated that the JSON parses without duplicate keys, the four scenario IDs
  and item IDs are unique, and the fixture preconditions match the shared M0
  specification.
* Verified that every expected explanation and next step matches the shared M0
  wording and that the documentation links resolve.

Issue 1's data and documentation are complete. Those checks validate the mock
records; they are not M4 feature-test or CI results. See the Issue 4 section
below for the service tests added after Issue 2's logic implementation.

## Prepared Cases

| Scenario | Prepared evidence | Expected help |
| --- | --- | --- |
| M0-M4-01: Package-size mismatch | One 24 oz cereal package; only 18 oz permitted; one mock unit required and one available; current item and benefit information. | Explain the possible size mismatch; suggest checking current benefit information and looking for an otherwise eligible 18 oz package. |
| M0-M4-02: Insufficient category balance | One 18 oz cereal package matching the permitted size; one mock unit required and zero available after other allocations; no allocation to this item; current information. The basket line is `PAID`, but its original category is `CEREAL`. | Explain the possible shortfall; suggest reviewing cereal balance and reducing covered quantity. A same-category substitution alone does not restore coverage. |
| M0-M4-03: Outdated information | One 18 oz cereal package with current item information, but an explicitly `outdated` benefit record and no verified current replacement. Usable coverage, size-rule, and balance evidence is unavailable. | Explain that the information may be outdated; suggest verifying current information or asking the cashier. Do not assert a size mismatch or exhausted balance. |
| M0-M4-F01: Unable to determine | An identified cereal item, but missing package-size rules and balance details; freshness is `unknown`. | Say that the cause cannot be determined; suggest checking with the cashier and consulting current benefit information. |

Each record's `expected_help` contains the complete explanation and next step
from the shared M0 specification. These are expected outputs for tests,
not answers copied by the implemented logic. F01 instantiates the shared
missing-evidence fallback; additional ambiguous/conflicting variants belong in
later tests.

## Record Format

The file is a JSON object with `schema_version: 1`, `synthetic: true`, common
`rejection_context`, and a `scenarios` array. Every scenario also has its own
`synthetic: true` marker. The common rejection context applies to all four cases;
`official_reason: null` means that no official reason was received.

| Field | Meaning |
| --- | --- |
| `scenario_id` | Shared M0 identifier for selecting a case and tracing evidence. It is not evidence from which to infer the rejection cause. |
| `input.item.id`, `name` | Stable mock identity and display name. IDs are not real UPCs and must not be sent to an APL or retailer service. |
| `original_benefit_category` | The affected item's original category, `CEREAL`, including when its basket line is marked `PAID`. |
| `basket_category` | The existing basket classification to preserve while viewing help. `CEREAL` does not guarantee official benefit coverage. |
| `quantity` | Number of packages in the affected basket line; one in these prepared cases. |
| `package_size`, `permitted_package_size` | Selected and permitted package sizes, each with `value` and `unit`, or `null` when unavailable. `oz` describes package weight, not nutrition serving amounts or benefit units. |
| `input.benefit.category`, `category_covered` | The mock rule's category and whether current evidence establishes category coverage. `null` means unknown, not false. |
| `required_units` | Mock benefit units needed for the affected line's entire quantity. It is one in the three primary cases; it does not establish eligibility. |
| `available_units_after_other_allocations` | Mock units available to cover this affected item after allocations to other items. This is supplied evidence, not calculated from or written to live app balances. |
| `units_allocated_to_affected_item` | Existing allocation to this item. It is zero in the size and balance cases and unknown in the other two. Do not subtract it again from availability after other allocations. |
| `input.benefit.unit` | `mock_benefit_unit`; one fictional count unit, not an official allowance or an ounce. |
| `information_freshness` | Separate status on the item and benefit record: `current`, `outdated`, or `unknown`. These fixture labels are not derived from timestamps. |
| `verified_current_replacement_available` | Whether a separate verified current benefit record is available. False in these fixtures; the `current` records in cases 01 and 02 are already usable. |
| `expected_help.possible_cause` | Expected result label: `package_size_mismatch`, `insufficient_category_balance`, `outdated_information`, or `unable_to_determine`. |
| `expected_help.explanation`, `suggested_next_step` | Expected wording for the explanation and next step, kept separate from the input evidence. |

**Keep missing values as `null`.** Do not replace unknown balances with zero or
unknown coverage with false. Missing or `unknown` freshness does not establish
staleness. In case 03, only the explicit `outdated` status establishes the stale
information scenario; its unavailable values cannot establish another cause.

## How to Use the Records

From the repository root, inspect a case with Python's standard library:

```bash
python3 - <<'PY'
import json
from pathlib import Path

path = Path("Project3/assets/mock/checkout_help_scenarios.json")
dataset = json.loads(path.read_text(encoding="utf-8"))
case = next(c for c in dataset["scenarios"] if c["scenario_id"] == "M0-M4-01")
print(json.dumps(case, indent=2))
PY
```

Decode this JSON and pass a case's `input.item` and `input.benefit`
to `CheckoutHelpService.explain`. Use the records as evidence; do not choose
the answer from `scenario_id` or return `expected_help` as the implementation.
The service tests compare the computed result with `expected_help`. Decode a fresh
copy for each test so mutations cannot affect another case.

For Flutter tests run from `Project3`, the relative file path is
`assets/mock/checkout_help_scenarios.json`. The file is located under assets so
the basket integration registers it in `pubspec.yaml` and loads it for the
prepared frontend demonstration. These evidence records are not replacements
for `AppState` basket or balance maps. The repository requires explicit synthetic
linkage and matching identity, quantity, and classifications before using a
scenario for a basket line. Ordinary basket items receive the fallback until a
verified evidence provider is connected. The sample basket never adds records
to the shopper's basket.

The mock records do not have the trial-outcome fields used by M0's scoring
script. Do not pass this file to `evaluate_checkout_trials.py`; that script
continues to use its separate trial records.

## Original Issue 1 Scope and Later Work

* Issue 2 implements the checkout-help rules.
* Issue 3 implements the basket action, help dialog/panel, and close behavior.
* Issue 4 adds unit and widget tests. Issue 5 verifies CI and records results.
* Help must eventually preserve every basket item, quantity, payment
  classification, and benefit balance. It must not complete checkout, reset
  usage, or apply the suggested next step automatically. Issue 1 specifies
  these expectations; it does not verify that behavior.
* This task does not change M1 nutrition handling, M2 catalogs or swap rules,
  M3 layouts, application state/storage, or the shared M0 specification.

Participant testing was not conducted. Feature behavior and user usefulness
remain unverified by this data-preparation task.

## Issue 4: Local Automated Tests

**Local completion verified on 2026-09-29:** all 139 M4 tests and the existing
50-test M0 baseline pass. See [Issue 4 verification](issue4_test_results.md)
for the acceptance checklist, fresh logs, commands, and CI scope distinction.

**Latest frontend results:** [Issue 3 frontend and demo guide](issue3_frontend.md).
The earlier [implementation and validation](implementation_results.md)
records fixes for all six M4 failures found by the earlier
[adversarial review](checkout_help_test_review.md). All nine review checks now
pass, along with the original service tests and new integration checks.
The earlier review is preserved as a record of the findings before these fixes.

The service portion is implemented in
[checkout_help_service_test.dart](../../Project3/test/services/checkout_help_service_test.dart).
Run it from `Project3` with:

```bash
flutter test --no-pub test/services/checkout_help_service_test.dart --concurrency=1 --reporter expanded
```

Use `flutter pub get` first if dependencies have not already been installed.
The service tests read the JSON file directly, so app asset registration is not
required for this suite.

Local validation on 2026-09-27: **102 service tests passed**, expanded from the
initial 62 tests. The **50-test M0 baseline also passed without regression**.
See [Issue 4 local test results](issue4_test_results.md) for commands, raw logs,
failures found and resolved, and completed widget/state coverage. The service suite covers:

* All three shared causes and the fallback, comparing all three result fields
  against the fixture's complete expected messages.
* Unchanged inputs, including nested read-only maps and repeated calls.
* Other categories, sizes, matching measurement units, and benefit amounts;
  original category retention for a `PAID` line; and independence from IDs and
  expected-answer fields.
* Equal/sufficient balances, competing causes, explicit versus unknown
  freshness, missing fields, conflicting categories, incompatible size units,
  malformed values, and unsupported allocation/replacement evidence.
* Smaller-than-permitted packages, text normalization, numeric strings and
  booleans, whole-number doubles, negative floating-point zero, very large
  finite numbers, and independence between consecutive calls.

The size-mismatch fixture now uses the approved general wording, “lists a
permitted package size of 18 oz,” instead of “lists an 18 oz package.” Its
meaning and next step remain consistent with the shared M0/M4 specification.
The test compares this expected text directly, without rewriting it at runtime.

The original 102 tests cover the service. The added
[widget and state tests](../../Project3/test/screens/checkout_help_screen_test.dart)
now verify opening and closing help for all four scenarios, selected-item
identity, unchanged basket and benefit state, and protection against stale or
mismatched evidence. See the latest report for commands and limitations.
Real-data integration, participant usefulness, and CI success are not established
by these local tests. Issue 5 still owns CI verification.
