# Prompt Notes — Gemini 3.1 Pro High

Runner: Antigravity  
Run date: 2026-08-25  
Repository commit: `03bc584b9a4e03aa8eca51b872435d07b4e7009f`  
Evidence: `Project1a_Work/model_outputs/gemini/K1_gemini_2026-08-25_antigravity.md` through `K4_gemini_2026-08-25_antigravity.md`

## Errors or overstatements caught

- **Direct product lookup was overstated as WIC verification.** K1 named both
  barcode and manual lookup “Check WIC eligibility,” and K4 marked real-time
  verification implemented. `AplService.findByUpc` returns any existing APL
  document without checking `eligible`, so the reconciled goal is **Identify
  product**, not guaranteed eligibility verification
  (`Project3/lib/services/apl_service.dart:31–35`).
- **Adding an alternative was called a swap.** K1 said the alternative is
  added “instead of” the original product. The code adds the chosen alternative
  but does not atomically replace or remove an original basket item
  (`Project3/lib/screens/scan_screen.dart:374–385`).
- **Account creation had the wrong success outcome.** K1 said a new shopper
  enters the app. The signup flow creates the account and profile, signs the
  shopper out, and returns to login
  (`Project3/lib/screens/signup_page.dart:52–70`).
- **Checkout was described as permanently committed.** K1 said Finish
  Transaction permanently commits a transaction. The app clears and persists
  its basket but receives no cashier acknowledgement or external transaction
  confirmation (`Project3/lib/screens/qr_checkout_screen.dart:34–45`;
  `Project3/lib/state/app_state.dart:556–563`).
- **K2 stated an inconsistent cap invariant.** Flow 1 said addition is blocked
  at a category cap, while Flow 2 correctly described PAID overflow. The
  evidence-based invariant is that covered usage stays capped; increasing an
  existing product at the cap creates shopper-paid quantity
  (`Project3/lib/state/app_state.dart:431–486`).
- **K2 overstated monthly-reset timing.** It claimed stale state is wiped before
  any UI renders. State restoration is asynchronous, so that exact display
  ordering is not guaranteed (`Project3/lib/state/app_state.dart:75–86,
  227–294`).
- **K2 incorrectly characterized the loaded flag as undefined on failure.** The
  `finally` block always marks balances loaded. The real problem is that a read
  failure can finish loading without a user-facing error
  (`Project3/lib/state/app_state.dart:290–293`).
- **Many K3 “use-case extensions” were redesign proposals.** Suggestions such
  as adding image compression, UTC rollover, transaction IDs, pagination,
  budget limits, and strict taxonomy IDs may be repairs or enhancements, but
  Project 1a requires reporting current behavior. We retained only verified
  current-system boundaries as extensions and test candidates.
- **K4 contradicted its own receipt conclusion.** Its table marked automatic
  receipt balance updating “Implemented,” while its final explanation correctly
  stated that receipt recognition only adds products to the basket and does not
  perform checkout. The correct verdict is **partial/misleading**
  (`Project3/lib/screens/receipt_scanner_screen.dart:169–181`).
- **Cross-platform behavior was overclaimed.** A wide-layout fallback and
  Flutter platform shells show structural intent, not equal runtime reliability
  across every platform.

## Which prompts earned their keep

- **K1 earned its keep** by independently corroborating most user-visible
  goals, manual UPC entry, PAID overflow, and the absence of order tracking.
  Its fixed count also exposed where the model promoted system behavior into
  actor goals.
- **K2 earned its keep** by connecting lookup, basket, balances, receipt OCR,
  checkout, and monthly restoration. Its cap contradiction produced a useful
  reconciliation issue.
- **K3 earned its keep selectively.** Its strongest findings were missing
  nutrition becoming zero, duplicate receipt UPCs, PAID-first decrement, QR
  payload size, and month rollover. Repair proposals were excluded from D2.
- **K4 earned its keep** because it caught absent order tracking and PAID
  overflow, but its receipt and eligibility verdicts required correction.

## Gemini strength and weakness on WolfBite

- **Strength:** Gemini quickly identified the major screens and user-visible
  basket, receipt, nutrition, checkout, authentication, and benefit behaviors,
  producing a useful independent comparison list.
- **Weakness:** It often promoted interface actions or README terminology into
  stronger product guarantees than the code supports, especially WIC
  verification, receipt checkout, external transaction completion, and
  cross-platform reliability.

## Reconciliation verdicts

- **K1:** Broadly useful goal inventory; merge barcode/manual lookup and narrow
  eligibility, alternative-swap, signup, and checkout claims.
- **K2:** Useful state trace; correct the cap invariant and asynchronous-load
  conclusions.
- **K3:** Valuable boundary inventory after removing repair proposals and
  unsupported inferences.
- **K4:** Order tracking finding is correct; receipt, eligibility, checkout, and
  cross-platform verdicts require narrower evidence-based wording.

