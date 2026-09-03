# Project 1b team workspace

This directory contains the team's requirements-development evidence for
Project 1b. Keep raw model output separate from the team's verified findings
and from the final ACM report.

## Directory map

```text
Project1b_Work/
├── inputs/                 Shared facts pasted into prompts
├── prompts/                Exact prompts run across models
├── model_outputs/          Complete, unedited output grouped by model
├── rivals/                 One rival worksheet per model plus final validation
├── evidence/               Source notes and transcript screenshots
├── analysis/               Cross-model comparison, errors, and design decisions
├── report/                 ACM LaTeX report for Overleaf
└── poster/                 Poster source/assets and export notes
```

## Evidence rules

- Record the model, runner, date, repository commit, prompt ID, exact prompt,
  and complete response for every run.
- Do not silently edit raw model output. Put corrections in `analysis/`.
- In every prompt, state that four students have one month to build **and
  test** the proposed product.
- Run Prompt 1 (market survey) and Prompt 10 (red team) on every model.
- A rival survives only if two models name it or one model supplies a live,
  relevant URL. The team must still verify the product and claims.
- Store working material as Markdown. Write the submitted report in LaTeX.
- Do not commit credentials, private data, build output, or unnecessarily
  large screenshots.

## Suggested raw-output filename

```text
P01_market_survey_2026-09-03.md
```

The final report must use `\documentclass[sigconf]{acmart}`, exceed four
pages, and agree with the separately submitted poster.
