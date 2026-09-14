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

Keep three to five clear, checkable goals in each group.

### Before -- Project 1a

- **TODO — awaiting team input:** Approve and insert three to five completed,
  evidence-backed Project 1a milestones.

### Now -- one-month build and test

1. **M0 — Check whether checkout help is useful.** Compare the checkout-help
   flow with the baseline on the same prepared scenarios. Build and test a
   reproducible scoring script and measure the 80% task-success and
   20-percentage-point improvement targets without presenting them as results.
2. **M1 — Better nutrition information and food-choice explainers.** Add units,
   serving or reference amounts, value explanations, and visible tradeoffs;
   preserve missing values as unknown. Verify the data rules, units,
   explanations, comparable measurement bases, persistence, and missing-data
   behavior with unit and widget tests.
3. **M2 — Basket-wide suggestions for more balanced food choices.** Use a
   bounded mock catalog, known compatible units/package amounts, and simulated
   allowances to preview up to three basket-aware, one-swap suggestions. Test
   quantity effects, basket-dependent rankings, unchanged previews, confirmed
   swaps, recalculation, missing data, balance consistency, and the absence of
   suitable candidates.
4. **M3 — A clearer, more complete shopping interface.** Improve the scan,
   basket, and benefits screens; add clear loading, empty, error, and retry
   states; and make the explanation and suggestion features discoverable.
   Verify the principal flows, phone/desktop layouts, enlarged text,
   screen-reader labels, non-color status, and existing regressions.
5. **M4 — Add straightforward help for a rejected item.** For prepared
   package-size, category-balance, stale-information, and missing-evidence
   scenarios, show a rule-based possible cause and next action from a basket
   item. Test every rule and the complete item-to-help-and-back flow without
   changing basket contents.

### Future -- after the one-month project

- **TODO — awaiting team input:** Approve and insert three to five credible
  Project 3 milestones.

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
