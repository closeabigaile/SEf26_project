# Codex P09 -- Milestone reality check

Model: GPT-5.6 Sol (Codex)  
Runner: Codex desktop  
Date: 2026-09-09  
Repository commit: `06f9dfe2280d6d1f6556d8e7609821c997c2c165` aka
"Support resources, standards, and licenses info"  
Prompt ID: P09  
Web access used: No  
Input files/context: `Project1a_Work/use_cases/usecases_final.md`,
`Project1a_Work/baseline.md`, Project 1a test and coverage records,
`Project1b_Work/README.md`, `Project1b_Work/inputs/team_skills.md`,
`Project1b_Work/analysis/design_decisions.md`,
`Project1b_Work/analysis/support_material.md`,
`Project1b_Work/rivals/validated_rivals.md`, `Project1b_Work/report/main.tex`,
relevant saved LLM analyses, and the current `Project3` source, tests, and
dependency configuration

## Exact prompt

```text
## Prompt 9 — Milestone Reality Check

We are evaluating the proposed milestones for **WolfBite**, the software product our team inherited and analyzed during Project 1a for CSC 510. We are preparing for Project 2 and need to determine whether the milestones currently documented in Project 1b are realistic for our actual team, available time, existing codebase, and testing requirements.

The goal is to challenge the milestone plan **before implementation begins**, not to justify it after the fact.

### Source Material

Before beginning:

1. Review the existing **Project 1a (`Proj1a`) codebase, use cases, tests, documentation, architecture, dependencies, and known technical issues**.
2. Use the **20 finalized Project 1a use cases** to understand what WolfBite already does.
3. Review the available **Project 1b (`Proj1b`) documentation**, especially:

   * D1 market analysis
   * D2 product direction / stay-or-pivot analysis
   * D3 milestones
   * D3 support material
   * Proposed Project 2 functionality
   * Relevant LLM analyses or team documentation
4. Locate the team's currently documented milestone groups:

   * **Before**
   * **Now**
   * **Future**
5. Treat the **Now milestones** as the primary proposed implementation scope for Project 2.
6. Use the actual existing implementation when estimating difficulty. Do not evaluate WolfBite as if it were being built from scratch.
7. Do not modify any project files. This task is analysis only.

---

### 1. Team and Time Constraints

Begin by summarizing the development constraints that can be established from the available project documentation.

Use this format:

**Team Size:**
[Number of active team members documented]

**Project Duration:**
[Available development period if documented]

**Approximate Development Capacity:**
[Estimate total person-hours only if enough information exists]

**Known Team Skills:**
[List only skills supported by the repository, prior Project 1a work, or documented team information.]

**Known Technical Experience:**
[Languages, frameworks, testing tools, databases, UI technologies, etc.]

**Important Unknowns:**
[List any skill or availability information that cannot be verified.]

Do **not** invent individual skills or assume all team members have equal experience.

If exact weekly hours are not documented, use the course/project assumptions provided in the assignment if available. Clearly identify any estimate.

---

### 2. Existing WolfBite Foundation

Before judging the milestones, briefly identify what the team already has.

Include:

* Existing implemented functionality
* Existing architecture
* Existing tests
* Reusable UI or backend components
* Existing data model
* Existing authentication or user-management functionality
* Important technical debt
* Known incomplete or unreliable functionality
* Any inherited code that may make extensions easier or harder

Then explain in 3–5 sentences how the existing system affects Project 2 scope.

The purpose of this section is to avoid estimating every milestone as though development starts at zero.

---

### 3. Milestones Found in Project 1b

Extract the documented D3 milestones from `Proj1b`.

Organize them exactly as currently documented:

#### Before Milestones

1. [Milestone]
2. [Milestone]
3. [Milestone]
   ...

#### Now Milestones

1. [Milestone]
2. [Milestone]
3. [Milestone]
   ...

#### Future Milestones

1. [Milestone]
2. [Milestone]
3. [Milestone]
   ...

Do not rewrite or improve the milestones yet. First reproduce their meaning faithfully so the later analysis evaluates the plan the team actually created.

---

### 4. Project 2 Milestone Reality Check

Evaluate **every Now milestone** against:

* Actual team size
* Available development time
* Approximate person-hours
* Existing WolfBite codebase
* Team familiarity with the technology
* Required implementation work
* Required testing work
* Integration complexity
* Research or support-material requirements
* Unknown technical risks

Classify each milestone as:

* **REALISTIC** — Reasonably achievable within the available time while still allowing adequate implementation, integration, and testing.
* **STRETCH** — Achievable, but only if development goes well or the scope is carefully controlled.
* **FANTASY** — Too large, risky, vague, technically uncertain, or time-consuming for this team and Project 2 timeframe.

Use this exact table:

| # | Now Milestone | Classification                | Estimated Effort    | Main Work Required | Main Risk | Why                        |
| - | ------------- | ----------------------------- | ------------------- | ------------------ | --------- | -------------------------- |
| 1 | [Milestone]   | REALISTIC / STRETCH / FANTASY | LOW / MEDIUM / HIGH | [Work]             | [Risk]    | [1–2 sentence explanation] |

Evaluate the milestones against a **student project team**, not a funded startup or professional development organization.

---

### 5. Effort Breakdown

For each Now milestone, break the work into these categories:

| Milestone   | Design              | Implementation      | Integration         | Testing             | Documentation       | Overall Effort      |
| ----------- | ------------------- | ------------------- | ------------------- | ------------------- | ------------------- | ------------------- |
| [Milestone] | LOW / MEDIUM / HIGH | LOW / MEDIUM / HIGH | LOW / MEDIUM / HIGH | LOW / MEDIUM / HIGH | LOW / MEDIUM / HIGH | LOW / MEDIUM / HIGH |

Briefly explain any milestone that contains a **HIGH** rating.

Consider hidden work such as:

* Updating existing models
* Database/schema changes
* New APIs
* Authentication/authorization changes
* UI changes
* Error handling
* Data migration
* Regression testing
* Unit tests
* Integration tests
* User-flow tests
* Accessibility
* Security concerns
* Documentation
* Integration with existing WolfBite functionality

Do not count only the time needed to create a visible feature.

---

### 6. Dependency Check

Identify whether any Now milestones depend on another milestone being completed first.

Use this table:

| Milestone   | Depends On                              | Blocking? | Risk if Dependency Slips |
| ----------- | --------------------------------------- | --------- | ------------------------ |
| [Milestone] | [Milestone / existing component / none] | YES / NO  | [Effect]                 |

Then identify the likely **critical path** for Project 2.

A milestone should receive additional risk if several other milestones depend on it.

---

### 7. Reality Check for Stretch Milestones

For every milestone classified as **STRETCH**, answer:

#### [Milestone Name]

**Why it is a stretch:**
[Explanation]

**What would have to go right:**
[Conditions]

**What should be cut first if the team falls behind:**
[Lower-priority functionality]

**Minimum acceptable version:**
[Smallest version that would still demonstrate meaningful value]

**Recommendation:**
KEEP / REDUCE SCOPE / MOVE PART TO FUTURE

---

### 8. Replace Every Fantasy Milestone

For every milestone classified as **FANTASY**, propose the **largest realistic slice** that could still be completed during Project 2.

Use this format:

#### Original Milestone — [Name]

**Why the original is unrealistic:**
[Specific reason based on time, complexity, architecture, or testing.]

**Realistic replacement:**
[Smaller milestone]

**Included functionality:**

* [Feature]
* [Feature]
* [Feature]

**Explicitly deferred:**

* [Feature]
* [Feature]

**Why this replacement is achievable:**
[Explanation]

**Suggested Future Milestone:**
[How the deferred portion could become a later milestone.]

Do not replace ambitious milestones with trivial work merely to guarantee completion. Preserve as much meaningful functionality as is realistically possible.

---

### 9. Testing Reality Check

Because Project 2 requires both **building and testing**, evaluate whether the milestone plan leaves enough capacity for meaningful testing.

Consider:

* Unit testing
* Integration testing
* Regression testing of Project 1a functionality
* New use-case testing
* UI or workflow testing
* Error cases
* Edge cases
* Security/access-control testing where applicable

Use this table:

| Milestone   | New Tests Needed    | Regression Risk     | Testing Effort      | Testing Concern |
| ----------- | ------------------- | ------------------- | ------------------- | --------------- |
| [Milestone] | [Brief description] | LOW / MEDIUM / HIGH | LOW / MEDIUM / HIGH | [Concern]       |

Then answer:

**Does the current milestone plan leave enough time for testing?**
YES / PROBABLY / NO

Explain briefly.

Do not classify a milestone as realistic if it is only realistic by skipping adequate testing.

---

### 10. Before and Future Milestone Check

Briefly review the documented **Before** and **Future** milestones as well.

For **Before milestones**, determine whether each appears to accurately describe work already completed in Project 1a.

Use:

| Before Milestone | Supported by Project 1a? | Evidence / Concern |
| ---------------- | ------------------------ | ------------------ |
| [Milestone]      | YES / PARTIAL / NO       | [Explanation]      |

For **Future milestones**, determine whether each is a logical later extension of the proposed Project 2 work.

Use:

| Future Milestone | Logical Future Direction? | Dependency on Project 2 | Concern       |
| ---------------- | ------------------------- | ----------------------- | ------------- |
| [Milestone]      | YES / MAYBE / NO          | [Dependency]            | [Explanation] |

Do not evaluate Future milestones as though they must be completed during Project 2.

---

### 11. Recommended Project 2 Milestone Set

Based on the analysis, create a revised milestone plan containing **3–5 Now milestones** that are ambitious but realistically achievable.

Use this exact table:

| Priority | Recommended Milestone | Scope                 | Why Realistic | Depends On   |
| -------- | --------------------- | --------------------- | ------------- | ------------ |
| 1        | [Milestone]           | [Clear bounded scope] | [Reason]      | [Dependency] |

The revised set should:

* Build naturally on WolfBite's existing implementation.
* Support the current Project 2 direction documented in Project 1b.
* Include meaningful new functionality.
* Leave adequate time for testing.
* Avoid unnecessary rewrites of working Project 1a functionality.
* Be specific enough that the team can determine when each milestone is complete.

Do not make the milestones so small that they become trivial.

---

### 12. Scope Protection

Identify:

**Must Have for Project 2**

* [Features/milestones necessary for a successful extension]

**Should Have**

* [Important but removable if schedule slips]

**Could Have**

* [Useful enhancements]

**Explicitly Defer**

* [Features that should remain Future milestones]

This section should make it clear what the team should cut first if development takes longer than expected.

---

### 13. Final Project 2 Reality Assessment

Finish with:

**Current Plan Overall:**
REALISTIC / STRETCH / UNREALISTIC

**Confidence:**
HIGH / MEDIUM / LOW

**Primary Reason:**
[Short explanation.]

Then complete:

| Measure                             | Assessment                          |
| ----------------------------------- | ----------------------------------- |
| Scope size                          | TOO SMALL / APPROPRIATE / TOO LARGE |
| Technical risk                      | LOW / MEDIUM / HIGH                 |
| Integration risk                    | LOW / MEDIUM / HIGH                 |
| Testing burden                      | LOW / MEDIUM / HIGH                 |
| Dependency risk                     | LOW / MEDIUM / HIGH                 |
| Likelihood of completing core scope | HIGH / MEDIUM / LOW                 |

Finally, provide the **3 most important recommendations** the team should follow before finalizing D3 and beginning Project 2 implementation.

---

### Important Rules

* Use the **documented Project 1a (`Proj1a`) code, use cases, tests, and architecture** to determine what already exists.
* Use the **documented D3 milestones in `Proj1b`** rather than asking us to paste the milestone list.
* Treat the **Now milestones** as the proposed Project 2 development scope.
* Use the Before milestones to describe prior work and Future milestones only as later possibilities.
* Do not invent team skills, availability, completed features, or technical capabilities.
* If team-skill information cannot be established, identify the uncertainty and judge complexity conservatively.
* Judge feasibility for the **actual student team and course timeframe**, not for a funded company.
* Account for implementation **and testing**, not coding alone.
* Consider integration and regression risk from modifying an inherited system.
* A milestone that can only be completed by skipping testing should not be classified as REALISTIC.
* Do not automatically label ambitious work as unrealistic. Consider whether the existing WolfBite implementation makes it easier.
* For every FANTASY milestone, propose the **largest meaningful realistic subset**.
* Do not turn ambitious milestones into trivial milestones merely to reduce risk.
* Clearly distinguish documented facts from estimates and assumptions.
* Do not modify any project files.
* Keep the output consistent and structured so the same prompt can be run through multiple LLMs and compared directly.
```

## Response

The central reality-check finding is that Project 1b does **not yet document
actual Before, Now, or Future milestones**. Both `report/main.tex` and
`analysis/design_decisions.md` contain placeholders. Therefore Sections 4–10
do not invent milestones to classify as though the team had already adopted
them; Section 11 supplies a proposed, checkable replacement plan.

### 1. Team and Time Constraints

**Team Size:**

Four active members are documented: Abigail Close, Aditya Mahajan, Satwi Shah,
and Supreme Constantine.

**Project Duration:**

One month to build **and test** Project 2.

**Approximate Development Capacity:**

The course workspace repeatedly states approximately 10 hours per student per
week. Assuming four weeks, the gross planning capacity is:

`4 students × 10 hours/week × 4 weeks = approximately 160 person-hours`.

This is scheduled capacity, not 160 implementation hours. Meetings, merge
coordination, report/poster work, review, study recruitment, and contingency
consume part of it. The repository does not support a more precise net-capacity
number.

**Known Team Skills:**

- Abigail Close: requirements analysis, evidence review, Dart/Flutter testing,
  traceability, ACM LaTeX report integration, and Git/PR workflow.
- Aditya Mahajan: Dart/Flutter testing, state/UI test curation, coverage-gap
  analysis, traceability, model-assisted analysis, and Git/PR workflow.
- Satwi Shah: Dart/Flutter testing, basket/quantity traceability, local-model
  execution/comparison, and Git/PR workflow.
- Supreme Constantine: Dart/Flutter testing, state/checkout traceability,
  model-output collection, and Git/PR workflow.
- As a team: reverse engineering, use-case writing, test design/execution,
  coverage analysis, requirements traceability, multi-model comparison, and
  collaborative report production.

**Known Technical Experience:**

Repository evidence demonstrates work with Dart, Flutter widget/unit testing,
Mockito, fake Cloud Firestore, Git/GitHub workflows, Markdown, and ACM LaTeX.
The team successfully analyzed a Flutter application using Provider state,
GoRouter, Firebase Authentication, Cloud Firestore, scanning, HTTP/OCR, and QR
packages. That establishes familiarity sufficient to extend and test the
existing stack; it does not establish production deployment expertise in every
component.

**Important Unknowns:**

- Each member's confirmed availability within the 10-hour planning assumption.
- Relative implementation depth in Flutter UI, asynchronous state management,
  Firebase Security Rules, and dependency-resolution work.
- Experience conducting accessible mobile-interface testing or moderated user
  studies.
- Access to representative WIC caregivers, WIC domain experts, assistive
  technology, or a state/retailer partner.
- Production security, privacy, regulatory, localization, and WIC/EBT/POS
  integration experience. The repository specifically does not establish these
  skills.

No ownership plan shows that all four members have equal expertise, so the
recommended work should be divided by demonstrated strengths and reviewed
across pairs rather than split into four isolated features.

### 2. Existing WolfBite Foundation

**Implemented functionality.** The 20 finalized use cases cover account
creation/sign-in/sign-out/session resumption (UC1–4); barcode/manual product
identification, nutrition summaries, healthier alternatives, and adding a
selection (UC5–9); receipt scanning and importing recognized items (UC10–11);
basket/nutrition/quantity/clear flows (UC12–17); benefit displays, QR checkout
handoff, and session completion (UC18–20).

**Architecture and reusable components.** WolfBite is a Flutter/Dart application
with GoRouter-authenticated routes, Firebase Authentication, Cloud Firestore,
Provider/`AppState`, an `AplService`, reusable scan, basket, balance, auth,
receipt, QR, nutrition, and badge screens/widgets, and camera/manual UPC input.
The Firestore model uses `users/{uid}` for basket/balance/profile state and an
`apl` collection keyed by UPC. This provides natural attachment points for a
new result/recovery screen and a deterministic service without rebuilding
navigation, authentication, scanning, or the basket.

**Existing tests.** The documented Project 1a team suite contains 86 tests: 82
passed and four intentionally retained failures expose application/requirement
mismatches. Executable-line coverage was 77.5%; main use-case outcomes were 90%
covered, but exception paths were 36.8% and persistence outcomes 43.5%. Eleven
post-curation state/persistence gap tests passed. Inherited tests also exist,
but a fresh broad resolution previously made five inherited files fail to
compile because `cloud_firestore` and `fake_cloud_firestore` resolved to an
incompatible pair.

**Important technical debt and unreliable behavior.** The application lockfile
is ignored, CI and older documentation refer to `Project2` instead of
`Project3`, and dependency resolution is not reproducible. Known failures
include unhandled profile-save and sign-out errors and false success after a
rejected alternative. Direct APL lookup can present an ineligible or missing-
eligibility record; missing nutrition values become zero; persistence failures
can leave local and cloud state inconsistent; the current receipt path uploads
the full image to OCR.space; and the QR handoff has no retailer/POS acceptance
or fallback.

This is not a build-from-zero project: routing, identity, state, product lookup,
manual/barcode input, and substantial test infrastructure can be reused. The
same inheritance creates regression and trust risk, so Project 2 should add a
small, pure rule layer and one integrated workflow rather than rewrite account,
basket, benefit, receipt, or checkout subsystems. Synthetic/versioned fixtures
avoid the highest-risk external integrations while still allowing a meaningful
feature and evaluation. At least one quarter of scheduled capacity should be
protected for test, integration, evaluation, documentation, and contingency
rather than assigned entirely to visible UI work.

### 3. Milestones Found in Project 1b

The following reproduces `report/main.tex` faithfully. Brackets identify the
LaTeX `\pending{}` marker; they do not turn its instruction into a milestone.
`analysis/design_decisions.md` likewise says only `Pending.` in each group.

#### Before Milestones

1. **[PENDING]** Add three to five completed, evidenced milestones.

#### Now Milestones

1. **[PENDING]** Add three to five ambitious but checkable milestones.

#### Future Milestones

1. **[PENDING]** Add three to five credible future milestones.

These are authoring placeholders, not milestone descriptions. In particular,
there is no current Now deliverable with a completion condition, owner,
dependency, effort, or test obligation.

### 4. Project 2 Milestone Reality Check

| # | Now Milestone | Classification | Estimated Effort | Main Work Required | Main Risk | Why |
|---|---|---|---|---|---|---|

**No rows to classify.** “Add three to five ambitious but checkable milestones”
is an instruction to the report authors, not an implementation milestone. It
would be misleading to label it REALISTIC, STRETCH, or FANTASY. The selected
mission describes a potentially feasible feature, but it does not allocate that
feature into current D3 work packages.

Plan-level consequence: the current Now plan is not executable. The team cannot
tell whether 160 scheduled person-hours are overcommitted, whether a feature is
done, what should be cut, or when integrated testing can start.

### 5. Effort Breakdown

| Milestone | Design | Implementation | Integration | Testing | Documentation | Overall Effort |
|---|---|---|---|---|---|---|

**No rows to estimate.** Project 1b has not documented any Now milestone. This
absence hides rather than reduces effort: fixture design, a rule engine, Flutter
workflow integration, accessibility, regression testing, comparative user
testing, and report evidence are all implied by D2 but allocated nowhere.

### 6. Dependency Check

| Milestone | Depends On | Blocking? | Risk if Dependency Slips |
|---|---|---|---|

**No documented milestone dependencies exist.** Based on the selected direction,
the likely technical sequence is nevertheless clear:

`stable baseline and scenario contract → deterministic recovery rules →
accessible integrated UI → regression testing and M0 comparison`.

The scenario/decision contract is the likely critical-path gate. The engine and
UI cannot be tested consistently until the team agrees on synthetic inputs,
reference likely causes, safe next actions, uncertainty language, and source-
freshness fields. Study-protocol drafting and participant recruitment can run
in parallel after that contract is stable; actual M0 trials depend on the
integrated baseline and treatment flows.

### 7. Reality Check for Stretch Milestones

No documented Now milestone can be classified as STRETCH. There is therefore
no existing stretch milestone to keep, reduce, or move. Section 11 identifies
where the proposed replacement plan is most schedule-sensitive without
pretending those recommendations were already in D3.

### 8. Replace Every Fantasy Milestone

No documented Now milestone can be classified as FANTASY. The report contains
an empty plan rather than an overlarge named milestone, so there is no honest
“original milestone” to replace. The largest realistic slice of the broader D2
mission is the four-milestone set in Section 11: fixed NC scenarios, a
deterministic rule service, one accessible integrated recovery flow, and a
tested baseline-versus-treatment M0 evaluation.

### 9. Testing Reality Check

For the **currently documented plan**:

| Milestone | New Tests Needed | Regression Risk | Testing Effort | Testing Concern |
|---|---|---|---|---|

There are no rows because there are no Now milestones.

**Does the current milestone plan leave enough time for testing?**  
**NO.** It reserves no work or completion criteria for any kind of testing. A
missing allocation cannot support unit, widget, integration, regression,
accessibility, security-rule, or M0 user-flow evidence.

For planning purposes, the recommended set in Section 11 would create this
testing burden:

| Recommended milestone | New Tests Needed | Regression Risk | Testing Effort | Testing Concern |
|---|---|---|---|---|
| 1. Stabilize baseline and freeze scenario contract | Dependency-resolution/build check; rerun 86-test team suite; fixture schema validation; preserve known-failure baseline | HIGH | MEDIUM | An unpinned incompatible fake/Firestore pair can block every test before feature work starts. Do not silently “fix” or delete known failing requirements evidence. |
| 2. Build deterministic explanation/recovery engine | Table-driven unit tests for each scenario, missing/conflicting/stale evidence, unknown inputs, deterministic output, and safe fallback | MEDIUM | MEDIUM | The main failure mode is a confident cause unsupported by the fixture evidence. Tests need negative assertions against guarantees and overrides. |
| 3. Integrate an accessible recovery workflow | Widget/navigation tests, screen-reader semantics, text scaling, focus, contrast/manual checks, loading/error/unknown states, back/dismiss, and baseline parity | HIGH | HIGH | UI may look complete while camera-only input, overflow, unclear uncertainty, or route/state coupling blocks the task. |
| 4. Verify and run M0 comparison | Full Project 1a regression, targeted Firestore Rules tests if data access changes, same-fixture baseline/treatment protocol, counterbalancing, task-success/time scoring, pilot, and reproducible results | MEDIUM | HIGH | Recruitment and study logistics are unverified, and the 80%/20-point thresholds cannot be claimed from a tiny convenience sample without reporting limitations. |

The revised plan can **probably** leave enough testing time if testing is part of
each definition of done and the team reserves roughly 30–40 person-hours for
final integration, regression, M0 execution, analysis, and documentation. It
does not fit if live APL/benefit/POS integration or full receipt reconciliation
is added.

### 10. Before and Future Milestone Check

#### Documented Before group

| Before Milestone | Supported by Project 1a? | Evidence / Concern |
|---|---|---|
| **[PENDING]** Add three to five completed, evidenced milestones. | NO | This is an instruction, not a claim about completed work. Project 1a has ample evidence, but none has been converted into D3 Before milestones. |

Evidence-supported Before milestones the team can adopt without overstating the
record are:

| Candidate Before milestone | Project 1a evidence |
|---|---|
| Finalized the inherited product model as 20 traceable use cases | `use_cases/usecases_final.md` documents UC1–UC20 and maps each to production evidence. |
| Built and executed a team-authored 86-test suite spanning all 20 use cases | The September 1 run records 82 passes and four retained failures with the complete output preserved. |
| Measured and audited test coverage instead of reporting test count alone | 77.5% executable-line coverage plus scenario audits identified exception, persistence, and state-transition gaps. |
| Exposed and documented inherited failure behavior and technical debt | The baseline and test reports record dependency drift, incorrect paths, auth/persistence errors, misleading success, unknown-as-zero nutrition, and QR/OCR boundaries. |

#### Documented Future group

| Future Milestone | Logical Future Direction? | Dependency on Project 2 | Concern |
|---|---|---|---|
| **[PENDING]** Add three to five credible future milestones. | NO | None | This is an instruction rather than a proposed direction, so its logic or dependencies cannot be evaluated. |

Credible Future candidates—**not** Project 2 commitments—are:

| Candidate Future milestone | Logical Future Direction? | Dependency on Project 2 | Concern |
|---|---|---|---|
| Add a permissioned, versioned multi-state APL adapter and refresh monitor | YES | Validated fixture/source/provenance model | Requires state permissions, reliable update ownership, jurisdiction handling, and stale-data operations. |
| Pilot a read-only agency/EBT/retailer evidence adapter for real rejection information | MAYBE | Demonstrated user value and stable recovery contract | Requires a qualified partner, data-sharing/security review, interface access, and careful separation from transaction authorization. |
| Add privacy-reviewed on-device receipt recognition and item-level reconciliation | MAYBE | Core recovery workflow and manual fallback | OCR accuracy, receipt variability, duplicates/quantities, device support, privacy, and testing are much larger than M0. |
| Expand to Spanish and additional accessibility/user studies | YES | Stable accessible workflow and research protocol | Requires professional translation/cultural review and recruitment beyond a convenience sample. |
| Prepare a production-grade release and operational security program | YES, only after validation | Stable product scope and deployment owner | Requires ownership, incident response, monitoring, backups, data retention, asset/APL rights, security assessment, and deployment-specific legal review. |

### 11. Recommended Project 2 Milestone Set

The following four milestones are a replacement proposal, not an extraction of
the current D3 text. Their combined planning range is approximately **110–135
person-hours**, leaving about 25–50 of the gross 160 hours for coordination,
report/poster integration, review, and contingency. Ranges are estimates, not
measured team velocity.

| Priority | Recommended Milestone | Scope | Why Realistic | Depends On |
|---:|---|---|---|---|
| 1 | Stabilize the inherited baseline and freeze the mismatch contract | Within approximately 20–25 hours: pin a compatible app dependency resolution; document/rerun the existing build and 86-test baseline; retain known failures explicitly; define at least four dated synthetic NC mismatch fixtures with exact UPC/package, app evidence, mocked benefit evidence, checkout result, reference likely cause, safe next action, source/freshness, and uncertainty wording. Done when fixtures validate and every field traces to a requirement/source. | Uses the existing test suite and completed support-material research. It removes an early test blocker without requiring unrelated application repair or live data. | Existing Project 1a evidence and completed D2/support-material decisions |
| 2 | Implement and unit-test a deterministic explanation/recovery service | Within approximately 25–30 hours: add a pure Dart service that consumes the frozen fixture/evidence model and returns evidence-backed possible causes, limitations, and one or two actions. Cover each rule, unknown/conflicting/stale evidence, invalid input, deterministic repeatability, and safe fallback. Done when the agreed table-driven suite passes and no output claims authorization, override, or certainty unavailable in the input. | A pure service is isolated from Firebase/POS risk, matches the team's demonstrated Dart testing skill, and delivers the feature's substantive logic. | Milestone 1 contract |
| 3 | Integrate one accessible explanation-and-recovery workflow | Within approximately 35–45 hours: connect the service to a bounded mocked rejection path using existing scan/manual UPC and navigation components; show item/package, source/freshness, uncertainty, concise cause, next actions, back/dismiss, and consistent agency help. Meet the chosen WCAG 2.2 AA checks and retain manual input/text output. Done when widget/navigation/error/accessibility tests pass for all fixtures. | Reuses WolfBite's routes, scan screen, product model, and test harness. Scope is one workflow—not a basket, auth, receipt, or backend rewrite. | Milestones 1–2 and existing scan/router components |
| 4 | Complete regression evidence and the M0 baseline-versus-treatment evaluation | Within approximately 30–35 hours: rerun/document Project 1a regression; execute the same counterbalanced synthetic scenarios in the baseline and recovery flows; pilot the procedure; record correct reference action, completion within 60 seconds, facilitator help, and qualitative burden; calculate task success and percentage-point difference; report results and limitations without treating targets as achieved in advance. Done when the run artifacts and analysis are reproducible. | The measurable claim and control are already defined, the scenarios are synthetic, and no live partner is required. A narrow protocol can fit if recruitment starts early. | Milestone 1 for protocol; Milestones 2–3 for final trials |

Suggested sequencing across four weeks:

- **Week 1:** Milestone 1; draft the M0 protocol and begin recruitment in
  parallel.
- **Week 2:** Milestone 2; begin UI shell and accessibility test cases.
- **Week 3:** Finish Milestone 3; integration pilot and defect correction.
- **Week 4:** Milestone 4; freeze scope, run regression/M0, analyze, and document.

The UI and evaluation milestones are the most schedule-sensitive. Their scope
remains realistic only because the plan excludes live data and starts study
preparation before the UI is complete.

### 12. Scope Protection

**Must Have for Project 2**

- A frozen, versioned set of at least four evidence-backed synthetic mismatch
  scenarios with reference next actions.
- A deterministic and thoroughly unit-tested likely-cause/recovery service.
- One integrated recovery flow that distinguishes app, APL, household-benefit,
  and retailer evidence and never claims an authoritative cause or override.
- Manual UPC/text alternatives, source/freshness, uncertainty, plain language,
  and the selected WCAG 2.2 AA checks.
- A documented dependency/test baseline and regression run.
- A reproducible same-scenario baseline-versus-treatment M0 evaluation that
  reports the 80%, 20-percentage-point, and 60-second measures honestly.

**Should Have**

- Externalized/localization-ready interface strings and a Spanish-language
  research plan, without promising an unreviewed translation.
- A fifth edge scenario if the four core rules and their negative cases are
  already stable.
- Automated accessibility assertions plus a documented manual screen-reader
  and text-scaling check.
- A simple export of de-identified aggregate study results for report figures.

**Could Have**

- Additional synthetic categories, package restrictions, or stale/conflicting
  evidence combinations.
- More polished transitions, icons, and source-detail disclosure.
- Local-only saved recovery examples if they do not introduce account/schema,
  retention, or migration work.

**Explicitly Defer**

- Live state APL synchronization or a claim that the bundled fixture is current.
- Live participant benefits, EBT transaction messages/reason codes, retailer
  POS integration, card numbers, PINs, payments, or balance mutation.
- An authoritative rejection diagnosis or a retailer override workflow.
- Cloud receipt upload, full receipt reconciliation, and production OCR; these
  are not required to prove the selected item-level recovery value.
- Multi-state rule coverage, complete professional translation, statewide
  deployment, production operations, and broad auth/basket rewrites.
- Predictive/LLM-generated eligibility or rejection-cause recommendations.

If schedule slips, cut in this order: visual polish and saved examples; the
fifth/additional scenarios; aggregate export; then localization-ready extras.
Do **not** cut rule tests, uncertainty/source labels, manual access,
accessibility basics, regression testing, or the comparative M0 evaluation,
because removing those would invalidate the core claim.

### 13. Final Project 2 Reality Assessment

**Current Plan Overall:**  
**UNREALISTIC**

**Confidence:**  
**HIGH**

**Primary Reason:**  
The current D3 plan contains no actual milestones—only instructions to add
them—so it cannot allocate the documented one-month capacity, expose
dependencies, reserve testing effort, or define completion.

| Measure | Assessment |
|---|---|
| Scope size | TOO SMALL — undefined rather than intentionally narrow |
| Technical risk | MEDIUM — the bounded deterministic feature is feasible, but inherited error/state issues remain |
| Integration risk | MEDIUM — manageable with synthetic adapters; HIGH if live WIC/EBT/POS or receipt processing enters scope |
| Testing burden | HIGH — regression, rule, widget/accessibility, error-path, and comparative user testing are all required |
| Dependency risk | HIGH — the ignored lockfile and known Firestore/fake incompatibility can block execution |
| Likelihood of completing core scope | LOW for the current empty plan; MEDIUM-HIGH for the bounded four-milestone replacement |

The three most important recommendations before D3 is finalized are:

1. **Replace every placeholder with the four checkable milestones in Section
   11**, including estimates, dependencies, and definitions of done; also add
   the four evidenced Project 1a Before milestones and three to five bounded
   Future milestones.
2. **Freeze the scenario/evidence contract and restore a reproducible test
   baseline in Week 1.** This is the critical-path gate; do not allow live APL,
   benefit, POS, payment, or receipt integration to enter M0.
3. **Budget testing and evaluation as deliverables, not cleanup.** Start the M0
   protocol/recruitment immediately, keep tests inside each milestone, and
   protect the final 30–40 person-hours for integration, regression, user-flow
   evaluation, analysis, and honest reporting.

