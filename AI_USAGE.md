# AI Usage and Human Review

This file records AI assistance used in Team 7's WolfBite work and the human
review of that assistance. Add entries as work is completed. Mark human review
as pending until a reviewer records what they checked and any corrections.

## Fresh-clone installation evidence - October 19, 2026

- **Contributor:** Abigail Close.
- **AI tool:** OpenAI Codex.
- **Files:** [INSTALL.md](INSTALL.md) and the
  [installation record and logs](Project2_Work/installation/2026-10-19/README.md).
- **Task and assistance:** Verify installation from a fresh GitHub clone at
  commit `3f1379ec15be9b7b093e5a291c6e05a9c50bf603`; record the environment,
  commands, observed results, and limits of the check.
- **AI verification:** Checked Flutter/Chrome availability, installed dependencies
  without changing the lockfile, ran 377 passing Flutter tests, built the release
  web app, and launched the fresh checkout in Chrome. Saved command output,
  checked local evidence links, and verified documentation whitespace.
- **Limitations:** The machine already had an SDK and package cache. This is not
  the final submission commit; native platforms were not tested. The specific
  product/UPC used in the live check was not recorded.
- **Human verification:** Abigail Close completed the requested live sign-in,
  product-lookup, and add-to-basket check and reported that everything looked
  good. No errors or corrections were reported. This records her live check,
  not a claim that she independently reviewed every saved automated log.

## Dart API documentation - October 19, 2026

- **Contributor:** Abigail Close.
- **AI tool:** OpenAI Codex.
- **Files:** Documentation comments in `Project3/lib`,
  `Project3/scripts/nutrition_cli.dart`, `Project3/scripts/verify_nutrition.dart`,
  `Project3/tool/m4_scenario_walkthrough.dart`, and this disclosure.
- **Task:** Use AI to help document what WolfBite's classes, functions, and
  components do so another team can understand and maintain the project.
- **AI assistance:** Inspected the implementation, added Dart documentation
  comments for public APIs, and corrected outdated descriptions. Documented
  inputs, outputs, side effects, data units, fallback behavior, and limitations
  where relevant, including the distinction between the offline nutrition
  prototype and the application's basket-balance service.
- **AI verification:** Compared executable Dart tokens before and after the
  edits across all 27 changed Dart files; only comments and whitespace changed.
  The formatting check passed. Generated documentation for 27 public libraries
  with `dart doc --validate-links`, with zero warnings and zero errors, and
  inspected rendered API pages locally. Application tests were not rerun because
  executable code was unchanged. Generated HTML was kept outside the repository;
  this update does not publish the documentation site.
- **Human review:** Abigail Close

## Dependency and license inventory - October 10-19, 2026

- **AI tool:** OpenAI Codex.
- **Files:** [THIRD_PARTY_LIBRARIES.md](THIRD_PARTY_LIBRARIES.md) and this disclosure.
- **Task:** Add only dependencies supported by repository evidence, preserve
  existing entries, and update counts and wording as needed.
- **AI assistance:** Added seven Dart/Flutter packages confirmed in the lockfile
  and `firebase-admin`, imported by `Project3/scripts/seed_m2.js`. Reclassified two
  existing packages as direct development dependencies and verified the added
  license summaries using SDK/cache license files and published package sources.
  Left `csv-parser` out because no usage was found in tracked code.
- **AI verification:** Checked all 122 Dart/Flutter entries against the lockfile
  for versions and categories; confirmed every existing dependency row was
  preserved, local links resolved, and `git diff --check` passed. Application
  tests were not rerun for this documentation-only update.
- **Human review:** Abigail Close

## M0 checkout-help baseline and evaluation - September 19-29, 2026

- **AI tool:** OpenAI Codex.
- **Files:** M0 findings, shared M0/M4 use cases, baseline and evaluation
  reports, scoring script/tests, and supporting M0 workflows.
- **Task:** Examine existing checkout behavior, define shared rejection
  scenarios, establish an automated baseline, and evaluate the scoring rules
  without presenting synthetic results as participant outcomes.
- **AI assistance:** Assisted with analysis, scenario documentation, scoring
  code and tests, verification, and conclusion reports. This is a retrospective
  summary of the disclosed assistance, not a verbatim prompt transcript or a
  claim that every line in these files was AI-generated.
- **Conclusion:** The automated baseline and scoring instrument were verified;
  participant testing was not conducted. The 60 second, 80% success, and
  20-percentage-point improvement targets remain unverified for real users.
- **Human reviewer:** Abigail Close

### M0 conclusion reports and saved outputs

| Date | Report / conclusion | Supporting output |
| --- | --- | --- |
| September 19–20, 2026 (commit dates) | [Checkout-help findings](Project2_Work/M0/m0_checkout_help_findings.md) and [accepted shared use cases](Project2_Work/M0/m4_checkout_help_use_cases.md) | Scenario definitions and expected next steps are recorded in those documents. |
| September 21, 2026 | [Baseline checkout results](Project2_Work/M0/m0_baseline_checkout_results.md): 50 selected tests passed | [Team tests](Project2_Work/M0/test_results/baseline_team_2026-09-21.txt), [allowance tests](Project2_Work/M0/test_results/baseline_allowance_2026-09-21.txt), [inherited tests](Project2_Work/M0/test_results/baseline_inherited_2026-09-21.txt) |
| September 29, 2026 | [Evaluation results and limitations](Project2_Work/M0/m0_evaluation_results.md) and [scoring documentation](Project2_Work/M0/m0_scoring_documentation.md) | [13 scorer tests](Project2_Work/M4/test_results/issue5_2026-09-29/m0_scoring.txt), [passing example](Project2_Work/M4/test_results/issue5_2026-09-29/scoring_passing_example.txt), [intentionally failing example](Project2_Work/M4/test_results/issue5_2026-09-29/scoring_failing_example.txt) |

## M4 item-level checkout help - September 26–29, 2026

- **AI tool:** OpenAI Codex.
- **Files:** M4 mock scenarios, checkout-help service/repository and interface,
  feature and regression tests, verification workflow, and M4 reports.
- **Task:** Implement and check item-level checkout guidance for the agreed
  synthetic scenarios, including uncertainty/fallback behavior, while preserving
  basket contents and benefit state.
- **AI assistance:** Assisted with implementation, test development, review of
  edge cases, corrections, interface integration, and verification reports.
- **Conclusion and corrections:** The review identified missing basket
  integration and numeric/evidence-validation weaknesses. Follow-up reports
  document fixes and passing M4 acceptance checks for the synthetic scenarios.
  Real-world checkout guidance still requires verified benefit and checkout
  evidence. Participant effectiveness remains unverified!
- **Human reviewer:** Abigail Close

### M4 conclusion reports and saved outputs

| Date | Report / conclusion | Supporting output |
| --- | --- | --- |
| September 27, 2026 | [Historical service results](Project2_Work/M4/issue4_service_results_2026-09-27.md) and [checkout-help review findings](Project2_Work/M4/checkout_help_test_review.md) | [Service tests](Project2_Work/M4/test_results/service_final_2026-09-27.txt), [adversarial review tests](Project2_Work/M4/test_results/review_2026-09-27/adversarial_tests.txt) |
| September 27, 2026 | [Implementation corrections and validation](Project2_Work/M4/implementation_results.md) and [frontend/demo guide](Project2_Work/M4/issue3_frontend.md) | [M4 implementation tests](Project2_Work/M4/test_results/implementation_2026-09-27/m4_final.txt), [full-application results with four failures](Project2_Work/M4/test_results/issue3_2026-09-27/full_suite_final.txt) |
| September 29, 2026 | [Issue 4 test conclusions](Project2_Work/M4/issue4_test_results.md) and [Issue 5 integration/CI conclusions](Project2_Work/M4/issue5_verification_results.md) | [Unit tests](Project2_Work/M4/test_results/issue5_2026-09-29/m4_unit.txt), [widget/state tests](Project2_Work/M4/test_results/issue5_2026-09-29/m4_widget.txt), [walkthrough](Project2_Work/M4/test_results/issue5_2026-09-29/walkthrough.txt), [saved CI job results](Project2_Work/M4/test_results/issue5_2026-09-29/github_jobs.json) |
