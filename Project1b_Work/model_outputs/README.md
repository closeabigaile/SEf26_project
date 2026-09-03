# Raw model outputs

Use one subdirectory per independent analyst:

- `codex/` -- Abigail
- `chatgpt_terra/` -- Supreme
- `gemini/` -- Aditya
- `local_ollama/` -- Satwi (best effort)

Each output file must include the run metadata, exact prompt, and complete raw
response. Do not put fact-check corrections in these files; record them in
`../analysis/model_error_log.md` and link back to the raw output.
