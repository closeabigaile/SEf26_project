# AI Usage and Human Review

This file records AI assistance used in Team 7's WolfBite work and the human
review of that assistance. Add entries as work is completed. Mark human review
as pending until a reviewer records what they checked and any corrections.

## Dependency and license inventory - October 10, 2026

- **AI tool:** OpenAI Codex.
- **Files:** THIRD_PARTY_LIBRARIES.md and the README dependency link.
- **Task:** Document only dependencies supported by repository evidence,
  verify their licenses, and link the inventory from the README.
- **AI assistance:** Drafted the inventory using dependency declarations,
  the Dart lockfile, installed license files, and upstream metadata.
- **AI verification:** Compared all 115 Dart/Flutter entries with the
  lockfile and checked relative links and Markdown rendering.
- **Human reviewer:** Abigail Close

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

