# Requirements decisions

## Stay or pivot

- **Decision:** CONTINUE developing WolfBite rather than pivot to a different
  product.
- **Evidence supporting the decision:**
  - Project 1a produced 20 code-traceable use cases and a team-authored suite
    of 86 tests, establishing a reusable behavioral and testing baseline for
    the inherited Flutter/Firebase application.
  - WolfBite already provides product identification, nutrition information,
    alternatives, basket and simulated-benefit management, receipt import, and
    a QR-based checkout handoff. Continuing preserves that implementation and
    the team's demonstrated knowledge of its behavior and failure paths.
  - The D1 competitor audit found a medium-confidence opportunity for an
    integrated, item-level explanation-and-recovery workflow when an app's
    eligibility indication conflicts with a checkout rejection.
  - Codex, Gemini, and local Ollama recommended continuing because a pivot
    would discard the existing implementation, test infrastructure, and WIC
    domain evidence under the one-month constraint.
- **Evidence against the decision:**
  - Terra recommended pivoting to a use-case-to-regression-test CLI, arguing
    that it better matches the team's demonstrated testing skills and avoids
    WIC, privacy, checkout, OCR, and government-integration risks.
  - Existing rivals already provide combinations of barcode scanning, benefit
    balances, food guidance, and purchase or transaction history. Public
    documentation may also omit program-specific recovery features, so the
    selected gap is plausible but not conclusively proven.
  - The team has no verified access to live WIC, EBT, retailer, or
    point-of-sale data and no demonstrated professional nutrition or regulatory
    expertise.
- **Team adjudication:** Continue with WolfBite, use the inherited application
  as the foundation for version i+1, retain the finalized Now milestones, and
  keep benefit and checkout scenarios simulated. Do not present LLM advice as
  unanimous or claim authoritative eligibility or checkout information.

## Mission statement

- **Why:** WIC participants and caregivers can face uncertainty and added
  friction when an item appears eligible in an app but is rejected at checkout.
- **What:** Extend WolfBite with an item-level explanation-and-recovery workflow
  that relates the rejected item's UPC and package details to the available
  benefit, eligibility, and purchase evidence. For bounded mocked scenarios,
  show rule-based possible causes, evidence limits, and actionable next steps.
- **So what / M0 claim:** During Project 2 M0, compare the checkout-help
  workflow with a baseline that shows the same eligibility result and mocked
  rejection but provides no explanation or recovery guidance. A trial succeeds
  when a test user selects the scenario's reference next step within 60 seconds
  without facilitator help. The targets are at least 80% task success and at
  least a 20-percentage-point improvement over baseline. These are targets to
  measure, not achieved results.

## Stakeholders

The following groups consolidate the overlapping roles in the four saved
Prompt 5 outputs and the D2 stakeholder table.

| Stakeholder | Need or fear | Design response | Evidence |
|---|---|---|---|
| WIC participants, caregivers, and household representatives | Misleading guidance, uncertainty after a rejection, or use of the wrong household state | Identify the active household context; show evidence limits, possible causes, and a short next action | D2 mission and stakeholder table; participant research |
| Infants, children, and pregnant or postpartum benefit recipients | Eligibility or nutrition guidance could be mistaken for health advice | Separate coverage information from health claims and represent missing information as unknown | Prompt 5 overlap; Project 1a nutrition findings |
| WIC clinic staff, program administrators, and agencies | Extra support burden or a prototype mistaken for official WIC authority | Show source and freshness and route unresolved cases to appropriate agency help | Prompt 5 overlap; WIC support material |
| Cashiers, authorized retailers, and store managers | Checkout delay, disputes, or incorrect UPC/package information | Treat the register result as authoritative, keep guidance concise, and make no payment or POS-integration claim | Prompt 5 overlap; D1 gap analysis |
| State WIC IT teams, EBT processors, and card-system vendors | Unsupported integrations, security risks, or simulated data presented as official | Use mock adapters and simulated data; make no live balance, payment, or transaction claim | Prompt 5 overlap; WIC EBT guidance |
| Approved-product-list stewards, manufacturers, and product-data providers | Stale, conflicting, or misattributed UPC, package, and category records | Retain source/version provenance and test stale, duplicate, and conflicting records | Prompt 5 overlap; NC APL guidance |
| Privacy, security, and legal reviewers | Exposure of household, benefit, receipt, location, or diagnostic data | Minimize stored data, exclude card credentials, use privacy-safe logs, and state prototype limits | Prompt 5 overlap; FTC, NIST, and OWASP guidance |
| Program regulators and compliance personnel | Misrepresented eligibility, unnecessary data collection, or exclusion | Trace claims to sources and test privacy, accessibility, and nondiscrimination requirements | Prompt 5 overlap; regulatory support material |
| Participants with disabilities or limited English proficiency, and their advocates | Camera-only controls, color-only status, small targets, or unclear language | Preserve manual entry, pair color/icons with text, use semantic labels and plain language, and test scaling and assistive navigation | Prompt 5 overlap; WCAG 2.2 guidance |
| Receipt OCR and other outside data-service providers | Sensitive uploads, unsupported formats, or use outside service terms | Keep OCR outside the core recovery path; if retained, require disclosure, minimization, validation, and a mock/manual fallback | Prompt 5 overlap; OCR.space review |
| Application developers and maintainers | Unreproducible failures, sensitive logs, and one-month scope growth | Use bounded deterministic rules, versioned fixtures, reproducible dependencies, and privacy-safe diagnostics | Project 1a baseline; milestone analysis |
| Project sponsors, funders, and procurement decision-makers | Unsupported benefit claims, hidden integration costs, or an unmaintainable prototype | Define a narrow pilot, measurable outcomes, and explicit external dependencies | Prompt 5 overlap; feasibility analysis |

## Milestones

### Before -- Project 1a

1. **Set up and analyze the inherited WolfBite application.** The team cloned,
   ran, and inspected the existing Flutter/Firebase project so later decisions
   were based on implemented behavior rather than the product description.
2. **Map the documented behavior to the implementation.** The team finalized
   20 code-traceable use cases and connected their primary, alternative, and
   exception paths to production code.
3. **Create and execute automated use-case tests.** The team authored 86 tests
   spanning UC1--UC20; the recorded run had 82 passes and four retained
   failures that became evidence for the next version.
4. **Document traceability, failures, and coverage.** The Project 1a report and
   supporting records preserve the test results, failure classifications, and
   77.5% executable-line coverage baseline.

### Now -- one-month build and test

Prompt 10 did not justify a pivot, but Codex, Terra, and Gemini independently
identified a scope and dependency risk. The team therefore preserves the five
agreed milestones while making M4 and M0 the critical path. M1--M3 are bounded
supporting improvements and may not consume the time reserved for integration,
regression testing, or the M0 evaluation.

1. **M0 — Check whether checkout help is useful.**
   - **Build and purpose:** Create a reproducible baseline-versus-help protocol
     and scoring script using the same synthetic mismatch scenarios. This was
     selected because D1 supports the underlying checkout problem but P10
     correctly notes that demand for this particular recovery workflow remains
     unproven.
   - **Feasibility and completion:** The comparison uses existing screens,
     fixed fixtures, and no live WIC/POS integration. It is complete when the
     scoring script passes known-answer tests and the team reports task success,
     time, facilitator help, and the percentage-point difference against the
     80% and 20-point targets without presenting targets as achieved results.
   - **Risk protection:** Define the baseline, acceptable next actions, trial
     count, and handling of multiple reasonable actions before collecting data.
     Synthetic logs validate the script, not user demand.

2. **M1 — Better nutrition information and food-choice explainers.**
   - **Build and purpose:** Extend the existing nutrition panel and utilities
     with units, serving/reference amounts, short explanations, and visible
     tradeoffs. Project 1a found misleading missing-data behavior, so this is a
     product-correctness improvement rather than a new verified market gap.
   - **Feasibility and completion:** Reuse the current product records and limit
     work to sodium, sugar, fiber, protein, and fat values already available.
     It is complete when unit/widget tests verify displayed values, comparable
     measurement bases, persistence, and that unknown values never receive a
     favorable badge or comparison.
   - **Risk protection:** Do not add a live nutrition service or personalized
     health advice. This milestone remains secondary to the M4/M0 path.

3. **M2 — Basket-wide suggestions for more balanced food choices.**
   - **Build and purpose:** Add optional basket-aware, one-swap previews that
     reuse the basket, alternatives, M1 measurements, and simulated allowances.
     This improves the inherited product, but P10 and the market audit show it
     is not the evidence-backed core gap.
   - **Feasibility and completion:** Restrict the feature to a small mock
     catalog, known compatible units/package amounts, and at most three
     suggestions. It is complete when tests cover basket-dependent ranking,
     quantity effects, unchanged previews, confirmed swaps, recalculation,
     missing data, balance consistency, and no-candidate cases.
   - **Risk protection:** Expand integration only after M1's measurement rules
     are stable and the M4-to-M0 fixtures, interface, and evaluation protocol
     are defined. Defer extra targets, multi-item optimization, and visual
     polish if the critical path slips.

4. **M3 — A clearer, more complete shopping interface.**
   - **Build and purpose:** Improve the principal scan, basket, and benefits
     flows; expose the explanation/suggestion actions; and add necessary
     loading, empty, error, and retry states. This supports usability and
     accessibility across all retained features.
   - **Feasibility and completion:** Treat this as targeted work on existing
     screens, not a full redesign. It is complete when widget tests and a manual
     walkthrough cover the principal flows, phone/desktop layouts, enlarged
     text, semantic labels, non-color status, and existing regressions.
   - **Risk protection:** Implement functional and accessibility requirements
     before optional visual polish; defer nonessential styling if M4/M0 slips.

5. **M4 — Add straightforward help for a rejected item.**
   - **Build and purpose:** Add the core item-to-help flow for prepared
     package-size, category-balance, stale-information, and missing-evidence
     cases. This directly implements the medium-confidence D1 gap.
   - **Feasibility and completion:** Use deterministic rules over versioned
     mock item/benefit fixtures rather than live integrations. It is complete
     when every rule and uncertainty fallback has a unit test and the full
     item-to-help-and-back flow returns without changing basket contents.
   - **Risk protection:** Label outputs as possible causes, include ``unable to
     determine,'' preserve source/freshness boundaries, and never promise
     checkout acceptance or override the register. M4 must reach a tested
     vertical slice before secondary milestone scope expands.

**Execution decision:** Within the roughly 160-hour team budget, week 1 protects
the M0 protocol and M1 measurement rules while defining M4's fixtures and flow;
bounded M2 work then proceeds in weeks 2--3 while M4 and targeted M3 work are
developed alongside it. Week 4 remains reserved for integration and evaluation.
If the M4/M0 critical path slips, defer M2 extensions and nonessential M3
polish; do not cut rule tests, uncertainty labels, regression testing,
accessibility basics, or the M0 comparison.

### Future -- after the one-month project

1. **Permissioned, versioned state APL synchronization.** Replace static
   eligibility fixtures with a monitored adapter that records jurisdiction,
   version, refresh time, conflicts, and stale-state information.
2. **Partner-backed read-only benefit and rejection-evidence pilot.** Evaluate
   recovery with authorized participant or transaction evidence without
   approving purchases, processing payments, or modifying benefits.
3. **Privacy-reviewed on-device receipt recognition and reconciliation.** Use
   local recognition where practical, connect item/quantity evidence to basket
   and benefit information, and retain a manual fallback.
4. **Spanish and broader accessibility validation.** Add professionally
   reviewed Spanish content and test disability, literacy, language, device,
   and network conditions.
5. **Production hardening and operational release.** Add access-control tests,
   monitoring, backups, retention/deletion policies, security review, and
   deployment-specific compliance work after scope and partnerships are stable.

## Scope and evidence boundaries

- Benefit information and checkout-rejection scenarios remain simulated.
- WolfBite may show only possible or likely causes when it lacks authoritative
  retailer or agency evidence; it must not promise acceptance or override a
  register result.
- Project 2 does not include live WIC/EBT/POS integration, payment processing,
  or mutation of an official benefit balance.
- Missing nutrition measurements remain unknown rather than becoming zero or
  receiving a favorable badge or comparison.
- Basket suggestions are an illustrative shopping aid, not personalized diet
  advice or a claim that a basket represents daily intake.
- Approval, rejection, and uncertainty must use text in addition to color or
  icons, and the core flow must retain manual UPC entry.
