# Prompt Notes — GPT-5.6-terra

Runner: Supreme Constantine using OpenAI Codex CLI  
Run date: 2026-08-25  
Repository commit: `03bc584b9a4e03aa8eca51b872435d07b4e7009f`  
Evidence: `Project1a_Work/model_outputs/codex_terra/K1_raw_output.md` through `K4_raw_output.md`

## Errors or overstatements caught

- **K1 named lookup “Look up product eligibility.”** Its stated outcome was
  more careful, but the name still implies that direct lookup enforces
  eligibility. `findByUpc` accepts any existing APL document, so the final actor
  goal is **Identify product** (`Project3/lib/services/apl_service.dart:31–35`).
- **K1 promoted “Check category capacity” to a top-level goal.** Category-cap
  status is visible and testable, but it is normally encountered while
  identifying or adding a product. The final use cases retain it as an
  extension of product addition and benefit review rather than a separate main
  actor goal.
- **K1 called the final action “Complete checkout transaction.”** The code
  clears the local basket and retains used benefits, but it does not verify that
  a cashier accepted the QR or that an external transaction completed. The
  reconciled goals are **Prepare checkout handoff** and **Finish shopping
  session** (`Project3/lib/screens/qr_checkout_screen.dart:12–45`).
- **K2’s basket/balance equality invariant was too broad.** Before checkout,
  covered basket quantities and provisional usage should agree. After checkout,
  the basket is empty while used benefits intentionally remain. The invariant
  therefore applies only to pending covered basket quantities, not the entire
  session (`Project3/lib/state/app_state.dart:556–563`).
- **K2 described mutations as persisted after each operation.** Most basket
  mutations start persistence without awaiting it. The model later caught this
  in its silent-failure list; the stronger wording in the flow table should be
  “persistence is attempted” (`Project3/lib/state/app_state.dart:400–403,
  488–490, 551–553`).
- **K1 treated quantity adjustment as one goal.** The combined label is
  defensible, but increase, shopper-paid overflow, and decrease have different
  benefit effects and test boundaries. The final list separates them to keep
  triggers and postconditions precise.
- **The run is not fully independent of the original Codex review.** Terra and
  Sol are different model variants, but both were used through Codex/OpenAI.
  This limits the diversity claim and should be stated honestly in D5.

## Which prompts earned their keep

- **K1 earned its keep** by independently reproducing nearly the entire final
  goal inventory, merging barcode/manual lookup, separating QR generation from
  finish, and identifying saved-session restoration.
- **K2 earned its keep** by providing the clearest evidence/inference labeling
  and by exposing ignored return values, unawaited persistence, inaccurate
  receipt counts, and failed-load behavior.
- **K3 earned its keep strongly.** It produced repository-specific, testable
  boundaries: malformed authentication input, ineligible APL records, exact
  nutrition thresholds, category-cap differences, duplicate receipt UPCs,
  PAID-first decrement, monthly reset, and checkout persistence failure.
- **K4 earned its keep strongly.** It directly adjudicated stale README, CI,
  dependency, receipt, eligibility, QR, and order-tracking claims with source
  evidence.

## GPT-5.6-terra strength and weakness on WolfBite

- **Strength:** Terra consistently connected user-visible behavior to specific
  production paths and distinguished evidence from inference better than the
  other comparison runs.
- **Weakness:** Its first-pass goal names still inherited domain labels such as
  “eligibility” and “transaction,” and its shared Codex/OpenAI lineage makes it
  less independent from the Sol review than Gemini or local Llama.

## Reconciliation verdicts

- **K1:** Strongest independent confirmation of the final 20 structure after
  narrowing eligibility, category-cap, and transaction wording.
- **K2:** Strong state audit; qualify persistence and basket/usage invariants.
- **K3:** Strong source of nontrivial D2 extensions and D3 test candidates.
- **K4:** Strong claim audit; its partial/absent verdicts are generally retained
  in the final reconciliation.

