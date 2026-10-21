# AI Usage and Human Review

This file records AI assistance used in Team 7's WolfBite work and the human
review of that assistance. Add entries as work is completed. Mark human review
as pending until a reviewer records what they checked and any corrections.

## User guide and README link review - October 19, 2026

- **Contributor:** Abigail Close.
- **AI tool:** OpenAI Codex.
- **Files:** [USER_GUIDE.md](USER_GUIDE.md), `README.md`, and this disclosure.
- **Task and assistance:** Wrote usage instructions from the current screens,
  application state, and shopping-journey tests. Explained demo allowances,
  PAID items, nutrition comparisons, checkout help, receipt OCR, and the QR
  completion behavior. Linked the guide from the README and replaced broken
  Discussions and stargazers destinations with the existing issue tracker and
  repository page. Preserved the previous-team documentation as a historical
  reference.
- **Verification scope:** Compared labels and effects with source code and
  tests. This was not an additional live walkthrough of every feature.
  Checked 73 local link occurrences across the README, guide, AI record,
  dependency inventory, and badge documentation. The README's 42 external
  URLs returned 32 HTTP 200 responses and 10 HTTP 404 responses for the
  deliberately unpublished main badge images/report. The combined main CI
  badge still reports "no status". All 13 non-SDK package versions in the
  README match the lockfile, and its license summaries match the inventory.
  Left the unconfirmed `csv-parser` declaration unchanged pending permission
  to remove it; no dependency was added or removed in this follow-up.
  Final feature results, both Project 2 videos, and teammates' AI/human-review
  entries remain their responsibility. Zenodo and hosted Dart documentation
  remain deferred until release preparation.
- **Human review:** Abigail Close

## README badges and CI evidence - October 19, 2026

- **Contributor:** Abigail Close.
- **AI tool:** OpenAI Codex.
- **Files:** `README.md`, `.github/workflows/flutter-ci.yml`, and
  [badge reporting scripts, tests, and documentation](.github/scripts/README.md).
- **Task and assistance:** Add badges backed by actual check outcomes, Flutter
  test counts, and measured Dart line coverage. AI added JSON test reporting,
  evidence generation, and a separate publisher for the `ci-evidence` branch.
  The existing build, formatter, analyzer, and application test commands remain
  checks; their failures are not suppressed by reporting. Style and syntax
  badges explicitly share the existing Dart analyzer result.
- **AI verification:** Ten Python reporting tests and five mocked publisher
  tests passed, including missing/failed evidence and stale-run cases. Parsed
  the workflow YAML and checked whitespace. Ran the updated Flutter reporting
  command locally: 377 tests passed; the generated report measured 2,388 of
  2,596 LCOV lines covered (92.0%). This is a local verification result, not a
  claim that GitHub CI has run the new workflow.
- **Publication and limits:** Only the branch-push publisher requests
  `contents: write`; it uses GitHub's built-in token and never runs for PRs.
  Publication, repository permissions, and live badge URLs still need checking
  after a push. README badge URLs target `main` and will become available after
  its first publishing run. Zenodo and Dart Docs badges remain deferred.
- **Human review:** Abigail Close

### Follow-up badge review - October 19, 2026

- **AI assistance:** Added a direct source-commit link to generated evidence
  and prevented coverage publication when a completed report contains no
  executed tests. Added a regression test for that case.
- **AI verification:** Eleven Python reporter tests, five mocked publisher
  tests, 13 M0 scoring tests, 13 APL conversion/review tests, and 16 Node
  importer tests passed (58 total). APL tests used a temporary virtual
  environment with the declared `openpyxl==3.1.5` dependency. Strict
  `flutter analyze --no-pub --fatal-infos --fatal-warnings` and the Firebase
  configuration check passed. The 377-test Flutter reporting result above
  remains the application-suite check; application code was unchanged.
- **Human review:** Pending review of these follow-up changes.

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

## M2 basket-aware suggestions and cross-milestone testing - October 12-17, 2026

- **Contributor:** Aditya Mahajan.
- **AI tool:** Claude Code (Claude Opus 5.5). Each assisted commit carries a
  `Co-Authored-By: Claude Opus 5.5` trailer.
- **Files:** `Project3/lib/services/basket_balance_service.dart`,
  `Project3/lib/widgets/basket_balance_sheet.dart`,
  `Project3/lib/state/app_state.dart`, `Project3/lib/services/apl_service.dart`,
  `Project3/lib/utils/wic_categories.dart`, nutrition scripts in
  `Project3/scripts/` (`enrich_nutrition_off.cjs`, `seed_nutrition.cjs`,
  `coverage_summary.cjs`), `Project3/firestore.rules`, tests in
  `Project3/test/e2e/` and `Project3/integration_test/`, the
  [nutrition recommendation rules](Project3/docs/nutrition_recommendation_rules.md),
  and [Testing WolfBite](Project3/docs/TESTING.md).
- **Task:** Turn the September 27 M2 prototype into an integrated feature:
  basket-level nutrition balance with shopper-confirmed swap previews, backed
  by real nutrition data, plus end-to-end tests across M0-M4.
- **AI assistance:** Assisted with implementation, tests, data scripts, and
  documentation:
  - `BasketBalanceService`: quantity-weighted sodium, added-sugar, and fiber
    averages compared with FDA label thresholds; same-category swaps ranked by
    whole-basket effect (at most three); abstains on missing data or
    inconsistent allowances. `AppState.swapItem` applies only confirmed swaps
    and keeps quantity, category, and balances.
  - Open Food Facts enrichment with consistency checks, and a dry-run-by-default,
    create-only seeding script with read-back. Nutrition collection lookups sit
    behind a revertible `config/nutrition` switch; APL values take precedence.
  - One WIC category name per APL category code so allowances and swap pools
    no longer split across spelling variants.
  - Cross-milestone end-to-end tests, eight shopper journeys over a fake
    Firestore seeded with real APL and Open Food Facts data, desktop
    integration tests, and a live-app test that reads credentials from outside
    the repository.
  - An M3 desktop fix for a Basket Summary title overflow just above the 800px
    breakpoint.
- **Corrections found during the work:**
  - An M1 regression in `AppState` loaded missing nutrition as `0.0`; it now
    stays unknown. Five Project 1a tests that encoded the old zero defaults were
    updated.
  - `healthierSubstitutes` offered products with no nutrition as "healthier"
    because they scored 0; they are now excluded.
  - After seeding 574 nutrition records, review found bad crowdsourced values:
    17 milks/yogurts with ~0.05 mg sodium, a cheese at ~8,300 mg/100 g, and a
    juice at 12.5 g/100 g. The enrichment now rejects dairy sodium unit errors
    and sodium above 2 g/100 g, while real salty products still pass.
- **AI verification:** 377 Flutter tests and 13 Node enrichment tests passed.
  Line coverage was 90.8%. Eleven of eleven shopper journeys and the M2 visual
  flow passed on a Windows desktop build. `firestore.rules` (signed-in read for
  `nutrition/` and `config/`, expired catch-all removed) passed 16 of 16 checks
  with the Firebase rules test API before it was deployed on October 17, 2026.
  `live_app_test.dart` has not been run to completion, and comparison targets are
  illustrative, not personal dietary goals.
- **Human review:** Aditya Mahajan

### M2 conclusion reports and saved outputs

| Date | Report / conclusion | Supporting output |
| --- | --- | --- |
| September 27 - October 17, 2026 | [Nutrition recommendation rules](Project3/docs/nutrition_recommendation_rules.md) and [nutrition profile review](Project3/docs/nutrition_profile_review.md) | [M2 service tests](Project3/test/services/basket_balance_service_test.dart), [M2 state tests](Project3/test/state/app_state_m2_test.dart), [scan-to-swap tests](Project3/test/e2e/m2_scan_to_swap_test.dart) |
| October 17-20, 2026 | [Testing WolfBite](Project3/docs/TESTING.md): test layers, commands, CI results, and known gaps | [Shopper journeys](Project3/test/e2e/shopping_journeys_e2e_test.dart), [cross-milestone tests](Project3/test/e2e/milestones_e2e_test.dart), [M2 visual flow](Project3/integration_test/m2_flow_visual_test.dart) |

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
