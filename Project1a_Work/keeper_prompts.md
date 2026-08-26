# Keeper prompts for cross-model comparison

Run every prompt below unchanged from the repository root in Codex Sol,
GPT-5.6-terra, and Gemini. Tell each tool it may inspect the whole repository
but must not edit anything. Save raw output or screenshots. The local Llama
run is best-effort and had limited pasted context.

## K1 — Evidence-ranked actor goals

```text
You are a requirements engineer reverse-engineering an unfamiliar product.
Read the entire repository, but do not edit any file. Ignore existing tests
for now: this is our independent design pass.

Produce exactly 20 candidate use cases, ranked by user value. For each give:
- a verb+noun actor goal;
- primary actor;
- trigger;
- one-sentence success outcome;
- strongest source evidence as file:line;
- confidence: high, medium, or low.

Rules: distinguish implemented behavior from README claims; do not turn UI
navigation, private helpers, or database operations into user goals; do not
guess. Finish with (a) README claims unsupported by code, and (b) implemented
user-visible behavior omitted from the README.
```

Why keep it: it forces a comparable top-20 list and makes unsupported claims
easy to catch with line evidence.

## K2 — State-transition and invariant audit

```text
You are a software test architect. Inspect the production code only; do not
edit it and do not read the inherited tests yet. Trace these end-to-end flows:
1. UPC input -> product lookup -> basket -> benefit balance.
2. Basket quantity at category cap -> paid overflow -> decrement.
3. Receipt image -> OCR text -> UPC matches -> basket.
4. Basket -> QR handoff -> finish transaction.
5. Sign-in -> restore state -> new-month behavior.

Return one table with columns: flow, starting state, state transitions,
persisted fields, visible outcome, invariant that should always hold,
file:line evidence. Then list contradictions or silent-failure paths. Label
each statement EVIDENCE or INFERENCE. Do not propose repairs.
```

Why keep it: state/balance interactions are the riskiest part of this app and
will generate testable extensions, not generic error-message cases.

## K3 — Boundary and extension miner

```text
You are a hostile but fair test designer. Inspect all production code and the
required use-case format, but do not inspect the inherited tests and do not
edit anything. Find behavior-changing boundaries for authentication, UPC
lookup, nutrition badges, healthier alternatives, basket quantity, WIC caps,
receipt OCR, persistence/month rollover, and QR checkout.

Return exactly 25 boundaries. For each provide: boundary/input partition,
expected behavior supported by code, actual ambiguity or risk, candidate use
case extension, and file:line evidence. At least 15 entries must be more
specific than "API fails -> show error." Mark any expected behavior that the
code does not actually guarantee as INFERENCE.
```

Why keep it: it is designed to produce non-trivial extensions and future test
ideas, which the rubric explicitly values.

## K4 — Contradiction adjudicator

```text
Act as an evidence auditor. Read README.md, the route inventory, production
source, pubspec.yaml, CI workflow, and git history. Do not edit files and do
not inspect inherited tests yet.

Create a table: claim, source making the claim, confirming or contradicting
code evidence (file:line), verdict (implemented / partial / absent /
misleading), and whether it belongs in the top 20 use cases. Include at least
the README claims about order tracking, receipt balance updates, QR checkout,
WIC eligibility, and cross-platform behavior. End with the three mistakes an
LLM is most likely to make when deriving this product's use cases.
```

Why keep it: it directly exposes hallucinations caused by trusting prose over
code and supplies concrete cross-model disagreement material for D5.

## Reconciliation worksheet

For each prompt, record one verdict per model and the evidence that settled
disagreements. Do not write “all agreed” without checking line references.

| Prompt | Codex Sol verdict | GPT-5.6-terra verdict | Gemini verdict | Local model | Evidence that settled disagreement |
|---|---|---|---|---|---|
| K1 | pending summary | | | | |
| K2 | pending summary | | | | |
| K3 | pending summary | | | | |
| K4 | pending summary | | | | |
