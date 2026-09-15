# Prompt 10 — Red Team

## Prompt

You are hostile to our proposal. Below: our mission statement, milestones,
and market survey.

Attack on three fronts:

1. Nobody wants it — the need is imagined.
2. They cannot build it — the month is too short, the team too green.
3. Someone does it better — name who.

Make each attack as strong as you honestly can; no strawmen. Then, for each
attack, state what evidence would defeat it. We will go collect that
evidence — or concede the point and change the plan.

## Mission Statement

WIC participants and caregivers can face uncertainty when a product appears eligible in an app but is rejected at checkout, a setting in which participant research has documented difficulty identifying eligible foods and stigma during shopping and checkout. That conflict can add confusion and friction during a household shopping trip. We propose extending WolfBite with an item-level explanation-and-recovery workflow that connects the rejected item’s UPC and package details, the participant’s current benefit or food category, and available eligibility or purchase evidence. For a bounded set of mocked mismatch scenarios, the workflow will distinguish app evidence from facts that only a retailer or WIC agency can confirm, then show rule-based likely causes and actionable next steps. This guidance is intended to help participants and caregivers choose a next action after an unexpected rejection while keeping uncertain information visible.

## Milestones

### Before — Project 1a

1. **Set up and analyzed the inherited WolfBite application**  
   We cloned and ran the existing project locally, learned how the codebase was organized, and reviewed the major application workflows so we could understand how the system behaved before making changes.

2. **Reviewed and mapped the Project 1a use cases to the implementation**  
   We worked through the documented use cases and connected each expected behavior, extension, and edge case to the relevant parts of the existing application.

3. **Created and executed automated tests for the documented use cases**  
   We added automated tests that covered the main scenarios and edge cases defined by the use cases, then ran the test suite to verify whether the implementation matched the documented requirements.

4. **Documented testing evidence and LLM-assisted analysis**  
   We recorded test results and traceability between tests and use cases, while also using multiple LLMs to analyze the product, requirements, and testing evidence as part of the overall Project 1a evaluation.


### Now — Project 2

1. **M0: Check whether checkout help is useful.** Compare the current flow with the checkout-help feature using the same prepared rejection scenarios. Keep D2’s target: at least 80% of trials choose the reference next step within 60 seconds without help, with success at least 20 percentage points above the baseline. Build a script that scores trial logs and runs in CI; check it with known passing and failing examples. Synthetic logs test the script, not real usability. Report pilot results separately if volunteers are available, and record a re-plan decision if measured results miss the target.

2. **M1: Better nutrition information and food-choice explainers.** Extend the existing nutrition panel and badges with units, serving or reference amounts, and short explanations of the values behind a label or comparison. Show available sodium, sugar, fiber, protein, and fat information, including tradeoffs between options rather than a single unexplained “healthier” score. Reuse the nutrition utility and product records, preserve missing values as unknown, and retain the measurement basis in saved basket items. Check educational wording against cited nutrition sources during implementation. Unit and widget tests must verify displayed values and units, explanation rules, comparable serving bases, and missing-data cases; unknown values must never earn a favorable badge or comparison.

3. **M2: Basket-wide suggestions for more balanced food choices.** Add an optional “Basket balance” mode alongside individual substitutions. Use basket quantities and M1’s nutrition data to summarize food-group variety and rank possible swaps by their effect on the whole basket. Start with a small mock catalog with known package amounts and food-group mappings, and explicit demonstration targets for sodium, added sugar, and fiber. Prioritize only comparisons with known, compatible units and package amounts; flag incomplete totals and skip suggestions that depend on missing measurements. Rank candidates against the basket’s largest target gap, rather than ranking each food in isolation; show before/after values and any tradeoffs for up to three suggestions. Reuse the APL category lookup, restrict swaps to the same benefit category and compatible package size, and recheck simulated allowances before applying one shopper-confirmed swap at a time. Recalculate after each change. Tests must show that the same item can receive different suggestions in different baskets, quantities affect results, and previews leave the basket unchanged. Also test confirmed swaps, balance consistency, missing measurement data, and no suitable candidate. This is a shopping aid with illustrative targets, not a personalized diet plan or a claim that a basket represents daily intake.

4. **M3: A clearer, more complete shopping interface.** Improve the existing scan, basket, and benefits screens with consistent typography, spacing, product cards, and clearly labeled primary actions. Make nutrition explanations and the two suggestion modes easy to find; distinguish covered and shopper-paid items with text as well as color. Add useful loading, empty, error, and retry states. Widget tests and a manual walkthrough must cover scan-to-basket navigation, opening an explainer, previewing a basket suggestion, and checking benefits. Verify phone and desktop layouts, enlarged text, and screen-reader labels without clipped content or inaccessible controls. Existing quantity and navigation tests must continue to pass.

5. **M4: Add straightforward help for a rejected item.** Add an action on a basket item that opens a short explanation and next step for prepared package-size, category-balance, and stale-information scenarios. Use simple rules over mock item and benefit records, with an “unable to determine” response when evidence is missing. Test each explanation and the full item-to-help flow, including returning to the basket without changing its contents. Label the advice as possible causes, not an official checkout decision; use this feature in M0’s comparison.


### Future — Project 3

1. **Permissioned, versioned state APL synchronization**  
   Replace static eligibility fixtures with a monitored data adapter that records jurisdiction, version, refresh time, conflicts, and stale-state information.

2. **Partner-backed read-only benefit and rejection-evidence pilot**  
   Test the recovery workflow using authorized participant or transaction evidence without allowing WolfBite to approve purchases, process payments, or modify benefits.

3. **Privacy-reviewed on-device receipt recognition and reconciliation**  
   Recognize receipt item and quantity evidence locally where possible and reconcile it with basket and benefit information while keeping a manual fallback.

4. **Spanish and broader accessibility validation**  
   Add professionally reviewed Spanish content and validate the workflow across disability, literacy, language, device, and network conditions.

5. **Production hardening and operational release**  
   Add stronger access-control testing, monitoring, backups, retention/deletion policies, security review, and deployment-specific compliance work.

## Market Survey

### Method

We ran the shared market-survey Prompt 1 with four LLM analysts: Codex,
Terra, Gemini, and local Ollama, to generate rival candidates. We retained a
rival only when at least two models named it or one model supplied a live,
relevant URL. We then checked official product sources and independently
audited the three strongest rivals. Each final rival independently satisfies
the live-URL qualification rule through an official product source.

### Verified Rivals

| Rival | Evidence it is real | What it does | Relevant limitation |
|---|---|---|---|
| WICShopper | Official App Store listing and vendor purchase-history documentation | Shows benefits, scans eligibility, provides food guidance, and records item/category purchase history in supported agencies | No documented workflow connects a scan/checkout mismatch to its likely cause and recovery steps. |
| myWIC Mosaic | Official App Store listing | Shows benefits, tracks purchases, scans products, and supports shopping, appointments, and certification | No documented item-level explanation and recovery workflow for an unexpectedly uncovered item. |
| Bnft | Official App Store listing | Shows balances, scans benefit eligibility, manages cards, and provides transaction history | No documented item-level reconciliation or explanation for conflicting scan and checkout results. |

### Selected Gap and Audience

**Gap:** Our feature audit found no documented integrated, item-level
explanation-and-recovery workflow in WICShopper, myWIC Mosaic, or Bnft for
cases where an app indicates that a product is eligible but checkout rejects
it. Such a workflow could connect the rejected item, the participant's current
benefit or food category, and purchase evidence to likely causes and
actionable next steps.

**Audience:** WIC caregivers and participants shopping for their
households, especially those managing young children while an item they
expected to be covered is rejected at checkout.

This need is supported by participant research reporting difficulty
identifying WIC-eligible foods and stigma during shopping and checkout.
WIC caregivers also rank balance checking and barcode scanning among their
highest-priority app features. Together, this evidence suggests that eligibility
uncertainty during shopping remains consequential for the target audience.

We also evaluated two alternative gaps. We rejected nutrition comparison
because participant evidence for that need was comparatively weak. We rejected
broader receipt reconciliation because all three rivals already provide some
form of purchase or transaction history. The narrower explanation-and-recovery
gap therefore has stronger support from both the competitor audit and
participant evidence.

### Counterevidence and Scope

The conclusion has **medium confidence**. WICShopper already provides
item-level purchase history in some agencies, myWIC tracks purchases, and Bnft
provides transaction history. Public documentation may also omit
program-specific features. In one month, the team can build and test a
WolfBite prototype using fixed mismatch scenarios, rule-based likely causes,
and recovery guidance. Without state benefit-system data, the prototype must
not claim to know an authoritative point-of-sale rejection reason.

## Terra Output

## 1. Nobody wants it — the need may be imagined

  Your evidence establishes that WIC shopping can be difficult and stigmatizing. It does not yet
  establish that an item-level post-rejection explainer is the thing participants want, would use,
  or would find helpful in the moment.

  A skeptical reading:

  - The claimed event may be too infrequent to justify a dedicated workflow. Participants may
    experience general eligibility uncertainty before checkout, but not a meaningful rate of “app
    said yes, register said no” conflicts.

  - When rejection happens, people may already know the practical recovery: leave the item, pay out
    of pocket, ask the cashier, or call their clinic later. A third-party app offering “possible
    causes” may add cognitive load at the most embarrassing and time-constrained point of the trip.

  - The product cannot resolve the only question that matters—“will this purchase go through here,
    right now?” Your copy correctly disclaims authority. But that means the feature could feel like
    a polished version of “we don’t know; ask someone else.”

  - “Checkout help” risks being a solution in search of a problem. The highest-priority needs you
    cite are barcode scanning and balance checking, both already addressed by incumbents.
    Difficulty identifying foods does not logically prove demand for retrospective diagnosis.

  - The nutrition and basket-balance work weakens the story. You explicitly rejected nutrition
    comparison as a weaker evidence-backed gap, then devote most of the month to it. That looks
    like feature accumulation rather than disciplined response to a validated problem.

  Evidence that defeats this attack

  Collect evidence from actual WIC shoppers, not just general literature:

  - A short intercept, diary, or survey study measuring the prevalence of app/POS mismatches, what
    users did, time lost, whether the situation was embarrassing, and whether they would have used
    in-app help.

  - Five to eight moderated scenario tests where participants encounter realistic mismatch cases.
    Compare current flow to proposed help; measure comprehension, confidence, time to a sensible
    action, and harmful misconceptions.

  - Evidence that the proposed next steps differ materially from participants’ unaided behavior and
    are judged useful by participants or WIC staff.

  - A clear prioritization study showing rejection recovery outranks, or at least complements,
    scanner/balance improvements.

  - If this evidence is absent, narrow the claim: call it an exploratory prototype for a documented
    friction point, not a demonstrated high-demand feature. Consider dropping M1/M2 unless
    independently justified.

  ## 2. They cannot build it — the month is too short and the plan is over-scoped

  This is not one feature. It is five substantial projects: experimental usability measurement,
  nutrition-information correctness, basket-level optimization, responsive/accessibility UI
  redesign, and a rejection-recovery workflow. A month is not credible for doing all of those well,
  especially on an inherited codebase.

  The riskiest parts are not the visible screens:

  - M0 requires a legitimate comparison design, a defined baseline, reference answers, recruitment,
    consent/ethics considerations as applicable, trial logging, analysis, and a re-plan decision.
    CI can validate a scoring script, but cannot validate usability.

  - M1 requires defensible nutrition normalization: per-serving versus per-package values, package
    quantities, compatible units, missing values, and wording sourced from authoritative nutrition
    guidance.

  - M2 is a constrained recommendation system. It must maintain basket state, quantities, food-
    group mappings, nutrition bases, benefit-category restrictions, package compatibility,
    allowance simulation, ranking, tradeoffs, previews, confirmed swaps, and recalculation. “Small
    mock catalog” reduces data volume, not behavioral complexity.

  - M3 adds cross-device, large-text, screen-reader, loading/error/empty-state, visual-consistency,
    and regression obligations across the entire existing application.

  - M4 alone is feasible as a mocked, rule-based prototype. But even it needs credible scenario
    data and careful wording because an incorrect explanation at checkout can waste money, delay a
    household, or increase stigma.

  There is also a mission-roadmap contradiction. The mission is about checkout mismatch recovery;
  M1–M3 dominate the workload and are only indirectly related. This creates a predictable failure
  mode: a visually impressive demo where the core recovery workflow is shallow, untested with
  people, and not shown to improve outcomes.

  Finally, the M0 success statement is ambiguous: “at least 80% … without help, with success at
  least 20 percentage points above the baseline.” Is 80% the helped condition, the unaided
  condition, or both? What is the baseline flow? What exactly counts as the reference next step in
  a situation where several actions may be sensible? Ambiguity lets the team accidentally grade
  toward its preferred outcome.

  Evidence that defeats this attack

  - A dated, owner-assigned work breakdown showing that M4 and M0 are the critical path, with
    explicit cuts to M1–M3 if the core path slips.

  - A thin vertical slice completed early: select mocked item → see evidence boundaries → receive
    likely cause/next action → return unchanged to basket; with automated coverage.

  - A fixed, reviewed scenario matrix containing inputs, expected explanation, uncertainty
    language, reference action, and known out-of-scope cases.

  - A demonstrated end-to-end run on physical target layouts plus automated tests for the core flow
    before investing in basket recommendations or visual polish.

  - A pre-registered M0 protocol: baseline, eligibility criteria, trial count, success definition,
    timing method, handling of multiple acceptable actions, and decision rule.

  - Evidence that the team has already delivered comparable changes to WolfBite, or a scope
    reduction to M0 + M4 only.

  The strongest corrective action is simple: make M4 the product, M0 the evaluation, and treat M1–
  M3 as explicitly deferred or minimal supporting polish.

  ## 3. Someone does it better — and they own the facts WolfBite lacks

  The real competitor is not another generic shopping app. It is the combination of the state WIC
  agency, its MIS/EBT processor, the authorized retailer, and the retailer’s certified point-of-
  sale system.

  They have the authoritative inputs WolfBite does not:

  - the current jurisdiction-specific Approved Product List;
  - the participant’s actual benefit balance and issuance state;
  - the actual UPC and transaction context;
  - retailer configuration and point-of-sale response;
  - the authoritative decision and, potentially, transaction/receipt evidence.

  WICShopper, myWIC Mosaic, and Bnft are also stronger competitors than the survey admits because
  they already offer much of the user’s actual job-to-be-done: balance visibility, product
  scanning, purchase history, and program-backed account access. Bnft, for example, publicly
  describes real-time balances, barcode scanning, and transaction history. The absence of public
  documentation for a narrowly named “mismatch explanation workflow” is not evidence that the
  capability is absent in state-specific configurations, support channels, retailer procedures, or
  future releases.

  More fundamentally, if the problem is stale or mismatched eligibility information, an independent
  app is structurally disadvantaged. It can tell a plausible story but cannot tell the user whether
  the retailer’s current system will approve the item. A state-backed app or retailer-integrated
  experience can either prevent the mismatch with fresher data or explain it with real evidence
  afterward. That is better than a prototype constrained to mock scenarios.

  Named “who”:

  - WICShopper / JPMA — established scanner, benefit, food-guide, and purchase-history ecosystem in
    participating agencies.

  - myWIC Mosaic — state-program-connected participant app covering benefits, purchases, product
    scanning, appointments, and certification.

  - Bnft / Solutran — benefit-management platform with real-time balance and transaction-history
    capabilities.

  - State WIC agencies, EBT processors, and certified retailer POS providers — the decisive
    competitors because they operate the authoritative systems. USDA documents the state-by-state
    MIS and EBT-provider ecosystem, while state vendor guidance makes clear that certified POS
    systems process the WIC transaction and current product-list logic.

  Evidence that defeats this attack

  - A jurisdiction-specific capability audit, not just public app-store descriptions: contact
    agencies/vendors, test current versions, and document whether each competitor handles the exact
    “scanner says eligible; POS rejects” case.

  - Evidence that the authoritative systems do not expose usable rejection reasons to participants
    or front-line staff—or that their current explanation is slow, inaccessible, or inadequate.

  - Proof of a durable integration path: a letter of interest, pilot partner, sandbox access, data-
    sharing path, or documented API/transaction-evidence arrangement with a WIC agency, processor,
    or retailer.

  - Comparative testing showing WolfBite helps users choose a correct next action more quickly or
    confidently than incumbent scanner/balance/history flows.

  - A sharply differentiated role: WolfBite should not claim to out-authorize WIC systems. It must
    demonstrate that it makes fragmented evidence understandable when those systems cannot—or do
    not—give a participant usable recovery guidance.

  The hard conclusion: without participant evidence and a credible route to authoritative data,
  this is best defended as a careful prototype and research artifact, not as a competitive product
  proposition.