# Project 1a team workspace

This directory contains the team's Project 1a analysis and evidence for
**WolfBite**. It is separate from `Project3/` so the inherited application can
be evaluated as-is.

## Ground rules

- Do not repair, extend, reformat, or otherwise edit inherited files in
  `Project3/` for Project 1a.
- Run the keeper prompts in `keeper_prompts.md` unchanged from the repository
  root and tell each model not to edit files.
- Record the model, date, runner, repository commit, exact prompt, and complete
  raw response for every model run.
- Keep raw evidence unedited. Put summaries and interpretations in
  `prompt_notes/` or `tables/`.
- Preserve raw test output, including failures. Do not report only screenshots
  or only passing excerpts.
- Pull the latest branch before working and use a separate branch/pull request
  when possible to prevent overwrites.
- Do not commit credentials, API keys, personal data, generated build output,
  or the final video file. Store the video externally and record its link.

## Current status

- Step 1 — fork, clone, build, and run: completed.
- Step 2 — reverse-engineer 20 use cases: completed and reconciled from Codex
  Sol, Gemini, GPT-5.6-terra, limited local Llama, and production evidence.
- Steps 3–8 — test design/execution, tables, inherited-test assessment,
  cross-model reconciliation, report, and video: not completed.

## Directory map

```text
Project1a_Work/
├── README.md                  Team instructions and status
├── baseline.md                As-is build/run/test observations
├── keeper_prompts.md          Prompts shared unchanged across models
├── model_outputs/
│   ├── codex/                 Complete Codex outputs
│   ├── gemini/                Complete Gemini outputs
│   ├── codex_terra/           Complete GPT-5.6-terra outputs
│   └── local/                 Optional local-model outputs or explanation
├── prompt_notes/              Errors caught and prompt/model reflections
├── use_cases/                 Drafts, evidence map, and reconciled final 20
├── tests/                     Team-authored test plans or supporting material
├── raw_test_output/           Complete outputs from executing team tests
├── tables/                    Results, traceability, and model comparison
├── report/                    ACM LaTeX source and working report artifacts
├── documents/                 Updated working DOCX and exported report PDFs
└── video/                     Outline, shot list, and external video link only
```

The executable test code should normally live in the applicable test directory
under `Project3/` so it can run with `flutter test`. Such additions must be
clearly identified as the team's Project 1a tests. Production code must remain
unchanged.

## File naming

Use descriptive names such as:

```text
model_outputs/codex_terra/K1_raw_output.md
model_outputs/gemini/K2_gemini_2026-08-27_name.md
raw_test_output/test_login_invalid_email_2026-08-30.txt
```

For each model output, start with:

```text
Model:
Runner:
Date:
Repository commit:
Prompt ID:
```

## Existing Codex material

- `model_outputs/codex/codex_first_contact.md` — starter prompts 1, 4, and 5.
- `model_outputs/codex/codex_keeper_outputs.md` — Codex K1–K4 results.
- `prompt_notes/prompt_notes_codex.md` — sheet-ready Codex prompt notes.
- `use_cases/usecases_codex_draft.md` — evidence-based draft of 20 use cases;
  this is not final until the cross-model reconciliation is complete.
- `use_cases/usecases_final.md` — reconciled and production-verified final 20
  used for D2 and team test assignments.
- `prompt_notes/prompt_notes_gemini.md` and
  `prompt_notes/prompt_notes_codex_terra.md` — verified model-specific notes
  for D5.

## Before submission

- Verify all 20 final use cases use the required format and have evidence.
- Map every team test to at least one use case and explain any coverage gap.
- Include expected versus actual results and raw-output samples.
- Assess inherited tests only after the independent design/test pass.
- Record real model disagreements and how repository evidence settled them.
- Compile the report with `\documentclass[sigconf]{acmart}`.
- Confirm the 2–5 minute video link works and shows real test runs.
