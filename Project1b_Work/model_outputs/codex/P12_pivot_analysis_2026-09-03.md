# Codex P12 -- Pivot analysis

- Model: GPT-5.6 Sol (Codex)
- Runner: Codex desktop
- Date: 2026-09-03
- Repository baseline: `5917721b4199` (`Prompt 1: Codex market survey`)
- Prompt ID: P12
- Web access used: No
- Input files/context: `Project1b_Work/inputs/team_skills.md`, verified Project
  1a report, and Project 1b Codex market/complaint analysis

## Exact prompt

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
  regulatory approval experience are not demonstrated.

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

## Complete raw response

| Different project kind | Different domain, user, or form | Why this team is unusually suited | One-month build-and-test slice | What the team loses by walking away from WolfBite |
|---|---|---|---|---|
| WIC approved-product-list integrity auditor | A CLI/library for WIC data stewards and application developers rather than a shopper-facing mobile app | The team has already traced UPC lookup, categories, allowances, missing nutrition, leading-zero identifiers, and eligibility ambiguity into tests and requirements | Accept one documented or synthetic APL schema; detect duplicate/conflicting UPCs, invalid package sizes, missing provenance, stale versions, and incomplete nutrition; emit Markdown/JSON reports; test with seeded faults and measure detection precision/recall | The existing shopper UI, authentication, receipt flow, basket, and QR work become mostly irrelevant; access to authoritative production APL data remains external |
| Requirements-to-test traceability workbench | A web/CLI developer tool for student software teams in any domain | The team just reconciled 20 use cases, mapped 86 tests, quantified uncovered extensions, and produced ACM evidence across four contributors | Parse a constrained Markdown use-case/test format, generate a traceability matrix, flag unmapped requirements and weak assertions, and export report-ready tables; evaluate against the Project 1a corpus plus seeded omissions | The team gives up the WIC mission and most inherited Flutter product code, although it gains a strong internal evaluation dataset |
| Campus grocery budget and nutrition assistant | A student-focused mobile app rather than a government-benefit application | The team can reuse demonstrated Flutter/Dart testing, basket state, receipt recognition concepts, nutrition presentation, and failure-path analysis while acting as accessible domain users | Import a fixed receipt corpus, categorize purchases, show budget remaining, and compare a small curated set of alternatives; use no banking integration; test OCR accuracy, category totals, missing nutrition, and accessibility | The social-impact WIC audience, benefit rules, Project 1a eligibility findings, and existing rival research would be discarded; the team would need a new market survey |

**Recommendation: stay the course.** Continue with WolfBite because this team
has verified knowledge of its Flutter/Dart code, twenty requirements, failure
paths, and test infrastructure, while every proposed pivot would discard either
the user mission, the existing product, or the market evidence already
collected. The one-month product should be a narrow, reliability-first WIC
shopping extension: make eligibility results explicitly eligible, ineligible,
or unknown/stale; expose source and refresh time; preserve manual lookup and a
tested degraded mode; and evaluate the behavior with synthetic/versioned data.
Do not spend the month claiming live EBT balance, retailer payment, nationwide
APL, or production nutrition authority that the team cannot verify.
