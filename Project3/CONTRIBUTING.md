# Contributing to WolfBite

## 1. Overview

Team 7 is extending WolfBite for CSC 510 Project 2 at NC State University,
building on previous teams' Flutter/Firebase application. The application
remains in the `Project3` folder; that folder name is inherited.

Discuss bugs and proposed changes in
[GitHub Issues](https://github.com/closeabigaile/SEf26_project/issues).
Include steps to reproduce a bug, expected and actual behavior, and relevant
device or browser details. Coordinate changes to shared files with teammates.

## 2. Code of Conduct

Follow our [Code of Conduct](CODE_OF_CONDUCT.md). It covers respectful
collaboration and private reporting of conduct concerns. Use its reporting
instructions for personal conduct matters, rather than public GitHub Issues.

## 3. Project Setup

Use Flutter **3.47.2**, matching the current CI configuration. Dart is included
with Flutter. Install Git and Chrome for the web development steps below.
See the [README prerequisites](../README.md#-quick-start) for installation links.

If you have repository write access, clone the team repository:

```bash
git clone https://github.com/closeabigaile/SEf26_project.git
cd SEf26_project/Project3
flutter pub get
```

If you do not have write access, fork the repository on GitHub and clone your
fork instead. Its application folder is also `Project3`.

Firebase client configuration is included. Read [Firebase Setup](FIREBASE_SETUP.md)
before changing it. Authentication and catalog access require an internet
connection. Do not commit passwords, administrative credentials, or login tokens.

From `Project3`, launch the web application:

```bash
flutter run -d chrome
```

Native platform setup and device behavior require separate verification.
Python and Node.js are used by supporting tools and tests.

## 4. Branching and Workflow

Use a descriptive branch name agreed with your teammates. A `feature/` prefix
is not required. Replace `your-branch-name` with your chosen name.

Before starting new work, commit or safely preserve existing changes. From the
repository root, start a branch from an up-to-date `main`:

```bash
git checkout main
git pull --ff-only
git checkout -b your-branch-name
```

Make focused changes, run the relevant checks below, and review your changes
before committing. From the repository root:

```bash
git status
git diff
git add path/to/changed-file
git diff --cached
git commit -m "Describe the change"
git push -u origin your-branch-name
```

Replace `path/to/changed-file` with an actual file path; repeat the staging
command for each file you intend to include. Then open a pull request targeting
the team repository's `main` branch.

## 5. Commit Messages

Use short, descriptive messages. Prefixes such as `feat`, `fix`, `docs`,
`refactor`, `test`, and `chore` can help explain the type of change:

```text
feat(basket): add a product-swap preview
fix(scan): handle a missing product record
docs(contributing): update Team 7 setup instructions
```

## 6. Pull Request Process

1. Explain the problem, your changes, and any related issue or milestone.
2. List the checks you ran and their results, including failures or checks not run.
3. Include screenshots for interface changes and note any remaining demo limitations.
4. Disclose AI assistance and human review as described below.
5. Request review from another contributor and address their feedback.
6. Merge after review approval and passing CI checks. Investigate failures instead
   of disabling checks or removing tests to obtain a passing result.

These are contribution expectations, not a claim that GitHub branch protection
has been configured to enforce them.

## 7. Coding Standards and Extending the Application

- Follow [analysis_options.yaml](analysis_options.yaml) and the surrounding code style.
  Use `lower_snake_case` for Dart files, `UpperCamelCase` for classes, and
  `lowerCamelCase` for methods and variables.
- Keep UI code in `lib/screens` or `lib/widgets`, business rules in `lib/services`,
  and shared basket/allowance state in `lib/state/app_state.dart`.
- When changing basket behavior, check quantities, allowance updates, saving,
  and reloading together. Preserve compatibility with existing saved records.
- Treat missing product or nutrition information as unknown. Do not invent values
  or turn missing data into favorable nutrition claims.
- Keep synthetic scenarios and demo allowances clearly labeled. Catalog lookup
  and checkout guidance must not imply official benefit balances or guaranteed
  retailer acceptance.
- Add or update tests for changed behavior, including failure and missing-data cases.
  Use fakes or fixtures for automated tests rather than writing to the shared database.
- Review the [APL conversion guide](scripts/APL_CONVERSION.md) and
  [import instructions](FIREBASE_UPLOAD.md) before changing catalog tools.
- Keep changes focused. Explain non-obvious decisions in comments and preserve
  existing attribution and license notices.

## 8. Testing and Checks

Run these commands from `Project3` after `flutter pub get`:

```bash
# Check formatting without changing files
dart format --output=none --set-exit-if-changed lib test tool

# Check Dart lint and static-analysis issues
flutter analyze --no-pub --fatal-infos --fatal-warnings

# Run the full Flutter suite and generate coverage
flutter test --coverage --concurrency=1

# Check that the web application builds
flutter build web --release --no-pub
```

To fix formatting, run `dart format` on the files you changed and review the diff.
Coverage is written to `coverage/lcov.info`; passing tests is not a coverage percentage.
For documentation-only changes, verify links, commands, and Markdown formatting.

The [Flutter CI workflow](../.github/workflows/flutter-ci.yml) also defines Python
and JavaScript checks. Use Python **3.12** and Node.js **22** to match CI.
For Python setup, use the local environment instructions in the
[APL conversion guide](scripts/APL_CONVERSION.md). With that environment active,
run the following from `Project3` when changing the corresponding tools.
If using the guide's macOS/Linux environment without activating it, replace
`python` below with `scripts/.venv-apl/bin/python`.

```bash
# Install the Python tooling dependency
python -m pip install -r scripts/requirements-apl.txt

# Test M0 scoring and APL processing
python -m unittest discover -s ../Project2_Work/M0 -p "test_*.py" -v
python -m unittest discover -s scripts -p "test_*.py" -v

# Check local Firebase configuration consistency
python scripts/verify_firebase_config.py

# Test the APL importer with simulated data
node --test scripts/test_import.cjs
```

The Firebase configuration check does not verify live access. Selected M0/M4
checks do not replace the full Flutter suite. Manually check affected user flows
and report which platforms were actually tested.

## 9. Documentation

Update the [README](../README.md) and relevant feature/setup documentation when
behavior, dependencies, or instructions change. Keep implemented features,
planned work, and demo behavior distinct. Update this guide if the team's
workflow changes.

## 10. AI Assistance and Human Review

When AI tools assist with a contribution, record the tool, what it helped with,
and a concise prompt or plan summary in the pull request or a linked repository
document. Do not include credentials or private conversations.

Record who reviewed the output, which code or claims they checked, the commands
and results used for verification, and any corrections or remaining limitations.
AI-generated tests or a passing CI run alone do not establish human review.
Contributors remain responsible for the changes they submit.
