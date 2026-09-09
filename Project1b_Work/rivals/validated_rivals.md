# Cross-model rival validation

A live URL must show that the named software product exists and is relevant;
an unrelated or broken page does not validate a rival.

| Candidate | Codex | Terra | Gemini | Local | Live relevant URL? | Survives course rule? | Direct rival? | Final evidence and decision |
|---|---:|---:|---:|---:|---|---|---|---|
| WICShopper | Yes | Yes | Yes | Yes | Yes | YES — named by 2+ models | Yes | Named by all four models after normalizing Ollama's “WIC Shopper” spacing. Live product and government pages verify benefit-aware WIC shopping and scanning. Strongest platform-level rival. |
| Bnft | Yes | No | Yes | No | Yes | YES — named by 2+ models | Yes | Codex and Gemini independently named it. The live listing verifies WIC balances, scanning, and card-management functions in supported programs. Strong platform-level rival, but WIC availability is limited. |
| myWIC Mosaic | Yes | Yes | Yes | No | Yes | YES — named by 2+ models | Yes | Terra's “myWIC” is the same product: the live myWIC Mosaic listing calls it the myWIC app and includes Texas. Strong multi-program rival with shopping, benefits, appointments, and certification workflows. |
| ebtEDGE | Yes | No | No | No | Yes | YES — one model + live relevant URL | Yes | Codex supplied a live listing for benefit/card security, transaction, and WIC eligibility functions. Retain as a platform-level rival, but only one model named it. |
| California WIC App | Yes | Yes | Yes | No | Yes | YES — named by 2+ models | Yes | Three models named it, and the California government page verifies food balances, appointments, and the app. Strong state-specific workflow comparison. |
| EzWIC | Yes | No | No | No | Yes | YES — one model + live relevant URL | Yes | Codex supplied Arizona government evidence for benefit-aware scanning and related shopping functions. Retain as a state-specific direct rival, but only one model named it. |
| WIC Connect | Yes | Yes | Yes | No | Yes | YES — named by 2+ models | Yes | Three models named the Michigan app. Government and app-store pages verify issued benefits, appointments, UPC scanning, and location tools. Strong state-specific comparison. |
| Florida WIC App | Yes | Yes | Yes | No | Yes | YES — named by 2+ models | Yes | Normalizes Terra's “FL WIC” and Gemini's “Florida WIC Mobile App.” Three models named it; government and app-store pages verify a current state-specific WIC app. |
| Maryland WIC App (MD WIC) | Yes | No | No | No | Yes | YES — one model + live relevant URL | Yes | Codex supplied current Maryland government evidence for benefit-aware UPC scanning and related WIC functions. Retain, but only one model named it. |
| WIC2Go | Yes | Yes | No | No | Yes | YES — named by 2+ models | Yes, but legacy | Codex and Terra named it. Current evidence identifies a real New York WIC app but also shows New York moving users toward ebtEDGE, so retain as a legacy comparison. |
| Indiana WIC | No | Yes | No | No | No URL supplied | NO — insufficient independent/URL evidence | Yes | Terra described a direct state WIC app but supplied only “App Store listing,” not a URL, and no second model named it. Do not count under the course rule. |
| Wisconsin MyWIC | No | Yes | No | No | No URL supplied | NO — insufficient independent/URL evidence | Yes | Terra described a direct state WIC app but supplied only a source label and no second model named it. Do not count under the course rule. |
| SC WIC Mobile App | No | Yes | No | No | No URL supplied | NO — insufficient independent/URL evidence | Yes | Terra described a direct state WIC app but supplied only a source label and no second model named it. Do not count under the course rule. |
| Minnesota WIC App | No | Yes | Yes | No | Supplied path unconfirmed; current official page exists | YES — named by 2+ models | Yes | Terra's older “my Minnesota WIC App” and Gemini's “Minnesota WIC App” refer to the same product. Minnesota's current site documents the rename and verifies benefit, UPC, appointment, and store features. |
| FreshConnect | No | No | No | Yes | No | NO — insufficient independent/URL evidence | No / unverified | Ollama's supplied `.com` URL did not produce a relevant product page. A different `.org` food-as-medicine platform does not validate the cited URL or the WIC-specific description. |
| WIC Mobile App | No | No | No | Yes | No | NO — insufficient independent/URL evidence | Unverified | Generic name, one model, and the supplied URL did not produce a live product page. Do not count it. |
| StoreWise | No | No | No | Yes | No | NO — insufficient independent/URL evidence | No / unverified | The supplied URL did not validate the described consumer product; searches found unrelated products using the same name. Do not count it. |
| Ibotta | No | No | No | Yes | Yes | YES — one model + live relevant URL | No; adjacent | The supplied URL verifies a real cash-back shopping app. It passes the literal rule but does not provide WIC eligibility or benefit tracking, so it is not a direct rival. |
| Fetch Rewards | No | No | No | Yes | Yes | YES — one model + live relevant URL | No; adjacent | The supplied URL verifies a real receipt-rewards app. It passes the literal rule but is not WIC-specific. |
| Checkout 51 | No | No | No | Yes | Yes | YES — one model + live relevant URL | No; adjacent | The supplied URL verifies receipt-based grocery cash back. It passes the literal rule but is not WIC-specific. |
| Out of Milk | No | No | No | Yes | Yes | YES — one model + live relevant URL | No; adjacent | The supplied URL verifies a grocery-list app with barcode entry. It passes the literal rule but is not WIC-specific, and the reviewed page did not support Ollama's receipt-scanning claim. |
| Grocery IQ | No | No | No | Yes | No | NO — insufficient independent/URL evidence | No / unverified | The supplied URL did not return a usable live product page. With no second model naming it, do not count it. |
| AnyList | No | No | No | Yes | Yes | YES — one model + live relevant URL | No; adjacent | The supplied URL verifies shared grocery lists, recipes, and meal planning. It passes the literal rule but is not WIC-specific, and the reviewed page did not support Ollama's receipt-scanning claim. |

## Strongest final rival set

1. **WICShopper — platform-level direct rival.** All four models named it, and
   live evidence verifies benefit-aware scanning and balances across many
   participating agencies.
2. **myWIC Mosaic — multi-program direct rival.** Three models named it after
   normalizing Terra's shortened name. It combines shopping and benefit tools
   with appointments and certification workflows.
3. **Bnft — platform-level direct rival.** Two models named it, and its live
   listing supports benefit-aware shopping and card management, although its
   documented WIC reach is narrower.

ebtEDGE is another qualifying platform-level rival. California WIC App, WIC
Connect, Florida WIC App, and Minnesota WIC App are useful state-specific
comparisons. State-branded apps should not automatically be counted as fully
independent market platforms because the collected output does not establish
their underlying vendor relationships.

## Focused feature audit

This audit uses the definitions in the focused-validation task. Eligibility
scanning, approved-food lists, balances, recipes, or nutrition education do not
by themselves count as nutrition comparison. Generic balance or transaction
history does not count as receipt reconciliation unless it connects purchases
to benefit use.

| Rival | Nutrition comparison | Receipt reconciliation | Strongest evidence | Confidence |
|---|---|---|---|---|
| WICShopper | NO EVIDENCE FOUND | PARTIAL | The official product site documents benefit display, eligibility scanning, recipes, and a food list. Its Washington help page documents 90 days of purchase history with date, store, WIC food category, item, and quantity, but no explanation for rejected or non-applied items. | MEDIUM-HIGH; official documentation is direct, but features vary by WIC agency. |
| myWIC Mosaic | NO EVIDENCE FOUND | PARTIAL | The official portal and store listings document benefits, purchases, scanning, shopping guidance, and nutrition resources. They do not document side-by-side nutrition tradeoffs or receipt-level explanations for benefit mismatches. | MEDIUM; documentation is direct but may not enumerate every program-specific feature. |
| Bnft | NO EVIDENCE FOUND | NO EVIDENCE FOUND | Current store listings document balances, benefit-aware scanning, and up to one year of transaction history. They do not establish meaningful nutrition comparison or item-level receipt reconciliation and mismatch explanations. | MEDIUM; transaction-history granularity and program-specific capabilities are not fully documented. |

### WICShopper

- **Nutrition comparison — NO EVIDENCE FOUND.** The [official product
  site](https://ebtshopper.com/) supports healthy recipes and other nutrition
  content, but the reviewed documentation does not show comparison of two or
  more eligible foods by sodium, sugar, protein, fiber, or other tradeoffs.
  Recipes and education therefore do not satisfy the definition.
- **Receipt reconciliation — PARTIAL.** The official [Washington redemption
  history help
  page](https://ebtshopper.com/banners/washington-redemption-history/)
  documents 90 days of WIC purchase history, including store, category, item,
  and quantity. This connects successful purchases to WIC benefits. The
  reviewed documentation does not show why an expected item failed to apply or
  reconcile non-WIC payment at receipt level. WICShopper also documents an
  ``I Couldn't Buy This!'' reporting path, but reporting a problem is not an
  explanation of the completed transaction.
- **Uncertainty.** WICShopper capabilities vary by participating agency. The
  absence of a documented comparison or explanation feature is not proof that
  no agency offers one.

### myWIC Mosaic

- **Nutrition comparison — NO EVIDENCE FOUND.** The [official
  portal](https://mywic.us/auth/login), [Apple App Store
  listing](https://apps.apple.com/us/app/mywic-mosaic/id1560485314), and
  [Google Play
  listing](https://play.google.com/store/apps/details?id=com.vexcel.mywic)
  document a scanner, shopping guide, benefits, and tailored nutrition
  resources. None of the reviewed material documents comparison of eligible
  foods by meaningful nutritional tradeoffs.
- **Receipt reconciliation — PARTIAL.** The portal and listings state that
  users can track purchases along with benefits. That is more than a balance
  alone, but the reviewed documentation does not establish item-level receipt
  matching or explanations for rejected or unexpectedly uncovered items.
- **Uncertainty.** The public descriptions may omit details and participating
  agencies may configure the product differently.

### Bnft

- **Nutrition comparison — NO EVIDENCE FOUND.** The [Apple App Store
  listing](https://apps.apple.com/us/app/bnft/id1286864895) and [Google Play
  listing](https://play.google.com/store/apps/details?id=com.bnft.solutran)
  document a benefit-aware scanner and featured products, but not comparisons
  among eligible foods by nutritional content or tradeoff.
- **Receipt reconciliation — NO EVIDENCE FOUND.** The listings document up to
  one year of transaction history. They do not say that the history identifies
  receipt items, relates each item or quantity to a WIC benefit, or explains a
  rejection. Under the task's strict definition, generic transaction history
  is counterevidence but is not enough to establish receipt reconciliation.
- **Uncertainty.** Public listings may omit transaction details, and Bnft's WIC
  functions are available only in supported programs.

## WIC-participant evidence

| Source | Type | Date | User problem | Brief quote or paraphrase | Possible gap supported | Strength |
|---|---|---|---|---|---|---|
| [Fiedler et al., *WIC Participant Perspectives*](https://doi.org/10.1016/j.jneb.2025.07.005) | Peer-reviewed qualitative study: 11 focus groups and two interviews with 44 English- and Spanish-speaking participants across 19 states, one tribal organization, and one territory | 2026 | Finding WIC-eligible foods and stigma during shopping | Participants described finding WIC-eligible foods and shopping stigma as barriers. | Clearer eligibility and recovery when a purchase does not work as expected | HIGH |
| [Chauvenet et al., *WIC Recipients in the Retail Environment*](https://doi.org/10.1016/j.jand.2018.09.003) | Peer-reviewed qualitative study | 2019 | Poor labeling, difficulty identifying WIC-approved items, and negative checkout experiences | Participants reported trouble identifying eligible items and stigma at checkout, which can impede benefit redemption. | Eligibility/mismatch explanation and recovery | HIGH |
| [Weber et al., *Prioritization of Features for Mobile Apps for Families in WIC*](https://doi.org/10.2196/30450) | Peer-reviewed user-centered design study with 22 WIC caregivers | 2021 | Need for usable shopping and benefit information | Participants ranked a balance checker and barcode scanner among the highest-priority app features; nutrition and dietary-preference features ranked lower. | Eligibility and benefit clarity; counterevidence to a nutrition-comparison gap | HIGH |
| [myWIC Mosaic Google Play review](https://play.google.com/store/apps/details?id=com.vexcel.mywic) | Public participant review | 2026-04-08 | Scanner failure and unclear approved-item specifications | The reviewer reports that the app will not scan and that the specifications for approved items are unclear. | Eligibility/mismatch explanation and recovery | LOW |
| [Bnft Google Play review](https://play.google.com/store/apps/details?id=com.bnft.solutran) | Public participant review | 2023-09-21 | Items previously shown as covered appear uncovered, alongside login trouble | The reviewer reports that products previously covered began appearing as not covered. | Eligibility/mismatch explanation and recovery | LOW |
| [r/WIC checkout-mismatch discussion](https://www.reddit.com/r/WIC/comments/1sbs4uw/wic_items_suddenly_not_covered/) | Public participant discussion | 2026 | App eligibility result did not match checkout coverage | The poster reports that items scanned as approved, but only two applied at checkout. | Eligibility/mismatch explanation and recovery | LOW |

The strongest participant evidence concerns reliable eligibility and benefit
clarity, especially where an expected eligible product does not work at
checkout. The evidence does not establish that nutrition comparison itself is
a participant priority, and it supports post-purchase reconciliation only
indirectly through checkout mismatch and redemption problems.

## Claim separation

**Claim A: the rivals do not appear to provide the capability.** None of the
three rivals' reviewed documentation establishes a workflow that connects a
scan/checkout mismatch with the affected item, current benefit or category,
likely causes, and actionable recovery steps. This claim has **MEDIUM** support:
the documentation is direct but incomplete, and WICShopper already offers
problem reporting plus item-level purchase history in some agencies.

**Claim B: WIC participants need the capability.** Peer-reviewed studies
document difficulty identifying eligible foods, checkout stigma, and the high
priority of scanners and balance information. Current participant reports also
describe scan/checkout mismatches. This claim has **HIGH** support for clearer
eligibility and mismatch recovery, but not for nutrition comparison or receipt
OCR by themselves.

## Nutrition-comparison gap test

- **Competitor-gap evidence: MEDIUM.** No reviewed source for WICShopper,
  myWIC Mosaic, or Bnft documents meaningful comparison among eligible foods,
  although incomplete public documentation prevents an absolute absence claim.
- **Participant-need evidence: LOW.** The strongest study that directly asked
  users to prioritize app features placed barcode and balance functions above
  nutrition and dietary-preference features. The other participant studies
  establish eligibility and checkout barriers, not demand for nutrition
  comparison.
- **Counterevidence:** WICShopper and myWIC already provide recipes or
  nutrition resources, and the evidence does not show that participants would
  use a side-by-side comparison while shopping.
- **One-month feasibility:** A bounded comparison prototype could be built and
  tested, but the unsupported participant priority would make the validation
  target speculative.
- **Overall gap confidence: REJECT.** Competitor absence alone is insufficient
  because Claim B is weak.

## Receipt-reconciliation gap test

- **Competitor-gap evidence: LOW-MEDIUM.** WICShopper documents item/category
  purchase history, myWIC says it tracks purchases, and Bnft offers transaction
  history. None clearly documents a complete mismatch-explanation workflow,
  but existing history features cover part of the proposed gap.
- **Participant-need evidence: MEDIUM.** Participant studies and reviews show
  eligibility and checkout mismatch problems, but do not directly establish a
  demand for receipt OCR or a separate post-purchase reconciliation tool.
- **Counterevidence:** Existing purchase and transaction histories may already
  give many users enough post-purchase information; adjacent grocery apps also
  establish that receipt capture itself is not novel.
- **One-month feasibility:** A fixed-fixture reconciliation prototype is
  feasible, but authoritative diagnosis would depend on point-of-sale and
  state EBT data outside the team's control.
- **Overall gap confidence: WEAK.** The broad receipt-reconciliation statement
  overclaims both rival absence and directly demonstrated participant demand.

## Final D1 Market Gap

**Decision: SELECT ONE BETTER EVIDENCE-BASED GAP.**

**Gap:** WIC participants who encounter a mismatch between an app's eligibility
result and checkout lack an integrated, item-level explanation-and-recovery
workflow that connects the rejected item, current benefit or category, and
purchase evidence to likely causes and next steps.

**Audience:** WIC caregivers and participants shopping for their households,
especially those managing young children while an item they expected to be
covered is rejected at checkout.

**Validated rivals:**

- WICShopper
- myWIC Mosaic
- Bnft

**Why the rivals do not adequately fill it:** All three support parts of the
shopping workflow, such as eligibility scans, balances, purchases, or
transaction history. The reviewed sources do not document one workflow that
links a mismatch to the item and current benefit, explains likely causes, and
offers recovery steps. WICShopper comes closest through purchase history and
problem reporting, so the finding is an inadequately filled gap rather than a
claim of complete feature absence.

**Participant evidence:** Peer-reviewed research documents difficulty finding
eligible foods, checkout stigma, and strong user priority for reliable benefit
and scanner information. Current reviews and participant discussion describe
approved-item uncertainty and scan/checkout mismatches. Together these sources
support a need for understandable recovery when eligibility signals conflict.

**Counterevidence:** WICShopper already offers item-level purchase history in
some agencies and a problem-reporting path; myWIC tracks purchases; and Bnft
offers transaction history. Public product pages may omit features, agency
implementations vary, and participant studies do not ask directly for the
proposed combined workflow. A student prototype also cannot supply an
authoritative point-of-sale denial reason without program data.

**Confidence: MEDIUM.** Claim B has strong support, while incomplete competitor
documentation and partial rival features limit Claim A.

**One-month feasibility:** Four students can build and test a bounded WolfBite
prototype using deterministic mismatch fixtures: capture an item, current
benefit/category, and purchase context; show rule-based likely causes; and
offer recovery steps. The prototype must label causes as possibilities and
must not claim authoritative point-of-sale diagnosis.

## Counterevidence checked

- WICShopper already supports benefit-aware scanning and real-time balances
  across many participating agencies, weakening any claim that multi-agency
  WIC shopping support is absent.
- myWIC Mosaic already combines shopping, benefits, appointments, document
  upload, and certification tasks, weakening broad “all-in-one WIC app” gap
  claims.
- Bnft and ebtEDGE already provide card, balance, purchase, or transaction
  management, which may make receipt OCR less valuable than the proposal
  assumes.
- Ibotta, Fetch Rewards, and Checkout 51 demonstrate receipt-based consumer
  workflows, but they do not show that WIC participants want receipt OCR
  layered onto benefit management.
- No user-research evidence in the reviewed D1 material establishes demand for
  nutrition comparison, receipt OCR, QR checkout handoff, or cross-state
  portability. The focused audit found participant evidence for eligibility
  and checkout problems, not for nutrition comparison or receipt OCR as such.
- WICShopper documents item-level purchase history for some agencies and an
  ``I Couldn't Buy This!'' reporting path. Those features narrow any credible
  gap to integrated explanation and recovery rather than history or reporting
  alone.
- myWIC Mosaic tracks purchases and Bnft provides transaction history. Public
  documentation does not establish item-level explanations, but incomplete
  documentation means absence cannot be asserted absolutely.
- Peer-reviewed feature-prioritization evidence favors balance and scanning
  over nutrition features, defeating the proposed nutrition-comparison gap.
- Authoritative rejection reasons may depend on point-of-sale and state EBT
  data unavailable to a one-month student project.

## D5 observations from rival validation

- **Gemini:** Returned seven products rather than the requested ten. Detected
  by counting the raw response rows; the missing rows were not repaired.
- **Terra:** Used source descriptions such as “Washington State DOH” instead
  of URL strings. Detected by inspecting each raw evidence field; Terra-only
  candidates cannot use the one-model-plus-live-URL rule.
- **Local Ollama:** Claimed zero overlap with Terra even though “WIC Shopper”
  is an obvious spacing variant of WICShopper. Detected by name normalization
  and confirmed by the supplied live URL.
- **Local Ollama:** Described the WICShopper URL as apparently fabricated, but
  the URL redirects to the live WICShopper product site. Other local URLs were
  dead, unverified, or pointed toward ambiguously named products.
- **Local Ollama:** Claimed receipt scanning for Out of Milk and AnyList; the
  reviewed live product pages support list/meal-planning functions (and a
  barcode scanner for Out of Milk) but did not support those receipt claims.
- **Cross-model:** Pricing and product-scope descriptions differ for several
  state apps. Product existence was verified separately from unsubstantiated
  strength, weakness, and price claims.
- **Cross-model:** Eligibility scanning was sometimes treated as evidence for
  the full shopping problem. The focused audit applied the task definition and
  did not count scanning as nutrition comparison.
- **Cross-model:** Generic transaction or purchase history can be mistaken for
  receipt reconciliation. Official descriptions were checked for item-level
  benefit use and mismatch explanations before assigning a verdict.
- **Local Ollama:** Its ``no receipt scanning'' description for WICShopper
  omitted the more relevant official evidence that some agencies expose
  item/category purchase history. The team caught this by checking WICShopper's
  official help documentation rather than treating the raw model summary as an
  absence finding.

## Current D1 Result

Qualifying rivals:

- WICShopper
- Bnft
- myWIC Mosaic
- ebtEDGE
- California WIC App
- EzWIC
- WIC Connect
- Florida WIC App
- Maryland WIC App
- WIC2Go
- Minnesota WIC App
- Ibotta (adjacent)
- Fetch Rewards (adjacent)
- Checkout 51 (adjacent)
- Out of Milk (adjacent)
- AnyList (adjacent)

Strongest direct rivals:

1. WICShopper
2. myWIC Mosaic
3. Bnft

Selected market gap:

An integrated, item-level explanation-and-recovery workflow for WIC
participants whose app eligibility result conflicts with checkout. The
workflow connects the rejected item, current benefit/category, and purchase
evidence to likely causes and next steps without claiming authoritative
point-of-sale diagnosis.

Important counterevidence:

- WICShopper already provides item-level purchase history in some agencies and
  a problem-reporting path.
- myWIC purchase tracking and Bnft transaction history reduce the novelty of a
  broad receipt-reconciliation claim.
- Public competitor documentation is incomplete and program configurations
  vary.
- Participant evidence favors eligibility, scanning, and benefit clarity over
  nutrition comparison.

**D1 STATUS: COMPLETE.** Three direct rivals are validated, the selected gap
and audience are supported, counterevidence is explicit, and the concise D1
finding is included in the Project 1b report. The final confidence is MEDIUM.

# Focused Gap Validation — Work Completed

- [x] Audited WICShopper
- [x] Audited myWIC Mosaic
- [x] Audited Bnft
- [x] Checked nutrition-comparison capabilities
- [x] Checked receipt-reconciliation capabilities
- [x] Collected WIC-participant evidence
- [x] Checked counterevidence
- [x] Evaluated nutrition-comparison gap
- [x] Evaluated receipt-reconciliation gap
- [x] Final market gap selected
- [x] D1 added to main.tex
- [x] D1 complete

## Simple Result

Nutrition-comparison gap:
REJECTED

Receipt-reconciliation gap:
WEAK

Selected final gap:
Integrated item-level explanation and recovery when an app eligibility result
does not match checkout.

Target audience:
WIC caregivers and participants shopping for their households, especially
those handling an expected-covered item rejected at checkout.

D1 added to main.tex:
YES

D1 status:
COMPLETE

Next Project 1b step:
Translate the selected D1 gap into the D2 mission and measurable impact claim,
then define D3 one-month milestones and mismatch fixtures for evaluation.
