# Gemini Antigravity runbook for Project 1b

## Instructions for Gemini

You are the Gemini analyst assigned to Aditya's Project 1b work. Follow this
document exactly.

### Repository boundaries

- Work only in the branch and working tree that are already checked out when
  this run begins.
- Do not switch, create, merge, rebase, or inspect any other local or remote
  Git branch.
- Do not run `git branch`, `git fetch`, `git switch`, `git checkout`,
  `git worktree`, or commands that read files from another Git ref.
- Do not inspect commits, diffs, raw outputs, prompts, analyses, or conclusions
  from other team members or other models.
- You may read files that exist in the current working tree when this document
  explicitly names them. If a named file is absent, use the context embedded
  in this document and record that fact in `Input files/context`.
- Do not modify application code, tests, shared inputs, or keeper prompts.
  Create only the Gemini raw-output files requested below.

These restrictions preserve an independent Gemini result for later
cross-model comparison.

### Execution rules

1. Run P01, P02, P05, P06, and P12 independently, in that order. Do not use an
   earlier prompt's response as evidence or input for a later prompt.
2. Treat every prompt block below as exact text. Do not rewrite, shorten, or
   silently correct it before answering.
3. Start each output file with the metadata format shown below. Replace every
   placeholder with the actual value. Use the full Gemini model name shown in
   Antigravity and the actual calendar date of the run in `YYYY-MM-DD` format.
4. Copy the exact prompt into `## Exact prompt`, then place the complete,
   unedited response in `## Complete raw response`.
5. Follow every requested table, column, ranking, and conclusion format.
6. Do not include facts that came from another branch or another model's
   response. Do not use another model's proposed rivals or recommendation as
   input.
7. When web access is allowed, use live, relevant evidence URLs and do not
   invent products, prices, features, complaints, or fixes. Write `unknown`
   where the evidence does not support a claim.
8. Do not place corrections or retrospective analysis in a raw-output file.
   Preserve the original response, including mistakes, for later review.
9. Do not run P10 yet. P10 requires an agreed draft market survey, mission
   statement, and milestones that are not supplied in this runbook.

### Required output format

Save each result under `Project1b_Work/model_outputs/gemini/` using these file
names, replacing `YYYY-MM-DD` with the run date:

- `P01_market_survey_YYYY-MM-DD.md`
- `P02_complaint_analysis_YYYY-MM-DD.md`
- `P05_stakeholder_analysis_YYYY-MM-DD.md`
- `P06_three_futures_YYYY-MM-DD.md`
- `P12_pivot_analysis_YYYY-MM-DD.md`

Use this exact wrapper in every file:

````markdown
# Gemini <PROMPT ID> -- <prompt title>

- Model: <full Gemini model name>
- Runner: Antigravity
- Date: <YYYY-MM-DD>
- Repository baseline: <current commit hash, or "unknown" if unavailable>
- Prompt ID: <P01, P02, P05, P06, or P12>
- Web access used: <Yes or No>
- Input files/context: <current-branch files read and/or embedded context used>

## Exact prompt

```text
<paste the exact prompt from this runbook>
```

## Complete raw response

<paste the complete response without editing or summarizing it>
````

## P01 -- Market survey

Web research is allowed for this prompt. Open and verify the evidence URLs
before including them.

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

## P02 -- Mine the complaints

Use only the complaint corpus embedded in this prompt. Opening its supplied
links to determine whether a reported issue has been fixed is allowed. Do not
search for, read, or use any other team's complaint corpus or analysis.

```text
You are a requirements and market-research analyst.

Below are 12 real issue observations from ten independent reviewers of three
products selected from our Prompt 1 rival list: WICShopper, Bnft, and myWIC
Mosaic. Each record includes a direct source and a limitation note. Treat two
issues from the same review as one independent report when discussing how many
users reported a theme. Do not treat an old or resolved report as a confirmed
current defect.

| ID | Rival product | Complaint excerpt | Source URL | Source type | Date accessed | Notes |
|---|---|---|---|---|---|---|
| C01 | WICShopper | "doesn't always show everything that's available" | https://apps.apple.com/us/app/wicshopper/id614569159?platform=iphone&see-all=reviews | Apple App Store review | 2026-09-03 | Scanner coverage complaint; listing displays the review as May 23 without a year. Self-reported, so it establishes user experience rather than root cause. |
| C02 | WICShopper | "approved that isn't actually approved" | https://apps.apple.com/us/app/wicshopper/id614569159?platform=iphone&see-all=reviews | Apple App Store review | 2026-09-03 | Reviewer describes a package-size mismatch at checkout; listing displays May 4 without a year. |
| C03 | WICShopper | "my benefits have expired" | https://apps.apple.com/us/app/wicshopper/id614569159?platform=iphone&see-all=reviews | Apple App Store review | 2026-09-03 | Reviewer reports an incorrect beginning-of-month status until the card is used; listing displays June 1 without a year. |
| C04 | WICShopper | "item descriptions are generic" | https://play.google.com/store/apps/details?id=com.jpma.EBTShopper | Google Play review | 2026-09-03 | Dated 2026-06-29; reviewer says poor search descriptions increase in-store shopping time. |
| C05 | Bnft | "logs me out multiple times" | https://apps.apple.com/us/app/bnft/id1286864895 | Apple App Store review | 2026-09-03 | The listing displays March 22 without a year. Same review as C06; count it as one independent reviewer when measuring frequency. |
| C06 | Bnft | "unknown error please try again" | https://apps.apple.com/us/app/bnft/id1286864895 | Apple App Store review | 2026-09-03 | Scanner failure reported in the C05 review after update/reinstall troubleshooting. |
| C07 | Bnft | "log in sometimes up to three times" | https://apps.apple.com/us/app/bnft/id1286864895 | Apple App Store review | 2026-09-03 | Review dated 2025-11-07 describes repeated login plus text verification during one shopping trip. |
| C08 | Bnft | "Cannot update phone number" | https://apps.apple.com/us/app/bnft/id1286864895 | Apple App Store review | 2026-09-03 | Review dated 2023-08-29 describes account lockout after loss of the old number; older report with no current resolution established. |
| C09 | myWIC Mosaic | "scanner stopped working" | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 | Apple App Store review | 2026-09-03 | Review dated 2025-08-27 reports that reinstalling restored the scanner; this is a workaround, not proof of a current universal failure. |
| C10 | myWIC Mosaic | "eligible items comes back ineligible" | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 | Apple App Store review | 2026-09-03 | Updated 2024-06-06 review says the scanner was repaired after roughly two months, so this incident is marked resolved. |
| C11 | myWIC Mosaic | "schedule Wic appointments ... not an available option" | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 | Apple App Store review | 2026-09-03 | Review dated 2025-01-30; may depend on clinic/program configuration rather than only the app. |
| C12 | myWIC Mosaic | "none of them will register" | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 | Apple App Store review | 2026-09-03 | Same C11 reviewer reports failed baby/pregnancy status changes. Treat C11 and C12 as one independent reviewer in frequency claims. |

Corpus limitations:

- These are 12 issue observations from ten independent reviewers, not 12
  independent people.
- App-store reviews are direct evidence that users reported a problem, but do
  not by themselves prove the technical cause or current prevalence.
- C08 is older, C10 was later reported fixed, and C09 has a reinstall
  workaround. They remain useful history but must not be described as confirmed
  current defects.
- Reviews shown without a year are recorded exactly that way rather than
  assigning a guessed year.

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

## P05 -- Stakeholder discovery

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

## P06 -- Three futures

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

## P12 -- Pivot question

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

## Completion checklist

Before finishing, confirm that:

- Exactly five Gemini raw-output files were created.
- Each file contains complete metadata, the exact prompt, and the complete raw
  response.
- All requested tables contain the exact requested columns.
- No other branch, teammate output, or other model's conclusions were read.
- No shared prompt, application, test, or analysis file was changed.
- P10 was not run.
