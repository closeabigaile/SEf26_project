# Gemini P12 -- Pivot analysis

- Model: Gemini 3.1 Pro (High)
- Runner: Antigravity
- Date: 2026-09-06
- Repository baseline: unknown
- Prompt ID: P12
- Web access used: No
- Input files/context: None

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
total total team hours, including tests and evaluation.
```

## Complete raw response

### 1. WIC Policy Rule Engine (Library)
- **Why THIS team, specifically, would be unusually good at it:** The team has strong demonstrated skills in testing (86 tests, 77.5% coverage), requirements analysis, and traceability. Building a robust, well-tested, headless rule engine leverages their testing and analysis strengths without requiring UI/Flutter expertise.
- **What one-month build-and-test slice looks like:** A self-contained Dart package that takes a product UPC and a user's current benefit state, and returns a deterministic "eligible/ineligible" decision based on a configurable set of WIC rules, accompanied by an extensive test suite covering exception paths and state transitions.
- **What we lose by walking away from our current plan:** The direct user-facing impact and the opportunity to build a complete consumer application.

### 2. LLM Requirements Analysis Tool (CLI)
- **Why THIS team, specifically, would be unusually good at it:** The team has demonstrated experience with multi-model comparison (Codex, Gemini, local-Llama, GPT-5.6) and requirements traceability. They could build a tool that automates the kind of analysis they are currently doing manually.
- **What one-month build-and-test slice looks like:** A Python CLI tool that takes a requirements document and a test suite as input, runs them through multiple LLMs to identify coverage gaps or ambiguities, and outputs a traceability matrix report.
- **What we lose by walking away from our current plan:** We abandon the entire WIC domain and the Project 1a codebase completely, starting from scratch in a new problem space.

### 3. EBT POS Mock Validator (Web Tool for Developers)
- **Why THIS team, specifically, would be unusually good at it:** Aditya and Satwi's focus on active-suite curation, coverage gaps, and test execution makes them ideal for building developer tools. They understand the pain of underspecified behavior and exception paths from Project 1a.
- **What one-month build-and-test slice looks like:** A web-based dashboard (using simple Flutter Web) that simulates a grocery store's Point of Sale system, allowing other WIC app developers to test their QR handoff or barcode logic against a rigorous suite of edge cases.
- **What we lose by walking away from our current plan:** Building a product for actual WIC participants; we become a B2B/developer-tool team.

Stay the course. While the team's testing and analysis skills could support a pivot to a backend rule engine or developer tool, the one-month (160 hour) constraint heavily penalizes throwing away the existing Project 1a Flutter/Firebase codebase. The team has already reverse-engineered 20 use cases, built 86 tests, and achieved 77.5% coverage on WolfBite. Abandoning this foundation to start a new domain or form factor from scratch would waste the domain knowledge and architectural understanding they've gained, making it highly unlikely they could build and test a completely new product to the same level of rigor in just four weeks.
