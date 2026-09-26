# M4 Checkout-Help Mock Cases

Issue 1 prepares **mock data and expected messages only**. The four records are in
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

Issue 1's data and documentation are complete. These checks validate the mock
records; they are not M4 feature-test or CI results. Checkout-help logic,
frontend behavior, and their automated tests remain work for later issues.

## Prepared Cases

| Scenario | Prepared evidence | Expected help |
| --- | --- | --- |
| M0-M4-01: Package-size mismatch | One 24 oz cereal package; only 18 oz permitted; one mock unit required and one available; current item and benefit information. | Explain the possible size mismatch; suggest checking current benefit information and looking for an otherwise eligible 18 oz package. |
| M0-M4-02: Insufficient category balance | One 18 oz cereal package matching the permitted size; one mock unit required and zero available after other allocations; no allocation to this item; current information. The basket line is `PAID`, but its original category is `CEREAL`. | Explain the possible shortfall; suggest reviewing cereal balance and reducing covered quantity. A same-category substitution alone does not restore coverage. |
| M0-M4-03: Outdated information | One 18 oz cereal package with current item information, but an explicitly `outdated` benefit record and no verified current replacement. Usable coverage, size-rule, and balance evidence is unavailable. | Explain that the information may be outdated; suggest verifying current information or asking the cashier. Do not assert a size mismatch or exhausted balance. |
| M0-M4-F01: Unable to determine | An identified cereal item, but missing package-size rules and balance details; freshness is `unknown`. | Say that the cause cannot be determined; suggest checking with the cashier and consulting current benefit information. |

Each record's `expected_help` contains the complete explanation and next step
from the shared M0 specification. These are expected outputs for later tests,
not results returned by implemented logic. F01 instantiates the shared
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

For Issue 2, decode this JSON and pass a case's `input.item` and `input.benefit`
to the future checkout-help logic. Use the records as evidence; do not choose
the answer from `scenario_id` or return `expected_help` as the implementation.
Later tests can compare the computed result with `expected_help`. Decode a fresh
copy for each test so mutations cannot affect another case.

For Flutter tests run from `Project3`, the relative file path is
`assets/mock/checkout_help_scenarios.json`. The file is located under assets so
Issue 3 can register it in `pubspec.yaml` and load it for the prepared frontend
demonstration. **It is not registered or loaded by the app in Issue 1.** These
evidence records are not direct replacements for `AppState` basket or balance
maps; later integration must map the selected mock item deliberately and must
not overwrite real user data or treat an arbitrary item as one of these cases.

The mock records do not have the trial-outcome fields used by M0's scoring
script. Do not pass this file to `evaluate_checkout_trials.py`; that script
continues to use its separate trial records.

## Scope and Later Work

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
