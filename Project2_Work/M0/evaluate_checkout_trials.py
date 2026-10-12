#!/usr/bin/env python3
"""
Calculate whether a set of checkout-help trial results passes M0.

The easiest way to think about this file is that it is a calculator. It does
not run WolfBite, create M4, simulate a person, or decide what a person's
answer means. We first record what happened during each trial in a JSON file.
This script reads those records and calculates the final percentages.

The two files currently in ``trial_data`` contain made-up examples. They let
us prove that the calculator can produce both PASS and FAIL results before we
have M4 or real participant results. They do not prove that M4 is useful.

"""

# ``annotations`` lets us use modern, readable type hints throughout the file.
from __future__ import annotations

# These modules all come with Python; there are no packages to install.
import argparse
import json
import sys
from pathlib import Path
from typing import Any

# These are the three rules from our measurable M0 hypothesis.
TIME_LIMIT_SECONDS = 60.0
M4_SUCCESS_THRESHOLD_PERCENT = 80.0
IMPROVEMENT_THRESHOLD_POINTS = 20.0

# Every trial must say whether it used the current app (baseline) or M4.
VALID_CONDITIONS = {"baseline", "m4"}

# If one of these fields is missing, we do not have enough information to
# score that trial honestly.
REQUIRED_RECORD_FIELDS = {
    "trial_id",
    "condition",
    "scenario_id",
    "identified_expected_step",
    "elapsed_seconds",
    "used_outside_assistance",
}


class TrialDataError(ValueError):
    """A clear error for incomplete or incorrectly formatted trial data."""

def load_dataset(path: str | Path) -> dict[str, Any]:
    """Open the JSON file and make sure its overall structure is usable."""

    # ``str | Path`` above means the caller may give us normal path text or a
    # Path object. This line converts either one into a Path object.
    dataset_path = Path(path)
    try:
        # ``with`` automatically closes the file after json.load reads it.
        with dataset_path.open(encoding="utf-8") as input_file:
            dataset = json.load(input_file)
    except FileNotFoundError as error:
        raise TrialDataError(f"Dataset not found: {dataset_path}") from error
    except json.JSONDecodeError as error:
        raise TrialDataError(
            f"Invalid JSON in {dataset_path}: line {error.lineno}, "
            f"column {error.colno}"
        ) from error

    # JSON objects become Python dictionaries. ``isinstance`` checks the type.
    if not isinstance(dataset, dict):
        raise TrialDataError("The dataset must be a JSON object.")

    # ``.get`` safely looks up a dictionary value. It returns None when the key
    # is missing instead of crashing immediately.
    dataset_name = dataset.get("dataset_name")
    if not isinstance(dataset_name, str) or not dataset_name.strip():
        raise TrialDataError("The dataset must have a non-empty dataset_name.")

    if not isinstance(dataset.get("synthetic"), bool):
        raise TrialDataError("The dataset synthetic field must be true or false.")

    records = dataset.get("records")
    if not isinstance(records, list) or not records:
        raise TrialDataError("The dataset records field must be a non-empty list.")

    # Check the individual records before we try to calculate anything.
    validate_records(records)
    return dataset


def validate_records(records: list[Any]) -> None:
    """Catch bad trial data instead of silently calculating a wrong result."""

    # A set stores unique IDs. We add each ID as we read it and use the set to
    # notice when an ID appears a second time.
    seen_trial_ids: set[str] = set()

    # ``enumerate`` gives us both the list position and the record at it.
    for index, record in enumerate(records):
        location = f"records[{index}]"
        if not isinstance(record, dict):
            raise TrialDataError(f"{location} must be a JSON object.")

        # A missing field could accidentally turn a failed trial into a pass,
        # so we stop and explain what is missing.
        # Subtracting sets leaves only required fields that were not present.
        missing_fields = REQUIRED_RECORD_FIELDS - record.keys()
        if missing_fields:
            # ``sorted`` makes the order predictable; ``join`` turns the list
            # of field names into one readable comma-separated sentence.
            missing = ", ".join(sorted(missing_fields))
            raise TrialDataError(f"{location} is missing required fields: {missing}.")

        trial_id = record["trial_id"]
        if not isinstance(trial_id, str) or not trial_id.strip():
            raise TrialDataError(f"{location}.trial_id must be a non-empty string.")
        # Duplicate IDs could count the same trial twice.
        if trial_id in seen_trial_ids:
            raise TrialDataError(f"Duplicate trial_id: {trial_id}.")
        seen_trial_ids.add(trial_id)

        condition = record["condition"]
        if condition not in VALID_CONDITIONS:
            allowed = ", ".join(sorted(VALID_CONDITIONS))
            raise TrialDataError(
                f"{location}.condition must be one of: {allowed}."
            )

        scenario_id = record["scenario_id"]
        if not isinstance(scenario_id, str) or not scenario_id.strip():
            raise TrialDataError(
                f"{location}.scenario_id must be a non-empty string."
            )

        identified = record["identified_expected_step"]
        if not isinstance(identified, bool):
            raise TrialDataError(
                f"{location}.identified_expected_step must be true or false."
            )

        elapsed = record["elapsed_seconds"]
        # Python treats true/false like the numbers 1/0, so we explicitly
        # reject Boolean values here. A time must be an actual number.
        if isinstance(elapsed, bool) or not isinstance(elapsed, (int, float)):
            raise TrialDataError(f"{location}.elapsed_seconds must be a number.")
        if elapsed < 0:
            raise TrialDataError(
                f"{location}.elapsed_seconds cannot be negative."
            )

        assisted = record["used_outside_assistance"]
        if not isinstance(assisted, bool):
            raise TrialDataError(
                f"{location}.used_outside_assistance must be true or false."
            )

    # We need both groups or there is nothing meaningful to compare.
    # The braces below build a set containing each condition found in the
    # records. The short ``for`` expression is called a set comprehension.
    missing_conditions = VALID_CONDITIONS - {
        record["condition"] for record in records
    }
    if missing_conditions:
        missing = ", ".join(sorted(missing_conditions))
        raise TrialDataError(f"Dataset has no records for condition(s): {missing}.")


def trial_succeeded(record: dict[str, Any]) -> bool:
    """Decide whether one trial counts as successful.

    This is the most important rule in the file. All three parts must be true:
    the expected next step was identified, it took no more than 60 seconds,
    and nobody provided outside assistance.
    """

    # ``and`` means every condition must be true. ``not`` reverses the
    # assistance value, so used_outside_assistance must be false.
    return (
        record["identified_expected_step"]
        and record["elapsed_seconds"] <= TIME_LIMIT_SECONDS
        and not record["used_outside_assistance"]
    )


def failure_reasons(record: dict[str, Any]) -> list[str]:
    """Explain why an unsuccessful trial did not count as successful."""

    # Start with an empty list and append every reason that applies. A trial can
    # fail for more than one reason.
    reasons: list[str] = []
    if not record["identified_expected_step"]:
        reasons.append("expected next step was not identified")
    if record["elapsed_seconds"] > TIME_LIMIT_SECONDS:
        reasons.append(
            f"elapsed time was {record['elapsed_seconds']:g} seconds "
            f"(limit: {TIME_LIMIT_SECONDS:g})"
        )
    if record["used_outside_assistance"]:
        reasons.append("outside assistance was used")
    return reasons


def summarize_condition(
    records: list[dict[str, Any]], condition: str
) -> dict[str, Any]:
    """Count successes and calculate the rate for baseline or M4."""

    # This list comprehension keeps only records for the requested condition.
    condition_records = [
        record for record in records if record["condition"] == condition
    ]

    # In Python, True counts as 1 and False counts as 0. Summing the Boolean
    # results therefore counts how many trials succeeded.
    successes = sum(trial_succeeded(record) for record in condition_records)
    total = len(condition_records)
    # Example: 4 successful trials out of 5 becomes 80 percent.
    success_rate = successes / total * 100.0
    # Returning a dictionary keeps the related results together by name.
    return {
        "condition": condition,
        "successes": successes,
        "total": total,
        "success_rate": success_rate,
    }


def evaluate_records(records: list[dict[str, Any]]) -> dict[str, Any]:
    """Compare baseline with M4 and check both M0 requirements."""

    validate_records(records)
    baseline = summarize_condition(records, "baseline")
    m4 = summarize_condition(records, "m4")
    # This is a percentage-point difference, not a percent increase.
    # Example: 80% minus 60% equals a 20-percentage-point improvement.
    improvement = m4["success_rate"] - baseline["success_rate"]

    # We compare the unrounded numbers so display rounding cannot change a
    # PASS into a FAIL (or the other way around).
    meets_success_requirement = (
        m4["success_rate"] >= M4_SUCCESS_THRESHOLD_PERCENT
    )
    meets_improvement_requirement = (
        improvement >= IMPROVEMENT_THRESHOLD_POINTS
    )

    # This final result dictionary is what the report and future tests inspect.
    return {
        "baseline": baseline,
        "m4": m4,
        "improvement_percentage_points": improvement,
        "meets_success_requirement": meets_success_requirement,
        "meets_improvement_requirement": meets_improvement_requirement,
        "overall_pass": (
            meets_success_requirement and meets_improvement_requirement
        ),
    }


def _pass_fail(value: bool) -> str:
    """Turn a true/false calculation into the words shown in the report."""

    return "PASS" if value else "FAIL"


def format_report(dataset: dict[str, Any], evaluation: dict[str, Any]) -> str:
    """Create the easy-to-read report printed in the terminal."""

    baseline = evaluation["baseline"]
    m4 = evaluation["m4"]
    source = "SYNTHETIC" if dataset["synthetic"] else "NON-SYNTHETIC"

    # We build the report as a list of lines, then join them with newline
    # characters at the end. This is easier to read than one very long string.
    lines = [
        f"Dataset: {dataset['dataset_name']}",
        f"Data source: {source}",
        "",
        (
            f"Baseline: {baseline['successes']}/{baseline['total']} successful "
            f"({baseline['success_rate']:.1f}%)"
        ),
        (
            f"M4: {m4['successes']}/{m4['total']} successful "
            f"({m4['success_rate']:.1f}%)"
        ),
        (
            "Improvement: "
            f"{evaluation['improvement_percentage_points']:.1f} percentage points"
        ),
        "",
        (
            f"{M4_SUCCESS_THRESHOLD_PERCENT:g}% success requirement: "
            f"{_pass_fail(evaluation['meets_success_requirement'])}"
        ),
        (
            f"{IMPROVEMENT_THRESHOLD_POINTS:g}-percentage-point improvement "
            "requirement: "
            f"{_pass_fail(evaluation['meets_improvement_requirement'])}"
        ),
        f"Overall result: {_pass_fail(evaluation['overall_pass'])}",
    ]

    # Showing the failed trial IDs makes the final number easier to audit.
    failed_records = [
        record for record in dataset["records"] if not trial_succeeded(record)
    ]
    if failed_records:
        lines.extend(["", "Unsuccessful trials:"])
        for record in failed_records:
            reasons = "; ".join(failure_reasons(record))
            # An f-string inserts the trial ID and its reasons into this line.
            lines.append(f"- {record['trial_id']}: {reasons}")

    # Never let someone mistake our made-up examples for real user evidence.
    if dataset["synthetic"]:
        lines.extend(
            [
                "",
                "Note: These records are synthetic examples, not participant "
                "results.",
                "They do not establish actual usefulness to real users.",
            ]
        )

    # ``\n`` means start a new line in terminal text.
    return "\n".join(lines)



def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """Read the JSON filename supplied after the Python command."""

    parser = argparse.ArgumentParser(
        description="Evaluate baseline and M4 checkout-help trial records."
    )
    # This creates the required filename after the command, for example:
    # python3 evaluate_checkout_trials.py trial_data/passing_example.json
    parser.add_argument("dataset", type=Path, help="Path to a trial JSON file")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    """Load the records, calculate the result, and print the report."""

    args = parse_args(argv)
    try:
        dataset = load_dataset(args.dataset)
        evaluation = evaluate_records(dataset["records"])
    except TrialDataError as error:
        # Code 2 means the input was invalid. A correctly calculated FAIL is
        # different: that still prints a normal report and returns code 0.
        print(f"Error: {error}", file=sys.stderr)
        return 2

    print(format_report(dataset, evaluation))
    return 0


# Python sets ``__name__`` to ``__main__`` only when this file is run directly.
# Keeping this check lets our future unit tests import the functions without
# automatically running the terminal command.
if __name__ == "__main__":
    raise SystemExit(main())
