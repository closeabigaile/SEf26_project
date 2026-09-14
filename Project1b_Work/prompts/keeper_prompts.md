# Project 1b keeper prompts

Store the exact prompts the team designates for cross-model comparison here.
Do not revise a keeper between models; if a correction is necessary, create a
new version and record which models received each version.

## Required cross-model prompts

- P01 -- Market survey (starter Prompt 1)
- P10 -- Red team (starter Prompt 10; run only after a draft market survey,
  mission statement, and milestones exist)

### P01 -- Market survey (exact keeper version)

```text
You are a market analyst. Our product, in one paragraph:

WolfBite is a cross-platform Flutter/Firebase shopping assistant for WIC
participants. It lets authenticated shoppers identify products through barcode
scanning or manual UPC entry, review nutrition information, compare healthier
alternatives, manage a basket against WIC category allowances, import products
recognized from receipts, review benefit balances, and generate a QR-based
checkout handoff. Project 1a found that the application has useful shopping and
benefit-management features but also has inconsistent behavior around
eligibility, shopper-paid overflow, missing nutrition data, receipt importing,
persistence failures, and checkout interoperability.

Hard constraint: our four-student team has one month to build AND test the new
product, with approximately ten hours per student per week.

List the ten closest competing products. Output a table: product | who uses
it | main strength | main weakness | price | evidence URL.

Rules: no invented products. If you are not sure a product exists, leave it
out. If you cannot support a claim, write "unknown" -- do not fill the cell
with something plausible.
```

### P10 -- Red team (finalized proposal version, 2026-09-13)

```text
You are hostile to our proposal. Below: our mission statement, milestones,
and market survey.

Attack on three fronts:
1. Nobody wants it -- the need is imagined.
2. They cannot build it -- the month is too short, the team too green.
3. Someone does it better -- name who.

Make each attack as strong as you honestly can; no strawmen. Then, for each
attack, state what evidence would defeat it. We will go collect that evidence
-- or concede the point and change the plan.

Mission statement:
WIC participants and caregivers can face uncertainty when a product appears
eligible in an app but is rejected at checkout. We propose extending WolfBite
with an item-level explanation-and-recovery workflow that connects the
rejected item's UPC and package details, the participant's current benefit or
food category, and available eligibility or purchase evidence. For bounded
mocked mismatch scenarios, the workflow will distinguish app evidence from
facts that only a retailer or WIC agency can confirm, then show rule-based
possible causes and actionable next steps. The Project 2 M0 target is at least
80% task success and at least a 20-percentage-point improvement over a baseline
that shows the same eligibility result and mocked rejection without recovery
guidance. Success means selecting the scenario's reference next step within 60
seconds without facilitator help. These are targets, not achieved results.

Milestones for the one-month build-and-test period:
- M0: Compare the checkout-help flow with the baseline on the same prepared
  scenarios. Build and test a reproducible scoring script and measure the 80%
  task-success and 20-percentage-point improvement targets.
- M1: Add clearer nutrition units, serving or reference amounts, value
  explanations, and tradeoffs while preserving missing values as unknown.
  Verify data rules, units, comparisons, persistence, and missing-data behavior
  with unit and widget tests.
- M2: Add basket-aware, one-swap suggestions using a bounded mock catalog,
  compatible units and package amounts, and simulated allowances. Test
  quantity effects, basket-dependent rankings, previews, confirmed swaps,
  recalculation, missing data, balance consistency, and no-candidate cases.
- M3: Improve the scan, basket, and benefits interfaces, including loading,
  empty, error, and retry states and discoverable explanation and suggestion
  features. Verify principal flows, phone and desktop layouts, enlarged text,
  screen-reader labels, non-color status, and existing regressions.
- M4: For prepared package-size, category-balance, stale-information, and
  missing-evidence scenarios, show a rule-based possible cause and next action
  from a basket item. Test every rule and the complete item-to-help-and-back
  flow without changing basket contents.

Market survey:
The team ran a shared market-survey prompt with Codex, ChatGPT Terra, Gemini,
and local Ollama, then checked the strongest candidates against official
product sources. The three validated direct rivals are WICShopper, myWIC
Mosaic, and Bnft. WICShopper shows benefits, scans eligibility, provides food
guidance, and records item or category purchase history in supported agencies.
myWIC Mosaic shows benefits, tracks purchases, scans products, and supports
shopping, appointments, and certification. Bnft shows balances, scans benefit
eligibility, manages cards, and provides transaction history.

The selected gap is the absence from those rivals' public documentation of an
integrated, item-level explanation-and-recovery workflow for cases in which an
app indicates eligibility but checkout rejects the product. Participant
research supports continued difficulty identifying WIC-eligible foods and
stigma during shopping and checkout, and caregivers rank balance checking and
barcode scanning as high-priority app features. However, the gap has only
medium confidence: all three rivals provide some purchase or transaction
history, public documentation may omit relevant program-specific features,
and the team has no live WIC, EBT, retailer, or point-of-sale data. WolfBite
will therefore use simulated benefit and rejection scenarios and must not
claim an authoritative rejection reason or override a register result.
```

## Current discovery prompts

- P02 -- Mine the complaints
- P05 -- Extend the stakeholder list
- P06 -- Three futures
- P12 -- Stay or pivot

### P02 -- Mine the complaints (exact Codex version)

```text
You are a requirements and market-research analyst.

Below are 12 real issue observations from ten independent reviewers of three
products selected from our Prompt 1 rival list: WICShopper, Bnft, and myWIC
Mosaic. Each record includes a direct source and a limitation note. Treat two
issues from the same review as one independent report when discussing how many
users reported a theme. Do not treat an old or resolved report as a confirmed
current defect.

<paste the complete table and Corpus limitations from
Project1b_Work/inputs/complaint_corpus.md here>

Cluster these complaints into themes. Rank the themes by frequency times
severity. For each theme: quote one complaint verbatim as evidence, and say
whether any current product has fixed it. The unfixed themes are our
opportunity list.

Output one table with: rank | theme | complaint IDs | independent reports |
severity (1--3) | frequency-times-severity score | short verbatim evidence |
fixed, partial, not fixed, or unknown | reasoning. Then provide a numbered
opportunity list.

Hard constraint: our four-student team has one month to build AND test the new
product, with approximately ten hours per student per week.

Rules: use only the supplied corpus and its linked evidence. Do not invent
complaints, prevalence, product features, or fixes. Clearly distinguish a
complaint-derived opportunity from a verified market gap.
```

### P05 -- Stakeholder discovery (exact keeper version)

```text
You are a requirements engineer performing stakeholder analysis.

Our product is WolfBite, a cross-platform Flutter/Firebase shopping assistant
for WIC participants. It supports barcode or manual UPC identification,
nutrition information, healthier-alternative comparison, a basket tied to WIC
category allowances, receipt-product recognition, benefit balances, and a
QR-based checkout handoff. Project 1a found risks involving eligibility,
missing nutrition data, benefit state, persistence, receipt import, and
checkout interoperability.

Our stakeholders so far are: WIC shopper, WIC clinic staff, and WIC program
administrator.

That list is lazy. Extend it. Consider: who pays, who profits, who is harmed,
who is ignored, who regulates, who maintains this at 3 a.m., who gets sued when
it fails, and whose job changes because it exists.

For each new stakeholder, output a table with: stakeholder | relationship to
the product | what they fear | one design decision that would win them over |
how the four-student team could verify that decision in one month.

Hard constraint: our four-student team has one month to build AND test the new
product, with approximately ten hours per student per week.

Rules: do not rename the three existing stakeholders and present them as new.
Do not assume access to live WIC, EBT, retailer, or government systems. Mark
design decisions that would require external approval or integration, and
prefer a testable one-month slice when the full solution is too large.
```

### P06 -- Three futures (exact keeper version)

```text
Our product:

WolfBite is a cross-platform Flutter/Firebase shopping assistant for WIC
participants. It lets authenticated shoppers identify products through barcode
scanning or manual UPC entry, review nutrition information, compare healthier
alternatives, manage a basket against WIC category allowances, import products
recognized from receipts, review benefit balances, and generate a QR-based
checkout handoff. Project 1a found that the application has useful shopping and
benefit-management features but also has inconsistent behavior around
eligibility, shopper-paid overflow, missing nutrition data, receipt importing,
persistence failures, and checkout interoperability.

Propose three versions: SAFE (obvious next step), BOLD (a real bet), and
WILD (probably wrong, but instructive). For each:
- Elevator pitch, two sentences.
- What four students could build AND test of it in one month.
- The biggest risk.
- The kill signal: "we abandon this version if we see ___."

Do not blend them into one compromise. Keep the three futures distinct.
```

### P12 -- Pivot question (exact keeper version)

```text
Forget our current plan for a moment. Here are the facts, nothing else:

- The team: four graduate students, approximately ten hours each per week.
- The budget: one month to build AND test a working product.
- What we learned in Project 1a: The team reverse engineered WolfBite, a
  Flutter/Firebase WIC shopping assistant, into 20 verified use cases. We
  designed and ran 86 tests: 82 passed, three exposed unhandled or misleading
  behavior, and one exposed a test-scope mismatch. Executable-line coverage
  was 77.5%. The largest remaining test gaps involved exception paths,
  persistence, and state transitions. WolfBite includes authentication,
  barcode/manual UPC lookup, nutrition summaries, healthier alternatives, a
  basket tied to WIC allowances, receipt OCR, benefit balances, and a QR basket
  handoff. Project 1a also showed that eligibility, missing nutrition data,
  persistence failures, receipt behavior, and checkout interoperability can be
  misleading or underspecified.

Team skills, stated only from repository evidence:

- Abigail: requirements analysis, Codex evidence review, Dart/Flutter tests for
  UC1--UC5, traceability, ACM LaTeX integration, and Git/PR work.
- Aditya: Dart/Flutter tests for UC6--UC10, active-suite curation, coverage-gap
  analysis, traceability, Gemini analysis, and Git/PR work.
- Satwi: Dart/Flutter tests for UC11--UC15, traceability, local-Llama execution
  and comparison, and Git/PR work.
- Supreme: Dart/Flutter tests for UC16--UC20, traceability, GPT-5.6 Terra output
  collection, and Git/PR work.
- Across the team: Flutter/Dart testing, requirements traceability, Git
  collaboration, multi-model comparison, and report writing are demonstrated.
  Production WIC/EBT integration, professional nutrition expertise, and
  regulatory approval experience are not demonstrated. All other skills are
  unknown until members confirm them.

Question: is there a DIFFERENT kind of project we should be exploring--one we
have not considered because we anchored on the Project 1a product?

Propose three genuinely different project kinds (different domain, different
user, or different form: CLI vs web vs library vs bot). For each:

- Why THIS team, specifically, would be unusually good at it.
- What one-month build-and-test slice looks like.
- What we lose by walking away from our current plan.

Then answer plainly: stay the course, or pivot? One paragraph. No hedging.

Rules: do not invent team skills. Do not assume access to live WIC, EBT,
retailer, or government systems. Judge feasibility against approximately 160
total team hours, including tests and evaluation.
```


### Run metadata template

```text
Model:
Runner:
Date:
Repository commit:
Prompt ID:
Web access used:
Input files/context:
```
