# Codex P13 -- Build the D3 milestone plan

Model: GPT-5.6 Sol (Codex)  
Runner: Codex desktop  
Date: 2026-09-09  
Repository commit: `06f9dfe2280d6d1f6556d8e7609821c997c2c165` aka
"Support resources, standards, and licenses info"  
Prompt ID: P13  
Web access used: No  
Input files/context: `Project1a_Work/use_cases/usecases_final.md`,
`Project1a_Work/baseline.md`, Project 1a test and coverage records,
`Project1b_Work/README.md`, `Project1b_Work/inputs/team_skills.md`,
`Project1b_Work/analysis/design_decisions.md`,
`Project1b_Work/analysis/support_material.md`,
`Project1b_Work/rivals/validated_rivals.md`, `Project1b_Work/report/main.tex`,
the saved Prompt 9 reality check, and the current `Project3` source, tests, and
dependency configuration

## Exact prompt

```text
## Prompt 13 — Build the D3 Milestone Plan

We are preparing **D3 for Project 2** for WolfBite in CSC 510.

The current issue is that some prior analyses could not fully evaluate milestone realism because the project does not yet have a finalized milestone set.

Your task is to propose a complete and realistic D3 milestone plan that satisfies the following requirement:

| D3 | Milestones: before / now / future, 3–5 each, clear goals. Plus the support material (regulations, standards, licenses) your design must respect, with sources. | engineering evidence: could each be built AND checked? |
| -- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------ |

The goal is to create milestones that are ambitious enough to be meaningful, but realistic for the actual course project.

Do not modify any project files. This task is analysis and planning only.

---

### 1. Review the Existing Project First

Before proposing milestones, inspect the project documentation and code.

Use:

* The documented **Project 1a (`Proj1a`) use cases**
* The existing WolfBite implementation
* Existing tests
* Architecture and dependencies
* Any known incomplete functionality
* Existing Project 1b (`Proj1b`) analysis
* D1 market analysis
* D2 stay/pivot or product-direction analysis
* D3 support-material research if already documented
* Outputs from prior prompts if available
* Any proposed Project 2 extension or market gap currently favored by the team

Do not ask us to paste information that already exists in the repository.

Use the documented project files as the authoritative source.

---

### 2. Project Constraints

Use the following development budget:

* **4 team members**
* **10 hours per person per week**
* **4 weeks**
* **160 total person-hours**

However, do **not** assume all 160 hours are available for feature implementation.

The project must also include:

* Design
* Implementation
* Integration
* Testing
* Regression testing
* Debugging
* Documentation
* Support-material review
* Final deliverables

Testing must receive a meaningful share of the budget.

When estimating scope, judge each milestone against the actual available student-team capacity, not against a professional development team or startup.

---

### 3. Milestone Realism Categories

For each proposed **Now milestone**, classify it as:

* **SAFE** — High confidence that the team can implement and verify it within the available time.
* **BOLD** — More ambitious, but still realistic if implementation goes reasonably well.
* **WILD** — High-risk because it depends on major unknowns, external services, difficult integration, unfamiliar technology, or substantial implementation effort.

A strong milestone plan should contain:

* Mostly **SAFE** milestones
* At least one meaningful **BOLD** milestone if appropriate
* A **WILD** milestone only if it has a clear fallback or kill signal

Do not propose four high-risk milestones.

---

### 4. Before Milestones

Propose **3–5 Before milestones** that clearly describe meaningful work already completed during Project 1a.

These milestones must be grounded in actual Project 1a evidence.

They should describe completed engineering capabilities rather than vague activities.

Use this table:

| # | Before Milestone | Goal                   | Project 1a Evidence                  | How It Was Checked            |
| - | ---------------- | ---------------------- | ------------------------------------ | ----------------------------- |
| 1 | [Milestone]      | [Clear completed goal] | [Use cases/code/tests/documentation] | [How completion was verified] |

Requirements:

* Use only work that is actually supported by `Proj1a`.
* Do not claim functionality was completed if the repository does not support it.
* Prefer milestones that establish the foundation for Project 2.
* Each milestone should represent a meaningful engineering accomplishment.

---

### 5. Now Milestones — Project 2

Propose **3–5 Now milestones** for Project 2.

These are the most important part of this task.

Each Now milestone must:

* Build naturally from WolfBite's current implementation.
* Support the Project 2 direction documented in Project 1b.
* Be specific and bounded.
* Represent meaningful new work.
* Be achievable within the 160 person-hour total budget.
* Include both implementation and verification.
* Avoid unnecessary rewrites of functioning Project 1a features.
* Have a clear definition of completion.

Use this exact table:

| # | Now Milestone | Goal               | SAFE / BOLD / WILD | Estimated Person-Hours | How We Build It       | How We Check It        |
| - | ------------- | ------------------ | ------------------ | ---------------------- | --------------------- | ---------------------- |
| 1 | [Milestone]   | [Specific outcome] | [Classification]   | [Estimate]             | [Implementation work] | [Testing/verification] |

For each estimate, include **all engineering work**, not just coding.

---

### 6. Person-Hour Budget

After defining the Now milestones, provide a realistic effort budget.

Use this table:

| Work Area                        | Estimated Hours |
| -------------------------------- | --------------: |
| Feature implementation           |               X |
| Integration / refactoring        |               X |
| Unit testing                     |               X |
| Integration / regression testing |               X |
| Debugging / contingency          |               X |
| Documentation / report support   |               X |
| Support-material review          |               X |
| **Total**                        |     **X / 160** |

Do not allocate the full 160 hours with no contingency.

Leave a reasonable buffer for unexpected issues.

Then state:

**Planned Hours:** X
**Contingency Remaining:** X
**Percentage of Budget Reserved for Testing:** X%

Explain briefly whether the allocation is realistic.

---

### 7. Engineering Evidence for Each Now Milestone

For each Now milestone, answer both:

**Could it be built?**
Explain why the current codebase, skills, architecture, and time make implementation achievable.

**Could it be checked?**
Explain exactly how the team would demonstrate that the milestone works.

Possible evidence may include:

* Unit tests
* Integration tests
* Regression tests
* End-to-end tests
* Manual acceptance tests
* Use-case validation
* UI verification
* Error-case testing
* Access-control testing
* Performance checks
* Accessibility checks

Use this table:

| Milestone   | Build Feasibility | Verification Method | Pass Condition           |
| ----------- | ----------------- | ------------------- | ------------------------ |
| [Milestone] | [Why buildable]   | [How tested]        | [What proves completion] |

A milestone should not be considered realistic if the team can build it but cannot reasonably verify it.

---

### 8. Risk and Kill Signals

For every **BOLD** or **WILD** milestone, define the main risk.

For every **WILD** milestone, also define a specific **kill signal** and fallback.

A kill signal should identify when the team stops pursuing the risky version and switches to a safer implementation.

Example:

> If the required API access is not available by the end of Week 2, stop external integration work and ship the tested mock/local version instead.

Use this format:

#### [Milestone Name]

**Classification:** SAFE / BOLD / WILD

**Primary risk:**
[Risk]

**Kill signal:**
[Specific measurable condition and deadline, if applicable]

**Fallback:**
[Smaller implementation that can still be completed and tested]

Do not use vague kill signals such as "if it gets too difficult."

---

### 9. Milestone Dependency Order

Identify the logical order of the Now milestones.

Use this table:

| Order | Milestone   | Depends On   | Can Be Worked in Parallel? |
| ----- | ----------- | ------------ | -------------------------- |
| 1     | [Milestone] | [Dependency] | YES / NO                   |

Then identify the likely **critical path**.

Explain which milestone would create the largest schedule problem if delayed.

---

### 10. Weekly Reality Check

Map the proposed Now milestones across the four-week development window.

Use this structure:

| Week   | Primary Work | Testing / Verification                | Decision Point                          |
| ------ | ------------ | ------------------------------------- | --------------------------------------- |
| Week 1 | [Work]       | [Tests]                               | [Decision]                              |
| Week 2 | [Work]       | [Tests]                               | [Kill signal / scope check if relevant] |
| Week 3 | [Work]       | [Tests]                               | [Decision]                              |
| Week 4 | [Work]       | [Final regression / acceptance tests] | [Scope freeze]                          |

The schedule should leave meaningful time for final testing and debugging.

Do not place all testing in Week 4.

---

### 11. Future Milestones

Propose **3–5 Future milestones** that logically extend the Project 2 work but should **not** be included in the current four-week implementation scope.

Use this table:

| # | Future Milestone | Goal   | Why It Belongs in Future | Depends on Project 2 |
| - | ---------------- | ------ | ------------------------ | -------------------- |
| 1 | [Milestone]      | [Goal] | [Reason]                 | [Dependency]         |

Future milestones should:

* Follow naturally from WolfBite.
* Build on the Now milestones.
* Represent meaningful future improvements.
* Be clearly separated from Project 2 scope.
* Avoid unrelated product ideas.

---

### 12. Support Material for D3

Identify the support material the proposed design must respect.

Review any existing support-material analysis already present in Project 1b before adding new material.

Consider:

* Regulations
* Privacy requirements
* Accessibility guidance
* Security standards
* Software licenses
* Dependency licenses
* Relevant domain guidance
* Relevant human-factors guidance

Use this table:

| Support Material | Category                                   | Source                  | Related Milestone(s) | Why It Matters | Priority                       |
| ---------------- | ------------------------------------------ | ----------------------- | -------------------- | -------------- | ------------------------------ |
| [Source]         | Regulation / Standard / License / Guidance | [Official source + URL] | [Milestone]          | [Impact]       | MUST-READ / SHOULD-READ / SKIM |

Requirements:

* Use real, findable sources.
* Prefer official or primary sources.
* Do not invent regulations, standards, licenses, or URLs.
* Do not include material merely because it is generally good software practice.
* Explain how each source actually affects WolfBite or a proposed Project 2 milestone.

---

### 13. D3 Milestone Balance

Evaluate the overall Now milestone set.

Provide:

**SAFE Milestones:** X
**BOLD Milestones:** X
**WILD Milestones:** X

Then answer:

**Is the milestone mix appropriate?**
YES / NEEDS REVISION

Explain why.

A good plan should generally be mostly SAFE, include meaningful ambition, and avoid relying on several high-risk items at once.

Remember:

> Dull milestones may lose marks, but impossible milestones lose more.

The goal is **credible ambition**.

---

### 14. Scope Cut Order

Assume the team loses approximately **25% of its expected development capacity** because of bugs, school workload, integration problems, or unexpected technical issues.

Identify what should be cut first.

Use:

**Must Keep**

* [Milestone / functionality]

**Cut First**

* [Lower-priority enhancement]

**Cut Second**

* [Additional scope]

**Never Cut**

* [Testing, critical functionality, etc.]

The reduced plan should still result in a coherent, testable Project 2 submission.

---

### 15. Recommended Final D3 Milestones

After completing the full analysis, provide the recommended milestone set in a concise format suitable for use in the team's D3 documentation.

#### Before

1. **[Milestone]** — [One-sentence clear goal]
2. **[Milestone]** — [One-sentence clear goal]
3. **[Milestone]** — [One-sentence clear goal]
4. **[Optional]**
5. **[Optional]**

#### Now

1. **[Milestone]** — [One-sentence clear and measurable goal] — **SAFE / BOLD / WILD**
2. **[Milestone]** — [Goal] — **SAFE / BOLD / WILD**
3. **[Milestone]** — [Goal] — **SAFE / BOLD / WILD**
4. **[Optional]**
5. **[Optional]**

#### Future

1. **[Milestone]** — [One-sentence clear goal]
2. **[Milestone]** — [One-sentence clear goal]
3. **[Milestone]** — [One-sentence clear goal]
4. **[Optional]**
5. **[Optional]**

Then provide the associated support-material list immediately afterward.

This section should be clean enough that the team could use it as the basis for the final D3 write-up.

---

### 16. Final Reality Assessment

Finish with:

**Overall D3 Plan:** REALISTIC / STRETCH / UNREALISTIC

**Estimated Total Person-Hours:** X / 160

**Testing Share:** X%

**Highest-Risk Milestone:** [Name]

**Most Important Kill Signal:** [Condition]

**Most Important Scope Recommendation:**
[Recommendation]

Then provide **3 concise reasons** why this milestone set is appropriate for Project 2.

---

### Important Rules

* Use the documented **Project 1a (`Proj1a`) implementation, use cases, tests, and architecture** to determine what already exists.
* Use the documented **Project 1b (`Proj1b`) analysis** to determine the current Project 2 direction.
* Do not ask us to paste milestone information if related project documentation already exists.
* If there are currently no finalized milestones, that is expected; propose them from the available project evidence.
* Propose **3–5 Before, 3–5 Now, and 3–5 Future milestones**.
* Treat **160 person-hours as the absolute total team budget**, not the coding budget.
* Reserve meaningful time for testing, debugging, documentation, and integration.
* Do not assume every team member can contribute exactly 40 productive implementation hours.
* Do not evaluate the team as though it were a professional startup.
* Prefer mostly SAFE milestones, with limited BOLD work.
* Use WILD milestones only when they have a clear kill signal and fallback.
* Every Now milestone must be both **buildable and checkable**.
* A feature that cannot be meaningfully tested within the project timeframe should not be treated as a strong milestone.
* Avoid trivial milestones created only to reduce risk.
* Avoid unrealistic milestones created only to appear ambitious.
* Do not rewrite working Project 1a functionality unless the proposed extension requires it.
* Clearly distinguish documented facts from estimates.
* Do not invent completed functionality, team skills, sources, or support material.
* Do not modify any project files.
* Keep the output organized and consistent so this analysis can be compared with outputs from other LLMs.
```

## Response

### 1. Review the Existing Project First

The repository supports continuing WolfBite rather than rebuilding it. The 20
finalized use cases cover accounts, barcode/manual UPC lookup, nutrition and
alternative review, basket and benefit estimates, receipt import, QR handoff,
and session completion. The implementation already provides Flutter screens,
GoRouter navigation, Firebase Authentication, Firestore-backed AppState and
AplService components, Provider state, scanning, and a substantial test harness.

Project 1a also establishes the constraints. Its 86-test team suite recorded 82
passes and four retained failures, with 77.5% executable-line coverage but much
weaker exception- and persistence-path coverage. Dependency resolution is not
reproducible because the application lockfile is ignored; a resolved
cloud_firestore/fake_cloud_firestore mismatch has blocked inherited tests. The
code can present ineligible/missing-status APL records, treat missing nutrition
as zero, silently diverge after persistence failure, upload a full receipt to
OCR.space, and display a QR handoff that no retailer integration is known to
accept.

Project 1b favors a narrower, defensible extension: for fixed synthetic cases
where the app appears to approve an item and checkout rejects it, show
evidence-bounded likely causes and safe recovery actions. M0 compares that flow
with a baseline that shows the same mocked rejection but no explanation. A
trial succeeds when a test user selects the prepared reference action within 60
seconds without help; the targets are at least 80% success and at least a
20-percentage-point improvement, to be measured rather than assumed.

The plan below therefore reuses UPC entry, product display, routing, Flutter
widgets, and team test skills while avoiding live WIC, benefit, EBT, POS,
payment, or receipt dependencies.

### 2. Project Constraints

- **Team:** Four students.
- **Time:** Four weeks at approximately 10 hours per person per week.
- **Gross capacity:** 160 person-hours.
- **Demonstrated skills:** Dart/Flutter testing, widget/state tests, Mockito,
  fake Firestore, requirements traceability, coverage analysis, Git/PR work,
  evidence review, and ACM LaTeX reporting.
- **Unverified skills/capacity:** Production Firebase/security administration,
  accessible mobile implementation, WIC/EBT integration, professional
  nutrition/regulatory work, representative-user recruitment, and each
  member's exact weekly availability.

The budget must pay for design, implementation, test creation, integration,
regression, debugging, M0 execution, analysis, support-material checks, and
report/poster evidence. For that reason, only 132 hours are planned and 28 are
left unallocated as schedule reserve.

### 3. Milestone Realism Categories

This plan uses three **SAFE**, two **BOLD**, and zero **WILD** Now milestones.
SAFE does not mean effortless; it means the deliverable uses known tools and
has a bounded verification method. BOLD milestones—the integrated accessible
workflow and comparative M0 study—remain credible because each has a dated
scope check and a mock/local fallback. No current milestone depends on access
to a state agency, retailer, EBT processor, OCR provider, or production data.

### 4. Before Milestones

| # | Before Milestone | Goal | Project 1a Evidence | How It Was Checked |
|---:|---|---|---|---|
| 1 | Reconstruct the inherited product as 20 traceable use cases | Establish an authoritative description of what WolfBite actually does, including normal, extension, and failure behavior. | Project1a_Work/use_cases/usecases_final.md documents UC1–UC20 and maps them to production code. | Review against routes, screens, AppState, AplService, utilities, and widgets; every finalized use case has production-evidence locations. |
| 2 | Establish a runnable inherited baseline | Demonstrate that the inherited Flutter/Firebase product can resolve dependencies, produce a release web build, and serve the sign-in experience while documenting failures rather than repairing them silently. | Project1a_Work/baseline.md records the tested commit, Flutter/Dart versions, commands, release-web build, local run, and broad-suite dependency failure. | flutter pub get and flutter build web --release passed; the app served locally; the failing broad test run and cause were recorded. |
| 3 | Build and execute team tests spanning all 20 use cases | Create active test evidence for every finalized use case and retain failures that expose requirement/application mismatches. | Four files under Project3/test/project1a plus the active gap-test file; project1a_team_suite_test_results_2026-09-01.md. | 86 tests executed: 82 passed and four retained failures were named and explained, including error-handling and false-success behavior. |
| 4 | Measure coverage and close high-value state/persistence gaps | Quantify what the tests cover and add meaningful tests where use-case state transitions or persistence lacked evidence. | Coverage report, traceability tables, active-suite curation, and 11 added coverage-gap tests. | All 11 new gap tests passed; executable-line coverage reached 77.5%; scenario audits separately identified exception, persistence, and state-transition gaps. |

### 5. Now Milestones — Project 2

The estimates below include design, coding, tests, debugging, review, and
milestone documentation. Together they total 132 hours.

| # | Now Milestone | Goal | SAFE / BOLD / WILD | Estimated Person-Hours | How We Build It | How We Check It |
|---:|---|---|---|---:|---|---|
| 1 | Stabilize the baseline and freeze the mismatch contract | Produce a reproducible development/test baseline and at least four versioned, evidence-backed synthetic NC mismatch scenarios with complete expected outcomes. | SAFE | 22 | Pin a compatible application dependency resolution; rerun/document the build and team suite without erasing known failures; define a fixture schema containing exact UPC/package, app evidence, mocked benefit evidence, checkout result, source/date, likely cause, limitation, and reference action. | Lockfile/build checks; existing-suite baseline; fixture-schema validation; source/requirement traceability review; every fixture has an explicit safe answer and uncertainty boundary. |
| 2 | Implement the deterministic explanation-and-recovery service | Convert the frozen evidence combinations into repeatable possible-cause and next-action results without claiming authorization, certainty, or override. | SAFE | 26 | Add a pure Dart model/service isolated from Firebase and POS systems; encode the bounded rules; return cause, explanation, source/freshness, limitations, and one or two safe actions; provide an unknown/conflict fallback. | Table-driven unit tests cover every fixture, each rule boundary, stale/missing/conflicting evidence, invalid input, repeatability, and negative assertions against guarantees or register overrides. |
| 3 | Integrate one accessible recovery workflow | Let a shopper enter the mocked checkout-rejection path from existing product identification and understand a likely cause and next step without depending on camera, color, QR, or memory. | BOLD | 36 | Reuse the scan/manual UPC result and router; add one bounded recovery route/view; connect the deterministic service; display item/package, evidence source/date, uncertainty, cause, actions, back/dismiss, and consistent agency help; avoid new account/benefit persistence. | Widget/navigation tests across all fixtures and loading/error/unknown states; manual and automated checks for semantics, focus, contrast, 200% text scaling, targets, non-color status, plain language, manual UPC input, and text output. |
| 4 | Produce reproducible integration, regression, and accessibility evidence | Demonstrate that the new service and workflow work together without adding regressions to the documented Project 1a baseline. | SAFE | 26 | Maintain a targeted integration suite; fix feature defects; document any inherited known failures separately; confirm no new Firestore schema, receipt upload, card/PIN, or external transaction path was introduced; assemble the verification record. | All new unit/widget/integration tests pass; every previously passing team test remains passing; known failures are fixed or explicitly retained with disposition; build succeeds; accessibility and manual acceptance checklists have evidence for every scenario. |
| 5 | Run and report the M0 baseline-versus-recovery evaluation | Measure whether users select the prepared reference action within 60 seconds and whether the recovery flow reaches the 80% and 20-point targets without presenting targets as results. | BOLD | 22 | Finalize a short same-fixture, counterbalanced protocol; recruit at least eight consented test users while seeking target-user relevance where feasible; pilot once; run baseline and treatment trials; record only necessary, de-identified task outcome/time/help and concise burden notes; calculate results and limitations. | Protocol and scoring review; at least eight completed sessions using identical scenarios across conditions; reproducible success/time calculations; raw de-identified evidence retained; result states whether each threshold was met, not assumed. |

### 6. Person-Hour Budget

| Work Area | Estimated Hours |
|---|---:|
| Feature implementation | 36 |
| Integration / refactoring | 16 |
| Unit testing | 16 |
| Integration / regression testing | 28 |
| Debugging / contingency | 12 |
| Documentation / report support | 16 |
| Support-material review | 8 |
| **Total** | **132 / 160** |

**Planned Hours:** 132  
**Contingency Remaining:** 28  
**Percentage of Budget Reserved for Testing:** 27.5% of the full budget
(44/160), or 33.3% of planned hours (44/132)

The 44 testing hours include unit, widget, integration, regression,
accessibility, and M0 user-flow work. The separate 12 debugging hours absorb
normal test findings; the 28-hour unallocated reserve protects against team
availability and dependency/integration surprises. This is credible but not
loose: the two BOLD milestones need their Week 1–2 scope decisions.

### 7. Engineering Evidence for Each Now Milestone

| Milestone | Build Feasibility | Verification Method | Pass Condition |
|---|---|---|---|
| M1. Baseline and mismatch contract | The team already ran the build/test workflow, diagnosed the dependency mismatch, wrote detailed use cases, and completed the relevant support-material review. Synthetic fixtures require no partner or new backend. | Clean dependency/build check, rerun of the selected 86-test suite, schema tests, and manual traceability review against NC/federal sources and D2 requirements. | A fresh checkout resolves the same versions, builds, reproduces or improves the documented baseline with no unexplained change, and validates at least four complete fixtures with reference actions. |
| M2. Deterministic recovery service | AplService and team-authored Dart tests provide familiar patterns, while a pure service avoids Firestore, asynchronous UI, and external interfaces. | Table-driven unit tests, decision/rule coverage, negative tests, invalid/unknown/conflict cases, and repeatability checks. | All agreed engine tests pass; every fixture maps to its reference result; unknown evidence yields an honest fallback; no result promises acceptance, diagnosis, or override. |
| M3. Accessible recovery workflow | Existing manual/barcode input, product display, router, state provider, and widget-test harness can be reused. Only one synthetic rejection flow is added. | Widget and navigation tests, test-text scaling, semantics inspection, contrast/target review, manual keyboard/switch-equivalent path, and scenario acceptance walkthroughs. | Every fixture can be completed using manual input and text output; expected cause/actions/source are readable; all automated tests pass; the selected WCAG 2.2 AA checklist has no unresolved blocker. |
| M4. Reproducible verification evidence | Project 1a already provides suite commands, raw-output conventions, traceability tables, and known-failure reporting. | Run new suites and prior team suite from a documented environment; compare baseline; verify build; review data flow and acceptance checklist; preserve raw results. | No new unexplained regression; all new tests pass; all previously passing tests remain passing; known failures have explicit disposition; evidence can be rerun from repository instructions. |
| M5. M0 comparative evaluation | D2 already defines the baseline, treatment, success event, time limit, and thresholds. Fixed scenarios keep sessions short and avoid live data. | Pilot protocol, counterbalanced baseline/treatment sessions, task-success/time scoring, facilitator-help record, de-identified notes, calculation review, and limitations statement. | At least eight complete sessions are analyzed consistently; success rate and percentage-point difference are reported; threshold misses remain reported as misses; evidence is sufficient to reproduce the calculation. |

Each milestone is both buildable and checkable. M3 and M5 are BOLD because
integration/accessibility and recruitment/study execution involve more
uncertainty than pure local Dart work—not because their verification is vague.

### 8. Risk and Kill Signals

#### M3 — Integrate one accessible recovery workflow

**Classification:** BOLD

**Primary risk:**
The inherited scan/router/state code is coupled to asynchronous Firebase and
camera behavior, while accessibility and text scaling can reveal late layout
or focus failures. Trying to integrate basket, receipt, and QR flows as well
would consume the testing budget.

**Kill signal:**
If a local two-fixture vertical slice cannot navigate from an existing
manual-product result to a readable recovery result and pass its core widget
and semantics tests by the end of Week 2, stop deeper scan/basket integration.

**Fallback:**
Ship a dedicated, tested recovery route launched from a local scenario/manual
UPC selector. It still demonstrates the decision service, uncertainty,
source/freshness, next actions, and accessibility without touching receipt,
basket, or Firestore state.

#### M5 — Run and report the M0 evaluation

**Classification:** BOLD

**Primary risk:**
Access to representative WIC caregivers and each participant's schedule are not
established. Late recruitment would compress pilot correction and analysis.

**Kill signal:**
If fewer than six participants are confirmed by the end of Week 1, stop
promising a target-population result and activate the exploratory-study plan.
If the treatment build is not frozen by the middle of Week 3, stop adding UI
features and test the dedicated fallback flow.

**Fallback:**
Run a smaller, clearly labeled convenience-sample pilot with the same
counterbalanced scenarios and calculations. Report feasibility/usability
evidence and sampling limitations; do not claim population-level effectiveness.

There is no WILD Now milestone. Any proposal requiring live APL/benefit/POS
access, authoritative reason codes, payments, or production receipt OCR would
be WILD and is placed in Future instead.

### 9. Milestone Dependency Order

| Order | Milestone | Depends On | Can Be Worked in Parallel? |
|---:|---|---|---|
| 1 | M1. Baseline and mismatch contract | Completed Project 1a evidence, D2 decision, and support-material register | YES — one pair can stabilize dependencies while another finalizes fixtures/protocol fields. |
| 2 | M2. Deterministic recovery service | Frozen M1 fixture/decision contract | PARTLY — engine scaffolding can start, but rules/tests cannot finish against a moving contract. |
| 3 | M3. Accessible recovery workflow | Stable M1 model and a usable M2 service interface | YES — the view shell and accessibility test harness can start while M2 rules finish. |
| 4 | M4. Reproducible verification evidence | M1 baseline; completed M2/M3 behavior for final integration | YES — regression and checklist work starts early; final evidence waits for M2/M3. |
| 5 | M5. M0 comparative evaluation | M1 scenarios/protocol and frozen M3 treatment; M4 smoke/regression readiness | YES — recruitment and protocol pilot start in Week 1, but final trials wait for the frozen build. |

**Critical path:** M1 contract → M2 service → M3 vertical slice → M4 release
gate → M5 final sessions. M1 is the dependency fan-out point, but M3 creates
the largest schedule damage if delayed because it blocks the treatment build,
final integration evidence, and M0. Recruitment/protocol work for M5 must run
alongside the technical path rather than wait until Week 4.

### 10. Weekly Reality Check

| Week | Primary Work | Testing / Verification | Decision Point |
|---|---|---|---|
| Week 1 | M1 dependency baseline and fixture contract; M5 protocol draft and recruitment; M2 model skeleton | Resolve/build check, rerun team baseline, validate fixture schema and reference actions, review protocol/scoring | Freeze at least four scenarios and the data/decision contract. If fewer than six participants are confirmed, label M0 exploratory and use the fallback sample plan. |
| Week 2 | Complete M2 rule service; build M3 recovery-route vertical slice; continue M5 scheduling | Run rule/negative/unknown tests continuously; add first widget/navigation/semantics/text-scaling checks | By end of week, require a two-fixture local vertical slice. If absent, stop deeper integration and use the dedicated recovery-route fallback. |
| Week 3 | Finish the bounded M3 workflow; execute M4 integration/accessibility passes; pilot M5 once | All-fixture widget/error tests, manual accessibility checks, targeted regression, pilot scoring and protocol correction | Freeze scenario count and core UI by midweek. Cut polish and optional integration before cutting verification. |
| Week 4 | M4 final regression/evidence; M5 sessions, analysis, and report/poster material; defect-only changes | Full documented build/test run, final acceptance/accessibility checklist, counterbalanced M0 trials, calculation review | Scope freezes at the start of Week 4 except verified defect fixes. Report targets as met/not met; do not add live integration or new scenarios. |

Testing begins in Week 1 and occurs inside every milestone. Week 4 contains the
final run and user evaluation, not the first attempt to test the system.

### 11. Future Milestones

| # | Future Milestone | Goal | Why It Belongs in Future | Depends on Project 2 |
|---:|---|---|---|---|
| 1 | Permissioned, versioned state APL synchronization | Replace static fixtures with a monitored adapter that records jurisdiction, version, refresh time, conflicts, and stale state. | Requires NCDHHS/data-owner permission, operational refresh ownership, redistribution decisions, and failure monitoring beyond four weeks. | M1 provenance/fixture contract and evidence-layer separation |
| 2 | Partner-backed read-only benefit and rejection-evidence pilot | Test recovery using authorized participant/transaction evidence without letting WolfBite approve, pay, or mutate benefits. | Requires a WIC agency, retailer/processor partner, interface access, confidentiality/security agreements, and domain validation. | M2 bounded decision contract, M3 recovery UX, and positive M0 evidence |
| 3 | Privacy-reviewed on-device receipt recognition and reconciliation | Recognize item/quantity evidence locally where supported and reconcile it with basket/benefit evidence while preserving manual fallback. | Receipt formats, OCR accuracy, quantities/duplicates, device support, and privacy testing are a separate large problem; the inherited full-image cloud upload should not be the production basis. | M2 evidence model and M3 manual/error recovery patterns |
| 4 | Spanish and broader accessibility validation | Deliver professionally reviewed Spanish content and validate the workflow across disability, literacy, language, and device/network contexts. | Requires translation/cultural expertise and broader participant recruitment; unreviewed machine translation is not a sufficient milestone. | Stable M3 content architecture and M5 study protocol/results |
| 5 | Production hardening and operational release | Establish access-control testing, incident response, monitoring, backups, data retention/deletion, dependency/asset licensing, security review, and deployment-specific compliance. | Production operations and public-agency deployment exceed the student prototype and require an accountable operator. | Stable product scope, partner/deployment decision, and all validated Project 2 evidence |

### 12. Support Material for D3

The detailed working register is in
Project1b_Work/analysis/support_material.md. The following are the sources that
directly create requirements or scope boundaries for these milestones.

| Support Material | Category | Source | Related Milestone(s) | Why It Matters | Priority |
|---|---|---|---|---|---|
| 7 CFR §246.10, especially §246.10(b) and (e)(12) | Regulation | [eCFR](https://www.ecfr.gov/current/title-7/subtitle-B/chapter-II/subchapter-A/part-246/section-246.10) and [USDA FNS summary](https://www.fns.usda.gov/wic/food-packages/regulatory-requirements) | M1–M3 | Federal criteria do not guarantee state authorization or participant-specific purchase eligibility; source, jurisdiction, item/package, and uncertainty must remain visible. | MUST-READ |
| NC WIC Authorized Product List and Vendor Manual | Domain guidance | [NCDHHS APL](https://www.ncdhhs.gov/divisions/child-and-family-well-being/community-nutrition-services-section/wic/vendors/nc-wic-authorized-product-list-apl) and [Vendor Manual](https://www.ncdhhs.gov/wic-vendor-manual-0) | M1–M3 | Supplies the NC scenario vocabulary: current/stale APL, remaining benefit/quantity, no override, and safe escalation. | MUST-READ |
| WIC EBT Technical Implementation Guide and Operating Rules | Standard/domain guidance | [USDA FNS](https://www.fns.usda.gov/wic/ebt/technical-implementation-guide-operating-rules) | M1–M3; Future 2 | Defines the external transaction ecosystem and supports keeping mock evidence separate from authoritative EBT/POS messages. | SHOULD-READ |
| FTC mobile-app marketing, privacy, and security guidance | Consumer/privacy guidance | [FTC marketing guidance](https://www.ftc.gov/business-guidance/resources/marketing-your-mobile-app-get-it-right-start) and [security guidance](https://search.ftc.gov/business-guidance/resources/app-developers-start-security) | M2–M5 | Requires supportable claims, transparent collection/sharing, data minimization, secure handling, and third-party review. | MUST-READ |
| WCAG 2.2 Level AA | Accessibility standard/design target | [W3C](https://www.w3.org/TR/WCAG22/) | M3–M5 | Creates testable requirements for non-color meaning, contrast, text, focus, targets, errors, help, and accessible interactions. | MUST-READ |
| WCAG2ICT 2.2 and W3C COGA Content Usable | Accessibility/human-factors guidance | [WCAG2ICT](https://www.w3.org/TR/wcag2ict-22/) and [COGA](https://www.w3.org/TR/coga-usable/) | M3–M5 | Helps apply WCAG to Flutter/native content and supports plain language, low memory burden, error recovery, and consistent help. | SHOULD-READ |
| OWASP Mobile Application Security Verification Standard | Security standard | [OWASP MASVS](https://mas.owasp.org/MASVS/) | M1, M3–M4 | Guides checks for storage, authentication, network traffic, platform permissions, third-party flows, logging, and privacy. | MUST-READ |
| Firebase Security Rules and service/data terms | Security/service guidance | [Rules and Authentication](https://firebase.google.com/docs/rules/rules-and-auth), [terms](https://firebase.google.com/terms), and [data terms](https://firebase.google.com/terms/data-processing-terms) | M1, M3–M4; Future 5 | Security Rules—not bundled client configuration—control data access; the operator retains configuration, processing, retention, and backup responsibilities. | SHOULD-READ |
| Inherited WolfBite MIT License | Software license | Project3/LICENSE.md and [upstream](https://github.com/SuyeshJadhav/CSC510_G19/blob/main/Project2/LICENSE.md) | M1–M4 | Redistributed substantial code must retain the inherited copyright and MIT permission/warranty notice. | MUST-READ |
| Direct and transitive package licenses | Dependency licenses | Project3/pubspec.yaml, generated notices, and official package license pages | M1 and M4 | Exact resolved versions and applicable MIT/BSD/Apache notices must be reproducible and retained; dependency changes need renewed review. | SHOULD-READ |
| OCR.space API documentation and privacy policy | API/privacy guidance | [API](https://ocr.space/ocrapi) and [privacy policy](https://ocr.space/privacypolicy) | M1 scope boundary; Future 3 | The inherited path uploads a complete receipt; service/privacy risk is why receipt OCR is excluded from the Project 2 critical path. | MUST-READ |
| ISO 9241-210:2019 | Human-centered design standard | [ISO](https://www.iso.org/standard/77520.html) | M3 and M5 | Requires attention to real context of use, iterative design, representative users, and observed task outcomes rather than aesthetic preference alone. | SHOULD-READ |
| Weber et al. (2021), desired WIC mobile-app features | Primary user research | [JMIR](https://formative.jmir.org/2021/7/e30450/) | M3 and M5 | Supports scanning/balance relevance while emphasizing ease, multilingual readiness, and device/performance burden. | MUST-READ |
| Chauvenet et al. (2019), WIC retail experience | Primary user research | [PubMed](https://pubmed.ncbi.nlm.nih.gov/30502034/) | M1, M3, M5 | Documents allowable-item difficulty and checkout stigma, making speed, privacy, and neutral language core requirements. | MUST-READ |

HIPAA, COPPA, Section 508, PCI DSS, ISO/IEC 27001, and NIST AI RMF are not
current blanket requirements for this bounded prototype. The support-material
register records the deployment or feature changes that would trigger a new
applicability review.

### 13. D3 Milestone Balance

**SAFE Milestones:** 3  
**BOLD Milestones:** 2  
**WILD Milestones:** 0

**Is the milestone mix appropriate?**  
**YES.** Three SAFE milestones protect the foundation, core deterministic
logic, and repeatable engineering evidence. Two BOLD milestones provide
credible ambition through a real integrated user flow and comparative
evaluation. Neither depends on an unavailable external partner, and each has a
bounded fallback. Adding a WILD live-integration milestone would endanger the
entire evidence path without being necessary to demonstrate value.

### 14. Scope Cut Order

A 25% capacity loss leaves approximately 120 person-hours. Because the planned
set uses 132, the team must remove at least 12 hours while preserving a coherent
result.

**Must Keep**

- M1's reproducible baseline and four-scenario evidence contract.
- M2's deterministic engine and negative/unknown-case tests.
- A usable version of M3 with uncertainty, source/freshness, next actions,
  manual access, and core accessibility.
- M4's no-new-regression release gate and reproducible evidence.
- M5's same-scenario comparison and honest calculation, even if exploratory.

**Cut First**

- Remove deeper integration with inherited scan/basket state and ship the
  dedicated local-fixture/manual-UPC recovery route defined by M3's fallback.
  Cut transition polish, extra icons, and optional source-detail layers while
  retaining plain text and the evidence date. Target savings: 8 hours.

**Cut Second**

- Keep four scenarios only; remove any fifth scenario, export/report automation,
  saved recovery examples, and localization scaffolding. If recruitment is the
  constraint, reduce the M0 minimum from eight to six completed participants
  and label it an exploratory pilot. Target savings: at least 4–8 hours.

**Never Cut**

- Tests for every decision rule, unknown/conflicting inputs, and the integrated
  four-scenario path.
- The manual non-camera path, non-color meaning, readable/scalable text,
  uncertainty/source labeling, and safe fallback action.
- Regression comparison with Project 1a and truthful preservation/disposition
  of known failures.
- The baseline-versus-treatment measurement or honest reporting of misses and
  sample limitations.

The reduced plan remains meaningful: it ships and evaluates the new recovery
decision and interface, but with a shallower connection to inherited state and
fewer presentation/research extras.

### 15. Recommended Final D3 Milestones

#### Before

1. **Document the inherited product as 20 traceable use cases** — Finalize
   UC1–UC20 with normal, extension, and failure behavior mapped to production
   evidence.
2. **Establish a runnable WolfBite baseline** — Resolve dependencies, build the
   release web application, serve the sign-in flow, and preserve the broad-test
   failure evidence without silently repairing inherited code.
3. **Build and execute tests across all 20 use cases** — Run the 86-test
   team-authored suite, recording 82 passes and four retained
   application/requirement mismatches.
4. **Measure coverage and close high-value gaps** — Reach 77.5% executable-line
   coverage, add 11 passing state/persistence gap tests, and document remaining
   exception, persistence, and transition risks.

#### Now

1. **Stabilize the baseline and freeze the mismatch contract** — Pin a
   reproducible dependency/build/test baseline and validate at least four
   versioned, evidence-backed NC mismatch fixtures with reference actions —
   **SAFE**.
2. **Implement the deterministic explanation-and-recovery service** — Pass a
   table-driven suite for every scenario, boundary, stale/missing/conflicting
   input, and safe unknown fallback without claiming authorization or override
   — **SAFE**.
3. **Integrate one accessible recovery workflow** — Complete every synthetic
   mismatch path through a tested Flutter view that shows item, source/date,
   uncertainty, possible cause, and next actions with manual/non-color access —
   **BOLD**.
4. **Produce reproducible integration and regression evidence** — Make every
   new test pass, retain every previously passing Project 1a test, build
   successfully, and complete the scenario/accessibility acceptance record —
   **SAFE**.
5. **Run and report the M0 comparison** — Complete at least eight
   counterbalanced baseline-versus-recovery sessions, measure correct reference
   action within 60 seconds, calculate the 80% and 20-point targets, and report
   limitations honestly — **BOLD**.

#### Future

1. **Add permissioned, versioned APL synchronization** — Maintain monitored
   jurisdiction/source/freshness data only after resolving state-data rights
   and operational ownership.
2. **Pilot read-only official benefit and rejection evidence** — Work with an
   agency/retailer/processor partner without giving WolfBite transaction or
   override authority.
3. **Add privacy-reviewed on-device receipt reconciliation** — Recognize
   receipt items/quantities locally where possible while preserving manual
   fallback and testing device/format variability.
4. **Expand language and accessibility validation** — Add professionally
   reviewed Spanish content and broader testing across disability, literacy,
   language, device, and network contexts.
5. **Prepare a production operational release** — Establish security,
   monitoring, backups, incident response, retention/deletion, licensing, and
   deployment-specific compliance under an accountable owner.

**Associated support material:**

- 7 CFR §246.10 and USDA food-package guidance.
- NC WIC Authorized Product List and Vendor Manual.
- USDA WIC EBT Technical Implementation Guide and Operating Rules.
- FTC mobile-app marketing, privacy, and security guidance.
- WCAG 2.2 Level AA, WCAG2ICT, and W3C COGA guidance.
- OWASP MASVS plus Firebase Security Rules and service/data terms.
- The inherited MIT license and resolved dependency licenses/notices.
- OCR.space API/privacy terms as a reason to defer the inherited receipt path.
- ISO 9241-210 human-centered design guidance.
- Weber et al. (2021) and Chauvenet et al. (2019) WIC participant research.

### 16. Final Reality Assessment

**Overall D3 Plan:** REALISTIC

**Estimated Total Person-Hours:** 132 / 160

**Testing Share:** 27.5% of the full budget; 33.3% of planned hours

**Highest-Risk Milestone:**
M3 — Integrate one accessible recovery workflow. It is the largest technical
milestone and lies directly on the path to final regression evidence and M0.

**Most Important Kill Signal:**
If a two-fixture local vertical slice cannot navigate from manual product input
to a readable recovery result and pass core widget/semantics tests by the end
of Week 2, stop deeper inherited-state integration and use the dedicated local
recovery-route fallback.

**Why the plan is achievable:**
It reuses WolfBite's Flutter navigation, product lookup/manual input, UI and
test infrastructure; keeps the new decision engine deterministic and locally
testable; uses synthetic evidence; starts testing/recruitment early; and leaves
28 hours outside the planned work.

**What must remain out of scope:**
Live APL, participant-benefit, EBT, retailer/POS, payment, card/PIN, balance
mutation, authoritative rejection diagnosis, cloud receipt processing,
multi-state rules, production deployment, and predictive/LLM decisions.

**Fallback Plan:**
Ship a dedicated accessible recovery route over the four tested local fixtures,
with the deterministic engine, source/freshness and uncertainty labels, safe
next actions, complete rule/widget/regression evidence, and a smaller clearly
labeled exploratory baseline comparison. This still demonstrates and checks
the Project 2 value proposition without risky integration.
