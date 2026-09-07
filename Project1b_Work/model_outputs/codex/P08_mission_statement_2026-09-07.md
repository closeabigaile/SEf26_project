# Codex P08 -- Mission statement

- Model: GPT-5.6 Sol (Codex)
- Runner: Codex desktop
- Date: 2026-09-07
- Repository baseline: `3a52bc516a64`
- Prompt ID: P08
- Web access used: No
- Input files/context: User-provided Prompt 8 text and WolfBite poster screenshot

## Exact prompt

```text
You are a software product strategist helping a four-student software
engineering team write the mission statement for the next version of an
existing product.

A mission statement gives the WHY (the challenge), the WHAT (the thing we
build), and the SO WHAT (the benefit).

Example of the required form:

"Online content can be emotionally overwhelming. Our app helps make sense of
it. Sentiment Analyzer Pro lets users analyze the emotional tone of text,
images, news, speech, and YouTube comments. Whether you track brand sentiment,
filter negativity, or just stay informed, the app makes emotional insight fast
and accessible. With a Chrome extension and improved UI, it is now easier than
ever to understand how content feels, not just what it says."

FACTS ABOUT OUR PRODUCT AND MARKET

Product:
- Our Project 1a product is WolfBite, a WIC-focused shopping application.
- We are proposing version i+1 of the product rather than blindly preserving
  every existing feature.

Primary users:
- WIC participants and caregivers shopping for their households.
- We are particularly concerned with users managing children or other
  responsibilities while shopping and dealing with an unexpected rejection
  at checkout.

Validated direct rivals:
- WICShopper
- myWIC Mosaic
- Bnft

How the rivals were validated:
- We used four independent LLM analysts: Codex, Terra, Gemini, and local
  Ollama.
- A rival was retained only if at least two models named it or one model
  provided a live, relevant URL.
- The three strongest rivals were then independently checked using official
  product sources.

What the strongest rivals already do:
- Show WIC benefits or balances.
- Help users determine whether products are WIC eligible.
- Provide barcode/product scanning.
- Provide some form of shopping, purchase, or transaction information.
- Some also provide card, appointment, certification, or food-guidance
  functions.

Validated market finding:
- Our focused feature audit found no documented integrated, item-level
  explanation-and-recovery workflow in WICShopper, myWIC Mosaic, or Bnft for
  situations where an app indicates that a product is eligible but the item
  is rejected at checkout.
- Existing products may provide transaction or purchase history, but that is
  not the same as explaining a specific eligibility/checkout mismatch and
  helping the user determine what to do next.

Selected opportunity:
- Improve the shopping/checkout workflow around unexpected WIC item rejection.
- The proposed feature should help connect the rejected item, the user's
  current benefit or food category, and available purchase/eligibility
  information to likely causes and actionable next steps.
- The goal is explanation and recovery, not simply another barcode scanner.

Evidence behind the need:
- Participant research found difficulty identifying WIC-eligible foods and
  reported stigma or difficulty during shopping and checkout.
- WIC caregivers place high value on functions such as balance checking and
  barcode scanning.
- We rejected nutrition comparison as our primary gap because evidence of
  participant demand was comparatively weak.
- We rejected broad receipt reconciliation as the primary gap because the
  strongest rivals already provide some form of purchase or transaction
  history.

Stakeholders currently identified:
- WIC participants and caregivers
- WIC program staff/agencies
- Grocery retailers/cashiers
- Product maintainers/developers
- Additional stakeholders may be identified from our existing Prompt 5 work.

Project constraint:
- We are four students.
- We have ONE MONTH to build AND test the proposed version.
- Do not propose a mission that assumes access to national WIC infrastructure,
  live retailer POS integrations, or capabilities that cannot realistically
  be implemented and tested by four students in one month.

D2 requirement:
- The final mission statement must clearly communicate WHY / WHAT / SO WHAT.
- The SO WHAT will eventually need at least one concrete, measurable claim
  that Project 2's M0 evaluation can test.
- Do not invent a measurement result that we have not tested yet.
- You may suggest what kind of measurable outcome would fit each candidate,
  but label it as a proposed metric, not an achieved result.

TASK

Write THREE candidate mission statements.

For each candidate:

1. Write exactly five sentences.
2. Clearly communicate:
   - WHY: the user challenge
   - WHAT: what version i+1 will do
   - SO WHAT: the benefit
3. Name or clearly identify the primary user.
4. Include at least one concrete detail that a rival could not simply
   copy-paste into its own mission statement.
5. Keep the scope realistic for four students to build AND test in one month.
6. Do not claim that competitors categorically lack a feature when our
   evidence only established "no documented feature."
7. Do not invent facts about WIC participants, competitors, laws, or the
   existing code.
8. Avoid vague marketing language.
9. After each candidate, provide:
   - WHY in one short phrase
   - WHAT in one short phrase
   - SO WHAT in one short phrase
   - Suggested measurable M0 metric (proposal only)

BANNED WORDS:
- leverage
- empower
- seamless
- revolutionize
- cutting-edge
- innovative
- solution

OUTPUT FORMAT

## Candidate 1
<five-sentence mission statement>

WHY:
...

WHAT:
...

SO WHAT:
...

Possible M0 metric:
...

## Candidate 2
<five-sentence mission statement>

WHY:
...

WHAT:
...

SO WHAT:
...

Possible M0 metric:
...

## Candidate 3
<five-sentence mission statement>

WHY:
...

WHAT:
...

SO WHAT:
...

Possible M0 metric:
...

## Comparison

| Candidate | Strongest quality | Biggest weakness | One-month feasibility |
|---|---|---|---|

## Recommendation

Choose the strongest candidate for this evidence and explain why in no more
than three sentences. Do not rewrite it yet; the team will make the final
decision.
```

## Complete raw response

## Candidate 1

WIC participants and caregivers can reach checkout believing an item is eligible, only to face a rejection while managing a household shopping trip. WolfBite version i+1 will let a shopper select the rejected basket item and relate its UPC and package size to the shopper's current benefit category and locally available eligibility and purchase information. It will present a small, testable set of likely mismatch causes—such as package-size, remaining-quantity, or stale-data conflicts—without claiming to know the retailer's authoritative rejection reason. For each cause, it will show a next step, such as checking the package, choosing a matching item, or asking the cashier or WIC agency for help. This focused recovery path aims to help shoppers understand and act on an unexpected rejection with less uncertainty than a scan result or transaction history alone.

WHY:
Unexpected checkout rejection creates uncertainty.

WHAT:
Item-level cause and recovery guidance.

SO WHAT:
A clearer next action for the shopper.

Possible M0 metric:
Proposal only: On 30 seeded mismatch fixtures, the percentage for which WolfBite displays the expected likely-cause category and recovery action; proposed target at least 90%, with current WolfBite measured first as the baseline.

## Candidate 2

Unexpected WIC item rejections can leave participants and caregivers unsure whether the conflict comes from the item, their benefit category, or information displayed before checkout. WolfBite version i+1 will add an item-level rejection review that links a selected basket item to its category balance and the eligibility evidence available to the app. Instead of pretending it receives the point-of-sale rejection reason, the workflow will state its evidence limits and show only rule-based likely causes from a bounded scenario set. It will give the shopper a short recovery checklist and a compact case summary to reference when speaking with a cashier or WIC agency. The result aims to reduce the time needed to choose a defensible next action while keeping uncertainty visible.

WHY:
Rejections leave the source of conflict unclear.

WHAT:
A bounded review with a checklist and case summary.

SO WHAT:
Faster, evidence-aware recovery.

Possible M0 metric:
Proposal only: Median time for recruited test users to select the expected next action in scripted rejection tasks; proposed target no more than 60 seconds and at least 25% faster than the measured current-flow baseline.

## Candidate 3

WIC participants and caregivers need more than an eligible label when checkout behavior contradicts what the app showed during shopping. WolfBite version i+1 will turn a rejected basket item into a traceable case containing its UPC, package details, benefit category, balance snapshot, and data-source timestamps. It will distinguish what the app knows, what may be stale, and what only a retailer or WIC agency can confirm. Using synthetic and versioned data, the four-student team will implement and test explanations for a bounded set of mismatch scenarios and attach a recovery action to each one. This gives shoppers a transparent path from contradiction to next step without presenting the prototype as an official point-of-sale or WIC authority.

WHY:
An eligibility contradiction needs a trustworthy explanation.

WHAT:
A traceable mismatch case with explicit evidence limits.

SO WHAT:
Transparent recovery without false authority.

Possible M0 metric:
Proposal only: Percentage of seeded mismatch cases that show source age, uncertainty, and no unsupported authoritative-cause claim; proposed target 100%, with the current app evaluated first for the baseline.

## Comparison

| Candidate | Strongest quality | Biggest weakness | One-month feasibility |
|---|---|---|---|
| 1 | Best balance of human need, concrete behavior, and practical recovery | The five-sentence statement carries several technical details | High: a bounded cause-and-action workflow can be built and tested with fixtures |
| 2 | Centers decision speed and gives the shopper a reusable case summary | The case-summary concept may require extra interface work | High: the scenario set and checklist can remain small |
| 3 | Draws the clearest boundary between app evidence and external authority | More technical and less emotionally direct | High: synthetic, versioned cases avoid live integrations |

## Recommendation

Candidate 1 is strongest because it connects the validated checkout problem to a specific, bounded recovery workflow and a direct shopper benefit. Its UPC, package-size, category, and recovery-action details make it specific to WolfBite while remaining testable in one month. The proposed fixture metric also evaluates the core behavior without claiming an unmeasured result.
