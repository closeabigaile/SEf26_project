"""Automated checks for the M0 checkout-trial calculator.

These tests do not evaluate real users or M4. They give the calculator inputs
where we already know the correct answer, then make sure Python calculates that
answer. If someone accidentally changes the scoring rules later, these tests
should catch it.

Run this file from the M0 directory with:

    python3 -m unittest -v test_evaluate_checkout_trials.py
"""

from __future__ import annotations

import unittest
from pathlib import Path

from evaluate_checkout_trials import (
    TrialDataError,
    evaluate_records,
    failure_reasons,
    load_dataset,
    trial_succeeded,
    validate_records,
)


# ``__file__`` is this test file. Its parent is the M0 directory, so these
# paths work no matter which directory we use to start the test command.
M0_DIRECTORY = Path(__file__).resolve().parent
PASSING_DATASET = M0_DIRECTORY / "trial_data" / "passing_example.json"
FAILING_DATASET = M0_DIRECTORY / "trial_data" / "failing_example.json"


def make_record(
    *,
    trial_id: str = "example-trial",
    condition: str = "baseline",
    identified: bool = True,
    elapsed_seconds: float = 30.0,
    assisted: bool = False,
) -> dict[str, object]:
    """Create one small record so each test only changes what it cares about."""

    return {
        "trial_id": trial_id,
        "condition": condition,
        "scenario_id": "M0-M4-01",
        "identified_expected_step": identified,
        "elapsed_seconds": elapsed_seconds,
        "used_outside_assistance": assisted,
    }


class KnownDatasetTests(unittest.TestCase):
    """Prove that our two synthetic examples produce their known results."""

    def test_passing_dataset_meets_both_requirements(self) -> None:
        dataset = load_dataset(PASSING_DATASET)
        result = evaluate_records(dataset["records"])

        # Baseline is 3/5 (60%), M4 is 4/5 (80%), and the difference is 20
        # percentage points. Because both thresholds are met, the result passes.
        self.assertEqual(result["baseline"]["successes"], 3)
        self.assertEqual(result["baseline"]["total"], 5)
        self.assertAlmostEqual(result["baseline"]["success_rate"], 60.0)
        self.assertEqual(result["m4"]["successes"], 4)
        self.assertEqual(result["m4"]["total"], 5)
        self.assertAlmostEqual(result["m4"]["success_rate"], 80.0)
        self.assertAlmostEqual(result["improvement_percentage_points"], 20.0)
        self.assertTrue(result["meets_success_requirement"])
        self.assertTrue(result["meets_improvement_requirement"])
        self.assertTrue(result["overall_pass"])

    def test_failing_dataset_misses_both_requirements(self) -> None:
        dataset = load_dataset(FAILING_DATASET)
        result = evaluate_records(dataset["records"])

        # Both conditions are 3/5 (60%), so M4 is below 80% and improves by
        # zero percentage points. The calculator must be able to report FAIL.
        self.assertAlmostEqual(result["baseline"]["success_rate"], 60.0)
        self.assertAlmostEqual(result["m4"]["success_rate"], 60.0)
        self.assertAlmostEqual(result["improvement_percentage_points"], 0.0)
        self.assertFalse(result["meets_success_requirement"])
        self.assertFalse(result["meets_improvement_requirement"])
        self.assertFalse(result["overall_pass"])


class TrialRuleTests(unittest.TestCase):
    """Check each part of the rule used to score one trial."""

    def test_exactly_sixty_seconds_succeeds(self) -> None:
        record = make_record(elapsed_seconds=60.0)
        self.assertTrue(trial_succeeded(record))

    def test_more_than_sixty_seconds_fails(self) -> None:
        record = make_record(elapsed_seconds=60.01)
        self.assertFalse(trial_succeeded(record))
        self.assertIn("elapsed time", failure_reasons(record)[0])

    def test_unidentified_expected_step_fails_even_when_fast(self) -> None:
        record = make_record(identified=False, elapsed_seconds=10.0)
        self.assertFalse(trial_succeeded(record))
        self.assertIn("not identified", failure_reasons(record)[0])

    def test_outside_assistance_fails_even_when_correct_and_fast(self) -> None:
        record = make_record(assisted=True, elapsed_seconds=10.0)
        self.assertFalse(trial_succeeded(record))
        self.assertIn("outside assistance", failure_reasons(record)[0])

    def test_record_can_have_more_than_one_failure_reason(self) -> None:
        record = make_record(
            identified=False,
            elapsed_seconds=70.0,
            assisted=True,
        )
        reasons = failure_reasons(record)
        self.assertEqual(len(reasons), 3)


class ValidationTests(unittest.TestCase):
    """Make sure incomplete or misleading records are rejected clearly."""

    def test_missing_required_field_is_rejected(self) -> None:
        baseline = make_record()
        del baseline["elapsed_seconds"]
        m4 = make_record(trial_id="m4", condition="m4")

        with self.assertRaisesRegex(TrialDataError, "elapsed_seconds"):
            validate_records([baseline, m4])

    def test_duplicate_trial_id_is_rejected(self) -> None:
        baseline = make_record(trial_id="duplicate")
        m4 = make_record(trial_id="duplicate", condition="m4")

        with self.assertRaisesRegex(TrialDataError, "Duplicate trial_id"):
            validate_records([baseline, m4])

    def test_unknown_condition_is_rejected(self) -> None:
        baseline = make_record()
        unknown = make_record(trial_id="unknown", condition="future-version")

        with self.assertRaisesRegex(TrialDataError, "condition must be one of"):
            validate_records([baseline, unknown])

    def test_negative_elapsed_time_is_rejected(self) -> None:
        baseline = make_record(elapsed_seconds=-1.0)
        m4 = make_record(trial_id="m4", condition="m4")

        with self.assertRaisesRegex(TrialDataError, "cannot be negative"):
            validate_records([baseline, m4])

    def test_boolean_elapsed_time_is_rejected(self) -> None:
        # Python normally treats True like the number 1. The scorer deliberately
        # rejects it because an elapsed time must be a real number.
        baseline = make_record(elapsed_seconds=True)
        m4 = make_record(trial_id="m4", condition="m4")

        with self.assertRaisesRegex(TrialDataError, "must be a number"):
            validate_records([baseline, m4])

    def test_dataset_requires_both_baseline_and_m4(self) -> None:
        baseline_only = make_record()

        with self.assertRaisesRegex(TrialDataError, "no records for condition"):
            validate_records([baseline_only])


if __name__ == "__main__":
    # This lets us run the file directly as well as through ``python -m``.
    unittest.main()
