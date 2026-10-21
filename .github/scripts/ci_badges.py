"""Generate CI badges from step outcomes, Dart JSON events, and LCOV evidence.

Uses only Python's standard library. Missing/incomplete evidence never passes.
"""

import argparse
from datetime import datetime, timezone
from html import escape
import json
import os
from pathlib import Path
import shutil


COLORS = {"success": "#4c1", "failure": "#e05d44", "cancelled": "#9f9f9f"}


def test_counts(path):
    """Count visible completed tests, including errors reported after completion."""
    completed, errors, started = {}, set(), set()
    finished = None
    for line in path.read_text().splitlines():
        event = json.loads(line)
        kind = event.get("type")
        if kind == "testStart":
            started.add(event["test"]["id"])
        elif kind == "testDone":
            completed[event["testID"]] = event
        elif kind == "error":
            errors.add(event["testID"])
        elif kind == "done":
            finished = event.get("success")
    counts = {"passed": 0, "failed": 0, "skipped": 0}
    for test_id, result in completed.items():
        if test_id in errors:
            counts["failed"] += 1
        elif result.get("hidden"):
            continue
        elif result.get("skipped"):
            counts["skipped"] += 1
        elif result.get("result") == "success":
            counts["passed"] += 1
        else:
            counts["failed"] += 1
    counts["failed"] += len(errors - completed.keys())
    counts["complete"] = finished is not None and not (started - completed.keys())
    counts["success"] = finished is True and counts["failed"] == 0
    return counts


def line_coverage(path):
    """Count unique source lines represented by LCOV DA records, without exclusions."""
    lines, source = {}, None
    for record in path.read_text().splitlines():
        if record.startswith("SF:"):
            source = record[3:]
        elif record == "end_of_record":
            source = None
        elif record.startswith("DA:"):
            if not source:
                raise ValueError("LCOV line has no source file")
            line, hits, *_ = record[3:].split(",")
            line, hits = int(line), int(hits)
            if line <= 0 or hits < 0:
                raise ValueError("Invalid LCOV line or hit count")
            key = (source, line)
            lines[key] = lines.get(key, False) or hits > 0
    if not lines:
        raise ValueError("No executable lines in coverage report")
    return sum(lines.values()), len(lines)


def svg(label, message, color):
    left, right = len(label) * 7 + 16, len(message) * 7 + 16
    title = escape(f"{label}: {message}")
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{left + right}" height="20" '
        f'role="img" aria-label="{title}"><title>{title}</title>'
        f'<rect width="{left}" height="20" fill="#555"/>'
        f'<rect x="{left}" width="{right}" height="20" fill="{color}"/>'
        '<g fill="#fff" text-anchor="middle" font-family="Verdana, sans-serif" font-size="11">'
        f'<text x="{left / 2}" y="14">{escape(label)}</text>'
        f'<text x="{left + right / 2}" y="14">{escape(message)}</text></g></svg>\n'
    )


def generate(input_dir, output_dir, env):
    output_dir.mkdir(parents=True, exist_ok=True)
    reports = input_dir / "build/test-results"
    available = env.get("REPORTS_AVAILABLE") == "true"
    steps = json.loads((reports / "steps.json").read_text()) if available and (reports / "steps.json").exists() else {}
    jobs = json.loads(env.get("CI_JOBS", "{}"))
    badges = {}

    def status(key, label, outcome):
        outcome = outcome or "skipped"
        badges[key] = (label, outcome, COLORS.get(outcome, "#9f9f9f"))

    for key, label, step in [
        ("build", "Web build", "build"),
        ("style", "Style (analysis)", "analysis"),
        ("formatter", "Dart format", "format"),
        ("syntax", "Syntax (analysis)", "analysis"),
    ]:
        status(key, label, steps.get(step, {}).get("outcome"))
    for key, label, job in [("python", "Python checks", "python-tests"), ("javascript", "JS tests", "javascript-tests")]:
        status(key, label, jobs.get(job, {}).get("result"))
    status("firebase", "Firebase config", jobs.get("python-tests", {}).get("outputs", {}).get("firebase"))
    test_outcome = steps.get("tests", {}).get("outcome", "skipped")
    counts = None
    notes = []
    try:
        if not available:
            raise ValueError("Flutter reports were not downloaded")
        counts = test_counts(reports / "flutter-tests.jsonl")
        passed, failed, skipped = (counts[k] for k in ("passed", "failed", "skipped"))
        total = passed + failed
        complete = counts["complete"] and test_outcome in ("success", "failure")
        good = complete and counts["success"] and test_outcome == "success" and total > 0
        message = f"{passed}/{total} passing"
        if skipped:
            message += f", {skipped} skipped"
        if not complete:
            message += " (incomplete)"
        elif test_outcome != "success" or not counts["success"]:
            message += " (failed)"
        elif total == 0:
            message += " (no executed tests)"
        badges["tests"] = ("Flutter tests", message, "#4c1" if good else "#e05d44")
    except (OSError, ValueError, KeyError, TypeError) as error:
        badges["tests"] = ("Flutter tests", "unavailable" if test_outcome != "skipped" else "skipped", "#9f9f9f")
        notes.append(f"Test report: {error}")
    coverage = None
    try:
        if not available or test_outcome != "success" or not counts or not counts["complete"] or not counts["success"] or counts["passed"] == 0:
            raise ValueError("Requires a complete, successful Flutter test run with at least one passing test")
        covered, total = line_coverage(input_dir / "coverage/lcov.info")
        coverage = {"covered": covered, "total": total, "percent": round(100 * covered / total, 1)}
        badges["coverage"] = ("Dart line coverage", f'{coverage["percent"]:.1f}%', "#007ec6")
    except (OSError, ValueError, TypeError) as error:
        badges["coverage"] = ("Dart line coverage", "unavailable", "#9f9f9f")
        notes.append(f"Coverage report: {error}")
    metadata = {
        "commit": env["GITHUB_SHA"], "branch": env["GITHUB_REF_NAME"],
        "run": f'{env["GITHUB_SERVER_URL"]}/{env["GITHUB_REPOSITORY"]}/actions/runs/{env["GITHUB_RUN_ID"]}',
        "run_id": int(env["GITHUB_RUN_ID"]), "attempt": int(env.get("GITHUB_RUN_ATTEMPT", "1")),
        "generated": datetime.now(timezone.utc).isoformat(),
        "tests": counts, "coverage": coverage, "notes": notes,
        "badges": {key: value[1] for key, value in badges.items()},
    }
    for key, (label, message, color) in badges.items():
        (output_dir / f"{key}.svg").write_text(svg(label, message, color))
    # Retain the measured input, not just a status assertion. No app credentials.
    for origin, target in [(reports / "flutter-tests.jsonl", "flutter-tests.jsonl"),
                           (reports / "flutter-tests.txt", "flutter-tests.txt"),
                           (reports / "steps.json", "steps.json"),
                           (input_dir / "coverage/lcov.info", "lcov.info")]:
        if available and origin.exists():
            shutil.copyfile(origin, output_dir / target)
    (output_dir / "summary.json").write_text(json.dumps(metadata, indent=2) + "\n")
    commit_url = f'{env["GITHUB_SERVER_URL"]}/{env["GITHUB_REPOSITORY"]}/commit/{metadata["commit"]}'
    body = ["# WolfBite CI evidence", "", f'Branch: `{metadata["branch"]}`  ',
            f'Commit: [`{metadata["commit"]}`]({commit_url})  ', f'[GitHub Actions run]({metadata["run"]})  ',
            f'Generated: {metadata["generated"]}', "", "| Check | Result |", "| --- | --- |"]
    body += [f"| {label} | {message} |" for label, message, _ in badges.values()]
    body += ["", "Style and syntax badges both report the same strict `flutter analyze` run,",
             "configured by `Project2/analysis_options.yaml`. They are not independent checks.",
             "Python checks include M0/APL tests, badge-report tests, and Firebase configuration validation.",
             "The Firebase badge reports local configuration consistency, not live database access.",
             "", "The test count covers visible Flutter tests; hidden successful loading/setup events",
             "are excluded, skipped tests are listed separately, and late errors count as failures.",
             "Coverage is the proportion of unique DA source lines hit in Flutter's LCOV file,",
             "with no extra exclusions. It does not measure Python, JavaScript, or every repository line.",
             "A failed/incomplete test run does not publish a passing coverage percentage.", ""]
    if coverage:
        body += [f'Covered lines: **{coverage["covered"]}/{coverage["total"]}**.', ""]
    body += [f"- [{name}]({name})" for name in ["summary.json", "steps.json", "flutter-tests.jsonl", "flutter-tests.txt", "lcov.info"] if (output_dir / name).exists()]
    body += ["", *notes, "", "Reports update after completed branch-push runs; reruns and source commit are",
             "recorded above. A cancelled run or failed publisher can leave the previous report",
             "visible. Check the linked run and commit before citing a result."]
    (output_dir / "README.md").write_text("\n".join(body) + "\n")
    return metadata


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(generate(args.input, args.output, os.environ), indent=2))
