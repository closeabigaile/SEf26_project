# Prompt Notes — Codex (sheet-ready bullets)

## Errors or overstatements caught

- Codex initially treated every existing APL document as proof of WIC
  eligibility. Code inspection showed `findByUpc` returns any document at that
  UPC and does not check `eligible == true`; only the healthier-alternative
  query explicitly filters eligibility. We narrowed the claim to “APL product
  lookup.”
- Codex could have accepted the README’s real-time order-tracking feature as a
  use case. The route and source inventory contains no order or tracking module,
  so we excluded it as unsupported documentation.
- The README says receipt import automatically checks out products and updates
  balances. Codex’s code trace found that receipt scanning only identifies
  products; the user must press Add All, which adds accepted products to the
  basket rather than calling checkout.
- QR checkout looked fully implemented from the README. The code does render
  real basket JSON as a QR, but it has no cashier acknowledgement or
  interoperability check. A separate unused basket dialog also displays only a
  dummy QR icon.
- Codex’s initial use-case wording risked treating “start a new benefit month”
  as an independent actor goal. Because it is automatically triggered while
  restoring state, it is better recorded as an extension of “Resume saved
  shopping session.”
- Missing nutrition data defaults to zero. Codex flagged that this can award
  low-fat, low-sodium, low-sugar, low-calorie, or heart-healthy badges even
  though the value is unknown; the UI does not distinguish unknown from zero.
- Codex found that several success messages are stronger than the state
  guarantee: scan additions persist asynchronously without awaiting failure,
  and healthier-alternative addition ignores `addItem`’s return value but still
  reports success.

## Which prompts earned their keep

- K1 earned its keep because ranked actor goals plus mandatory file:line
  evidence exposed the unsupported order-tracking claim and prevented private
  helpers from becoming use cases.
- K2 earned its keep because the end-to-end state trace exposed the important
  basket/balance invariants, PAID overflow behavior, unawaited persistence, and
  the difference between receipt import and checkout.
- K3 earned its keep because it produced specific, testable boundaries rather
  than generic API-error cases—for example, same month in a different year,
  exact category cap, PAID-first decrement, 13/14-digit OCR windows, and missing
  nutrients defaulting to zero.
- K4 earned its keep because comparing README claims with routes and production
  code found material contradictions: absent order tracking, overstated receipt
  checkout, weaker-than-claimed WIC verification, and CI targeting `Project2`
  instead of `Project3`.
- The starter “first contact” prompt was useful for repository orientation and
  ranking important files, but it was not sufficient to establish use cases or
  tests by itself.
- The starter fragility prompt was useful for prioritizing receipt OCR,
  scan/swap, and basket/balance state, but its conclusions are risk hypotheses,
  not proof that those features fail.

## Codex strength/weakness line

- Strength: Codex traced Flutter UI, state, Firestore persistence, routes, README,
  workflow, and history into concrete file:line evidence and testable
  invariants. Weakness: its first-pass summaries could over-trust domain labels
  such as “approved” or promote system-triggered behavior into a user goal unless
  the prompt explicitly required code-level contradiction checking.

## Codex keeper-prompt verdicts

- K1 verdict: Twenty defensible goals exist, but monthly reset belongs under
  session restoration; food delivery and order tracking are unsupported.
- K2 verdict: The main state flows are implemented, but some UI paths report
  success before persistence completes or without checking whether state
  accepted the operation.
- K3 verdict: The most valuable boundaries are WIC-cap-to-PAID overflow,
  paid-first decrement, month/year rollover, OCR candidate windows and
  deduplication, and missing nutrition treated as zero.
- K4 verdict: The README and CI are stale: order tracking is absent, receipt
  checkout is overstated, eligibility verification is weaker than claimed, and
  CI targets the missing `Project2` directory.

## Evidence record

- Full Codex K1–K4 output:
  `Project1a_Work/model_outputs/codex/codex_keeper_outputs.md`.
- Repository state analyzed: commit `cc22b3c`; production repository remained
  unmodified.
