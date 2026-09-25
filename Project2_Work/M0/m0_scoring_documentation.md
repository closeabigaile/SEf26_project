# M0 Checkout-Help Scoring

## Purpose

Created `evaluate_checkout_trials.py` to calculate whether checkout-help trial results meet the M0 requirements. The script is a calculator: it reads trial records, calculates success rates, compares M4 with the baseline, and reports Pass or Fail.

The script does not run WolfBite, simulate people, or decide whether a written answer is correct. That information must already be recorded in the input data.

## Measurable Hypothesis

Compared with the current WolfBite checkout flow, M4 checkout help will enable at least 80% of evaluation trials to identify the expected next step after a rejected item within 60 seconds and without outside assistance. This success rate will be at least 20 percentage points higher than the baseline rate.

The current checkout flow is the `baseline` condition. The checkout-help flow is the `m4` condition.

## Trial Records

One record represents one attempt to identify the expected next step for one checkout-rejection scenario.

```json
{
  "trial_id": "m4-01",
  "condition": "m4",
  "scenario_id": "M0-M4-01",
  "identified_expected_step": true,
  "elapsed_seconds": 42,
  "used_outside_assistance": false
}
```

A trial succeeds only when all three rules are met:

1. The expected next step was identified.
2. The answer was identified in 60 seconds or less.
3. No outside assistance was used.

Exactly 60 seconds passes. Anything above 60 seconds fails.

## Calculations

The script calculates:

```text
success rate = successful trials / total trials x 100

improvement = M4 success rate - baseline success rate
```

The overall result passes only when:

```text
M4 success rate >= 80%
AND
improvement >= 20 percentage points
```

The script validates the data before calculating. It rejects missing fields, duplicate trial IDs, unknown conditions, negative times, invalid value types, and datasets that do not contain both baseline and M4 records.

## Synthetic Examples

The records in `trial_data` are synthetic. I created them to test the scoring instrument before M4 or participant results are available.

| Example | Baseline | M4 | Improvement | Expected result |
| --- | ---: | ---: | ---: | --- |
| `passing_example.json` | 60% | 80% | 20 points | Pass |
| `failing_example.json` | 60% | 60% | 0 points | Fail |

The failing example proves that the evaluation can report unmet requirements. These examples are not participant results and do not prove that M4 is useful.

## Running the Scorer

From `Project2_Work/M0`:

```bash
python3 evaluate_checkout_trials.py trial_data/passing_example.json
python3 evaluate_checkout_trials.py trial_data/failing_example.json
```

The first command should report an overall Pass. The second should report an overall Fail.

## Running the Automated Tests

```bash
python3 -m unittest -v test_evaluate_checkout_trials.py
```

The 13 tests check the known examples, the inclusive 60-second boundary, incorrect answers, outside assistance, percentage calculations, and invalid records.

## Continuous Integration

`.github/workflows/m0-scoring.yml` runs the same tests and both examples in GitHub Actions. A successful remote workflow run still needs to be confirmed after these files are committed and pushed.

## Limitations

Participant testing was not conducted. M4 has not been implemented, and actual usefulness to real users remains unverified. The synthetic examples only demonstrate that the scoring instrument calculates known passing and failing results correctly.
