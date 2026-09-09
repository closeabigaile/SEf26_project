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
