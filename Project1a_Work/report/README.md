# Final report workflow

The Moodle submission is one PDF, but the PDF must be generated from LaTeX
using the ACM two-column format. `main.tex` starts with the required
`\documentclass[sigconf]{acmart}` declaration and provides an outline for D1–D5.

## Using Overleaf

1. Create a blank Overleaf project.
2. Upload `main.tex` and the contents of `figures/` if needed.
3. Keep the compiler set to pdfLaTeX unless a package requires otherwise.
4. Replace every placeholder only with finalized, verified team content.
5. Recompile frequently and resolve warnings that affect readability.
6. Download the compiled PDF and verify every repository/video link before
   submitting it to Moodle.

The Google Doc remains the collaborative drafting workspace. Transfer its
finalized material into the corresponding section of `main.tex`; do not paste
chat logs, entire model transcripts, or complete raw test logs into the report.
Those remain repository evidence. The report should summarize them, include
representative samples, and link to the full evidence.

## Google Doc to report map

| Google Doc material | LaTeX destination |
|---|---|
| Product name, URL, selection rationale | `Product Choice (D1)` |
| Reconciled 20 use cases | `Reverse-Engineered Use Cases (D2)` |
| Executed tests and expected/actual results | `Designed Tests and Results (D3)` |
| Test/use-case mapping and inherited-test judgment | `Traceability and Inherited Tests (D4)` |
| Errors caught, prompt verdicts, model comparison | `Cross-Model Comparison and Prompt Notes (D5)` |
| Shareable video URL | `Demo Video` |

Do not transfer the current Codex-only use-case draft as if it were final. It
must first be reconciled with Claude, Gemini, and repository evidence.

