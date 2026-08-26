Prompt Notes — Local model (Llama 3 8B, Ollama)

Errors caught, per prompt:
- K1: Fabricated file:line evidence (e.g., "app_state.dart:24", ":35", ":44") — these do not correspond to real line numbers since raw pasted text had none. Also violated the explicit rule against turning private helpers/persistence into user goals (items 10-20: "Notify listeners of changes," "Persist basket data," "Initialize the basket").
- K2: Invented an invariant ("basket always up-to-date") that is not actually guaranteed by the code — Codex's K2 pass found the opposite (persistence is fire-and-forget and can silently fail). Marked "N/A (no code provided)" for flow 3 (receipt/OCR) and flow 5 (sign-in/restore), correctly acknowledging missing context rather than fabricating evidence — this was the most honest moment across all four runs.
- K3: Every one of the 25 boundaries lists "File:Line Evidence: N/A" — the model could not ground any boundary in real code, and instead generated plausible-sounding but generic scenarios (e.g., "Invalid QR Code," "Item Not Found in Basket") that are not tied to any actual implementation detail. This fails the prompt's explicit requirement that 15+ entries be more specific than "API fails -> show error."
- K4: Reasoned from dependency names rather than code — e.g., concluded "QR checkout: Implemented" because "QR Flutter" is listed as a dependency in the README, not because it inspected qr_checkout_screen.dart (which it never saw). This is a shallower and less reliable method than Codex's actual route-tracing.

Which prompts earned their keep:
- K1: Weak — fabricated evidence and rule violations outweigh any use.
- K2: Best of the four — the model correctly flagged when it lacked evidence instead of inventing it, though the two flows it did answer were shallow.
- K3: Weak — zero real evidence citations across all 25 entries.
- K4: Weak — reasoning from README/dependency names rather than actual code, producing confident-sounding but ungrounded verdicts.

Local model strength/weakness line:
Llama 3 8B, run locally without repository access, could follow the requested output format reasonably well but consistently substituted plausible-sounding guesses for real code evidence, fabricated line numbers, and — with only 1-2 source files as context — missed most of the real contradictions and invariants that Codex's fully repo-aware pass caught (e.g., order tracking absence, receipt-checkout mismatch, unawaited persistence failures).

Local-model result: All four keeper prompts (K1-K4) were attempted using Llama 3 8B via Ollama, with manually pasted context (README.md and app_state.dart only, since this setup cannot browse the repository autonomously). Given the fabricated evidence and shallow reasoning observed across all four, results were not incorporated into the final 20 use cases without independent verification against Codex's evidence.