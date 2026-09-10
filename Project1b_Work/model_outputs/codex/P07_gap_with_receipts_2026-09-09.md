# Codex P07 -- The gap, with receipts

Model: GPT-5.6 Sol (Codex)  
Runner: Codex desktop  
Date: 2026-09-09  
Repository commit: `06f9dfe2280d6d1f6556d8e7609821c997c2c165` aka
"Support resources, standards, and licenses info"  
Prompt ID: P07  
Web access used: Yes  
Input files/context: `Project1a_Work/use_cases/usecases_final.md`,
`Project1a_Work/baseline.md`,
`Project1b_Work/inputs/product_context.md`,
`Project1b_Work/rivals/validated_rivals.md`,
`Project1b_Work/report/main.tex`, `Project1b_Work/report/references.bib`,
and current external sources listed below

## Exact prompt

```text
## Prompt 7 — The Gap, With Receipts

We are analyzing **WolfBite**, the software product our team inherited and evaluated during Project 1a for CSC 510. We are now preparing for Project 2 and need to critically evaluate whether the market gap identified during Project 1b is actually real and worth pursuing.

### Source Material

Before beginning:

1. Review the documentation within the project repository.
2. Use the finalized **Project 1a (`Proj1a`) use cases and product documentation** to understand WolfBite's current functionality.
3. Review the available **Project 1b (`Proj1b`) market analysis, competitor research, D1/D2/D3 material, prompt outputs, and related documentation**.
4. Identify the **market gap our team currently claims or is considering for Project 2**.
5. State that gap in **one clear sentence** before analyzing it.
6. Do not invent a market gap if the documentation does not clearly support one. If multiple possible gaps appear in the documentation, identify the strongest/currently favored one and note the ambiguity.

Do not modify any project files. This task is analysis only.

When external evidence is necessary, use current, verifiable public sources rather than relying only on assumptions or prior knowledge.

---

### 1. Claimed Market Gap

Use this format:

**Claimed Gap:**
[State the market gap in one clear sentence.]

**Project Evidence:**
Briefly explain where this gap comes from in the existing Project 1b analysis.

**Connection to WolfBite:**
Explain which existing Project 1a use cases, users, workflows, or capabilities make this gap relevant to WolfBite.

---

### 2. What Would Confirm the Gap?

Identify **five specific pieces of evidence** that would strengthen the claim that this gap is real.

Look for evidence such as:

* User reviews requesting the missing functionality
* Forum, Reddit, community, or support discussions describing the problem
* Competitor users complaining about missing or weak functionality
* Competitor documentation showing that the functionality is absent
* Competitor roadmaps repeatedly postponing or avoiding the functionality
* Discontinued or failed products that attempted to solve the same problem
* Workarounds users currently rely on because existing products do not solve the problem
* Industry reports or domain guidance identifying the unmet need

Use this exact table:

| # | Evidence to Confirm Gap | Status            | Source          | What It Shows | Strength                 |
| - | ----------------------- | ----------------- | --------------- | ------------- | ------------------------ |
| 1 | [Evidence sought]       | FOUND / NOT FOUND | [Source or N/A] | [Explanation] | STRONG / MODERATE / WEAK |
| 2 |                         |                   |                 |               |                          |
| 3 |                         |                   |                 |               |                          |
| 4 |                         |                   |                 |               |                          |
| 5 |                         |                   |                 |               |                          |

### Requirements

For each item:

* Mark it **FOUND** only if actual supporting evidence was located.
* Provide the source name and a live URL when available.
* Briefly explain what the evidence actually demonstrates.
* Do not treat a vague mention as proof of demand.
* If evidence cannot be found, mark it **NOT FOUND** rather than inventing support.
* Distinguish between evidence that users actively want something and evidence that a competitor simply does not provide it.

---

### 3. What Would Refute the Gap?

Actively search for evidence that the claimed gap is **wrong, overstated, already solved, or not valuable**.

Look specifically for:

* Existing products that already solve the claimed problem
* Competitor features our earlier analysis may have missed
* Newer product releases that close the gap
* Evidence that users do not care about the proposed functionality
* Reviews suggesting the problem is low priority
* Existing solutions that users are already satisfied with
* Evidence that similar features were attempted and abandoned because of weak demand
* Technical, legal, privacy, cost, or workflow barriers that make the gap impractical rather than genuinely unmet

Use this exact table:

| # | Evidence That Could Refute Gap | Status            | Source          | What It Shows | Strength                 |
| - | ------------------------------ | ----------------- | --------------- | ------------- | ------------------------ |
| 1 | [Evidence sought]              | FOUND / NOT FOUND | [Source or N/A] | [Explanation] | STRONG / MODERATE / WEAK |
| 2 |                                |                   |                 |               |                          |
| 3 |                                |                   |                 |               |                          |
| 4 |                                |                   |                 |               |                          |
| 5 |                                |                   |                 |               |                          |

Do not search only for evidence that supports our existing idea. The purpose of this section is to try to **disprove our own claim**.

---

### 4. Competitor Recheck

Revisit the rival products documented in Project 1b.

Use this table:

| Rival     | Does It Already Address the Gap? | Evidence                     | Impact on Gap Claim               |
| --------- | -------------------------------- | ---------------------------- | --------------------------------- |
| [Rival 1] | YES / PARTIALLY / NO / UNCERTAIN | [Source + brief explanation] | [Strengthens / Weakens / Neutral] |

Include every finalized rival from the Project 1b market analysis.

If a rival provides similar functionality under a different name, count the underlying behavior rather than relying on terminology alone.

Also identify any **new competitor discovered during this analysis** that materially changes the conclusion.

---

### 5. User-Demand Check

Evaluate whether there is evidence that actual users want the capability represented by the gap.

Organize findings into:

**Direct Evidence of Demand**

* [Users explicitly requesting or complaining about the missing capability]

**Indirect Evidence of Demand**

* [Workarounds, repeated pain points, related complaints, etc.]

**Evidence Against Demand**

* [Low adoption, negative reactions, lack of interest, discontinued attempts, etc.]

**Demand Assessment:**
**STRONG / MODERATE / WEAK / INSUFFICIENT EVIDENCE**

Briefly justify the rating.

Do not equate the absence of a feature with evidence that users want it.

---

### 6. Gap Verdict

Use exactly one of these classifications:

* **SUPPORTED** — Strong evidence indicates the gap is real and meaningful.
* **PLAUSIBLE BUT UNPROVEN** — Some evidence supports it, but more validation is needed.
* **WEAK** — Evidence for the gap is limited or contradictory.
* **REFUTED** — Existing products, weak demand, or other evidence indicates the claimed gap is not meaningful.

Then provide:

**Verdict:** [SUPPORTED / PLAUSIBLE BUT UNPROVEN / WEAK / REFUTED]

**Confidence:** [HIGH / MEDIUM / LOW]

**Why:**
Provide a concise 3–5 sentence explanation weighing the confirming evidence against the refuting evidence.

If the refuting evidence is stronger, **say so plainly**. Do not try to preserve the team's existing idea simply because it is already documented.

---

### 7. Project 2 Impact

Based on the evidence, complete this table:

| Question                                         | Recommendation   | Reason           |
| ------------------------------------------------ | ---------------- | ---------------- |
| Should Project 2 pursue this gap?                | YES / MAYBE / NO | [Why]            |
| Should the gap be narrowed or changed?           | YES / NO         | [Why]            |
| Is more validation needed before implementation? | YES / NO         | [Why]            |
| What is the strongest evidence supporting it?    | [Finding]        | [Why it matters] |
| What is the strongest evidence against it?       | [Finding]        | [Why it matters] |

If the gap appears weak or refuted, propose **one better direction** that follows naturally from the documented Project 1a and Project 1b findings.

Do not propose an unrelated replacement product.

---

### 8. Evidence Summary

End with a compact summary:

**Supporting Evidence Found:** X / 5
**Refuting Evidence Found:** X / 5
**Rivals Already Addressing Gap:** X
**Demand Assessment:** [Rating]
**Final Gap Verdict:** [Rating]

Then provide the **3 most important takeaways** for the team before finalizing Project 2 scope.

---

### 9. Sources

List every external source used in the analysis.

Use this format:

1. **Source/Organization:** [Name]
   **URL:** [Live URL]
   **Used For:** [What claim or finding it supports/refutes]

Do not list a source unless it was actually used.

---

### Important Rules

* Use the **documented Project 1a (`Proj1a`) use cases and functionality** as the authoritative description of the existing WolfBite product.
* Use the existing **Project 1b (`Proj1b`) documentation** to determine the team's current market-gap claim.
* Do not ask us to paste information that already exists in the project files.
* Do not invent a gap, competitor feature, user complaint, statistic, source, or URL.
* Clearly distinguish between **FOUND** and **NOT FOUND** evidence.
* A missing competitor feature alone does **not** prove a market gap; evidence of user need matters.
* Search specifically for information that could disprove the team's claim, not just confirm it.
* Treat functionally equivalent competitor features as equivalent even if they use different terminology.
* Prefer original or authoritative sources such as official product documentation, company roadmaps, support forums, app reviews, credible industry reports, and clearly attributable user discussions.
* Clearly label speculation or inference.
* If current evidence contradicts Project 1b's earlier analysis, state that explicitly.
* If the market gap is refuted, say so directly.
* Do not modify any project files.
* Keep the output concise, evidence-based, and consistently structured so results from multiple LLMs can be compared directly.
```

## Complete raw response

# Prompt 7 — The Gap, With Receipts

## 1. Claimed Market Gap

**Claimed Gap:**  
WIC participants whose app indicates an item is eligible but checkout rejects it lack an integrated, item-level workflow that connects the item, current benefit or category, and purchase evidence to likely causes and actionable next steps.

**Project Evidence:**  
This is the currently favored gap in the Project 1b D1 report and validated-rival analysis. Project 1b rejected nutrition comparison because participant demand was weak and rejected broad receipt reconciliation because WICShopper, myWIC Mosaic, and Bnft already provide purchase or transaction history; it then narrowed the opportunity to explanation and recovery when app and checkout evidence conflict.

**Connection to WolfBite:**  
The gap builds directly on UC5 Identify product, UC8 Add product to basket, UC12 Review basket, UC15 Add shopper-paid quantity, UC18 Review benefit balances, UC19 Prepare checkout handoff, and UC20 Finish shopping session. WolfBite already represents products, categories, planned quantities, and locally tracked benefits, but Project 1a found that lookup does not consistently establish eligibility and that checkout is not connected to a real point-of-sale result.

## 2. What Would Confirm the Gap?

| # | Evidence to Confirm Gap | Status | Source | What It Shows | Strength |
| - | ----------------------- | ------ | ------ | ------------- | -------- |
| 1 | Large multi-state evidence that app and register eligibility results conflict | FOUND | [UC Nutrition Policy Institute policy brief](https://ucanr.edu/program/nutrition-policy-institute/article/wic-app-modifications-needed-improve-wic-participants) | In a 2023 survey of 38,621 WIC participants, 64% reported misalignment between items labeled WIC-approved and what could be purchased at the register; focus-group participants also described the app saying an item was allowed and the register rejecting it. This demonstrates a substantial underlying problem, not necessarily demand for WolfBite's exact solution. | STRONG |
| 2 | A current participant report of an app-approved item failing at checkout | FOUND | [r/WIC: “WIC items suddenly not covered”](https://www.reddit.com/r/WIC/comments/1sbs4uw/wic_items_suddenly_not_covered/) | The participant reported scanning items in the app before shopping but having only two covered at checkout; replies describe retrying, taking photos, and seeking customer service. It is direct but anecdotal evidence. | MODERATE |
| 3 | User-centered research showing repeated eligibility conflicts, checkout problems, and workarounds | FOUND | [Weber et al., JMIR Formative Research](https://pmc.ncbi.nlm.nih.gov/articles/PMC8367138/) | Twenty-one of 22 participants described WIC shopping as difficult, 18 described checkout problems, and 10 described conflicting eligibility information; participants separated items, sought staff help, or photographed known products. | STRONG |
| 4 | Broad review evidence that scanner reliability and eligibility information remain persistent user problems | FOUND | [NLP study of WIC app reviews, 2013–2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC12755294/) | The study found that barcode scanning and real-time benefit tracking were valued but that technical and administrative burdens persisted. This supports reliable eligibility help, though not specifically a rule-based explanation engine. | MODERATE |
| 5 | Competitor documentation lacking a combined explanation-and-recovery workflow | FOUND | [WICShopper](https://doh.wa.gov/you-and-your-family/wic/shopping-wic/wicshopper-app), [myWIC Mosaic](https://apps.apple.com/us/app/mywic-mosaic/id1560485314), and [Bnft](https://apps.apple.com/us/app/bnft/id1286864895) | Their public documentation covers scanning, balances, purchases, history, or reporting, but it does not document one in-app flow that connects a rejected item and current benefit evidence to likely causes and recovery steps. This establishes a documented feature gap, not user demand. | MODERATE |

## 3. What Would Refute the Gap?

| # | Evidence That Could Refute Gap | Status | Source | What It Shows | Strength |
| - | ------------------------------ | ------ | ------ | ------------- | -------- |
| 1 | An existing WIC program already explains app/checkout conflicts and gives recovery actions | FOUND | [Minnesota WIC: Help with Common Checkout Issues](https://www.health.mn.gov/people/wic/vendor/checkout.html) | Minnesota explicitly covers the case where its app says an item is allowed but checkout rejects it, then explains possible benefit-registration, package, produce-mapping, and transaction causes and gives next steps. The guidance is outside the app and not automatically item-specific, but it addresses the underlying behavior. | STRONG |
| 2 | A leading rival already combines purchase evidence with a problem-reporting path | FOUND | [Colorado WICShopper resources](https://www.coloradowic.gov/about/WICShopper-information-and-resources) | WICShopper provides detailed purchase history and an “I Couldn't Buy This” feature for reporting problem products. It does not provide immediate automated diagnosis, but it covers important parts of evidence collection and recovery. | STRONG |
| 3 | A rival already supports transaction dispute and eligibility checks | FOUND | [New York eWIC and ebtEDGE](https://www.health.ny.gov/prevention/nutrition/wic/ewic/?os=android) | ebtEDGE provides balance, eligibility scanning, transaction history, and a transaction-dispute path. Public documentation does not show a linked item-level explanation, but this meaningfully narrows the gap. | MODERATE |
| 4 | Earlier market research found that a WIC app already offered redemption-dispute functionality | FOUND | [Review of WIC mobile-app features](https://pmc.ncbi.nlm.nih.gov/articles/PMC6277824/) | A review of 17 WIC apps found one transaction-dispute function for users who disagreed with or did not understand why an item could not be redeemed. The capability is uncommon, not wholly unprecedented. | MODERATE |
| 5 | Trust, privacy, and integration constraints make a third-party diagnosis impractical | FOUND | [California Department of Social Services ebtEDGE guidance](https://www.cdss.ca.gov/inforesources/cdss-programs/ebt/ebtedge) | California warns participants to use official state-supported benefit apps because third-party apps may expose benefit data and state agencies may be unable to help when they fail. This does not disprove the need, but it is strong counterevidence to deploying WolfBite as an authoritative live-data solution. | STRONG |

## 4. Competitor Recheck

The Project 1b validation retained 16 qualifying products: 11 direct or legacy WIC rivals and five adjacent grocery products. All are included below.

| Rival | Does It Already Address the Gap? | Evidence | Impact on Gap Claim |
| ----- | -------------------------------- | -------- | ------------------- |
| WICShopper | PARTIALLY | [Washington WIC](https://doh.wa.gov/you-and-your-family/wic/shopping-wic/wicshopper-app) documents balance-aware scanning and “I Couldn't Buy This”; [Colorado WIC](https://www.coloradowic.gov/about/WICShopper-information-and-resources) documents detailed redemption history and problem reporting. No immediate cause-and-recovery explanation is documented. | Weakens |
| Bnft | UNCERTAIN | Its [App Store listing](https://apps.apple.com/us/app/bnft/id1286864895) documents benefit-aware scanning, real-time balances, and up to a year of transaction history, but not rejection explanations. Absence from a listing is insufficient to conclude the capability does not exist. | Neutral |
| myWIC Mosaic | UNCERTAIN | Its [App Store listing](https://apps.apple.com/us/app/mywic-mosaic/id1560485314) documents benefits, purchase tracking, a shopping guide, and scanning, but not item-level rejection recovery. | Neutral |
| ebtEDGE | PARTIALLY | [New York WIC](https://www.health.ny.gov/prevention/nutrition/wic/ewic/?os=android) documents eligibility scanning, history, and transaction disputes, but not a linked explanation based on the affected item and benefit category. | Weakens |
| California WIC App | NO | [California WIC](https://myfamily.wic.ca.gov/Home/WICCardAndApp) documents balances, expiration dates, and food scanning. It does not document post-rejection explanation or recovery. | Strengthens, modestly |
| EzWIC | NO | The [Arizona Department of Health Services brochure](https://www.azdhs.gov/documents/prevention/azwic/exwic-appbroucher-eng.pdf) documents balances, approved-food lists, and in-store scanning, but no checkout-mismatch recovery. | Strengthens, modestly |
| WIC Connect | PARTIALLY | [Michigan WIC](https://www.michigan.gov/mdhhs/-/media/Project/Websites/mdhhs/Assistance-Programs/WIC-Media/Vendor-Promotional-Materials/WIC-Connect-Mobile-Clings.pdf) documents distinct scan results for WIC eligible, not in current benefits, and not eligible. This explains some pre-checkout conflicts but not an actual register disagreement. | Weakens |
| Florida WIC App | PARTIALLY | [Florida Department of Health](https://www.floridahealth.gov/individual-family-health/womens-health/wic/florida-wic-mobile-app/) documents scanning and submission of foods for WIC approval. Reporting is a recovery path, but no immediate diagnosis is documented. | Weakens |
| Maryland WIC App | NO | [Maryland Department of Health](https://health.maryland.gov/phpa/wic/Pages/how_to_use_WIC.aspx) documents UPC scanning against approval and the household's benefits, but not post-checkout explanation or recovery. | Strengthens, modestly |
| WIC2Go | UNCERTAIN | [New York WIC](https://www.health.ny.gov/prevention/nutrition/wic/ewic/?os=android) now labels WIC2Go as available only to current users and directs shoppers to ebtEDGE. No current WIC2Go mismatch workflow was established. | Neutral |
| Minnesota WIC App | PARTIALLY | [Minnesota WIC](https://www.health.mn.gov/people/wic/vendor/checkout.html) publishes exact causes and next steps for app-allowed items rejected at checkout. The guidance is not shown as integrated into the app or automatically connected to the selected item. | Weakens substantially |
| Ibotta (adjacent) | NO | [Ibotta](https://home.ibotta.com/) processes offers and receipts for cash back, not WIC eligibility conflicts. | Neutral |
| Fetch Rewards (adjacent) | NO | [Fetch](https://fetch.com/receipt-scanning) turns receipts into rewards rather than explaining WIC benefit rejection. | Neutral |
| Checkout 51 (adjacent) | NO | [Checkout 51](https://www.checkout51.com/how-it-works) validates purchased offer items for cash back, not WIC eligibility or benefit mismatches. | Neutral |
| Out of Milk (adjacent) | NO | [Out of Milk](https://www.outofmilkapp.com/features) manages grocery lists and barcode item entry but not WIC benefits or checkout rejection. | Neutral |
| AnyList (adjacent) | NO | [AnyList](https://www.anylist.com/features) supports lists, recipes, and meal planning but not WIC eligibility or checkout recovery. | Neutral |

**New competitor:** [Lulo: WIC Shopping](https://apps.apple.com/us/app/lulo-wic-shopping/id6636156582) is a current WIC-focused app not included in the Project 1b finalized list. It documents approved-product discovery, balances in selected states, and barcode scanning; its public listing does not establish checkout-mismatch explanation, and one review reports incorrect scanner results. It expands the crowded eligibility-prevention market but does not materially refute or confirm the narrower explanation-and-recovery gap.

## 5. User-Demand Check

**Direct Evidence of Demand**

* The UC Nutrition Policy Institute's multi-state evidence reports that 64% of surveyed participants experienced disagreement between WIC-approved labels and what the register would accept. Focus-group participants explicitly described the app approving an item and checkout rejecting it.
* Recent r/WIC discussions describe shoppers scanning items in advance, seeing them rejected, retrying transactions, photographing products, seeking customer service, and asking why the discrepancy occurred.
* App Store reviews for WICShopper, myWIC Mosaic, Bnft, and Lulo complain about products being incorrectly classified or scanners becoming unusable. These are direct complaints about unreliable eligibility information, although they are not all explicit requests for a separate explanation feature.

**Indirect Evidence of Demand**

* Weber et al. found repeated checkout problems, conflicting eligibility information, and workarounds such as separating transactions, shopping with experienced participants, seeking staff help, and photographing products.
* Chauvenet et al. connected poor WIC labeling and negative checkout experiences to stigma and failure to use all benefits.
* The existence and continued enhancement of WICShopper's “I Couldn't Buy This,” state checkout-troubleshooting pages, and ebtEDGE disputes suggests that agencies already need mechanisms for unresolved purchase problems.

**Evidence Against Demand**

* No reviewed study asked participants whether they specifically want an automated, rule-based explanation-and-recovery workflow, rather than a better scanner, live balance, chat, or human support.
* In the 2023 multi-state survey, the most requested app changes included expiration reminders, ordering or pickup information, eligibility scanning, chat, balances, and self-checkout information; a diagnosis engine was not separately identified.
* WICShopper, myWIC Mosaic, Bnft, and Lulo have high overall App Store ratings, suggesting that existing scanning-and-balance workflows satisfy many users. Ratings do not establish satisfaction with checkout mismatch handling.

**Demand Assessment:**  
**MODERATE**

The underlying eligibility-conflict problem has strong, current, multi-state evidence. Demand for WolfBite's particular solution is only moderate because users clearly ask for reliable eligibility and help, but the reviewed evidence does not show that they prefer an automated explanation workflow over improved scanner accuracy, live benefit integration, chat, reporting, or agency assistance.

## 6. Gap Verdict

**Verdict:** PLAUSIBLE BUT UNPROVEN

**Confidence:** MEDIUM

**Why:**  
Large-sample and qualitative evidence shows that app/register misalignment is real, common, and consequential. No reviewed rival documents the complete integrated workflow WolfBite proposes. However, Minnesota already publishes explanations and recovery steps for the exact conflict, while WICShopper, ebtEDGE, WIC Connect, and Florida WIC provide reporting, disputes, reason distinctions, or other partial recovery behavior. The problem is supported more strongly than the proposed solution, so Project 2 still needs direct validation before treating this as a proven market gap.

## 7. Project 2 Impact

| Question | Recommendation | Reason |
| -------- | -------------- | ------ |
| Should Project 2 pursue this gap? | MAYBE | Pursue only a bounded prototype and validation study; do not commit to live WIC or point-of-sale integration. |
| Should the gap be narrowed or changed? | YES | Focus on a small set of understandable scenarios—wrong package or size, insufficient current benefit, unregistered card context, stale APL data, and retailer mapping—while labeling causes as possibilities rather than authoritative diagnoses. |
| Is more validation needed before implementation? | YES | Test whether participants can choose a correct next action faster or with less uncertainty than when given a scan result plus ordinary help/reporting links. |
| What is the strongest evidence supporting it? | 64% of 38,621 surveyed participants reported WIC-label/register misalignment | It demonstrates that the underlying problem is substantial and not based on a few reviews. |
| What is the strongest evidence against it? | Minnesota already publishes cause-and-recovery guidance, and WICShopper/ebtEDGE offer partial recovery paths | WolfBite must improve on existing guidance and reporting rather than merely reproducing them. |

Because the verdict is not WEAK or REFUTED, no replacement direction is required. A prudent fallback, if validation fails, is to improve WolfBite's pre-checkout eligibility transparency—source, jurisdiction, package match, balance context, and data freshness—which follows directly from the same Project 1a failures without claiming to diagnose checkout.

## 8. Evidence Summary

**Supporting Evidence Found:** 5 / 5  
**Refuting Evidence Found:** 5 / 5  
**Rivals Already Addressing Gap:** 0 fully; 5 partially  
**Demand Assessment:** MODERATE  
**Final Gap Verdict:** PLAUSIBLE BUT UNPROVEN

1. Validate the proposed response, not merely the problem: app/register mismatch is established, but preference for WolfBite's explanation workflow is not.
2. The differentiator must be the integrated, item-specific, uncertainty-aware experience; generic scanning, FAQ guidance, history, reporting, and disputes already exist.
3. Keep the M0 prototype synthetic and bounded, measure next-action task success against a baseline, and use failure to outperform existing guidance as a kill signal.

## 9. Sources

1. **Source/Organization:** UC Nutrition Policy Institute, University of California Agriculture and Natural Resources  
   **URL:** https://ucanr.edu/program/nutrition-policy-institute/article/wic-app-modifications-needed-improve-wic-participants  
   **Used For:** Multi-state participant evidence about app/register misalignment and desired app changes.

2. **Source/Organization:** Weber et al., *JMIR Formative Research*  
   **URL:** https://pmc.ncbi.nlm.nih.gov/articles/PMC8367138/  
   **Used For:** User-centered evidence about checkout problems, conflicting eligibility information, feature priorities, and participant workarounds.

3. **Source/Organization:** Chauvenet et al., *Journal of the Academy of Nutrition and Dietetics*  
   **URL:** https://doi.org/10.1016/j.jand.2018.09.003  
   **Used For:** Evidence connecting labeling problems and negative checkout experiences to stigma and unused benefits.

4. **Source/Organization:** *Effectiveness of Digital Interventions for Low-Income, Food-Insecure Populations*  
   **URL:** https://pmc.ncbi.nlm.nih.gov/articles/PMC12755294/  
   **Used For:** Review evidence about valued scanner/balance functions and persistent technical or administrative burdens.

5. **Source/Organization:** r/WIC participant discussion, “WIC items suddenly not covered”  
   **URL:** https://www.reddit.com/r/WIC/comments/1sbs4uw/wic_items_suddenly_not_covered/  
   **Used For:** Recent direct report of app-approved items failing at checkout and participant workarounds.

6. **Source/Organization:** Washington State Department of Health, WICShopper App  
   **URL:** https://doh.wa.gov/you-and-your-family/wic/shopping-wic/wicshopper-app  
   **Used For:** WICShopper scanning, benefit-awareness, limitations, and “I Couldn't Buy This” functionality.

7. **Source/Organization:** Colorado Department of Public Health and Environment, WICShopper Resources  
   **URL:** https://www.coloradowic.gov/about/WICShopper-information-and-resources  
   **Used For:** WICShopper redemption-history and problem-reporting counterevidence.

8. **Source/Organization:** Apple App Store, WICShopper  
   **URL:** https://apps.apple.com/us/app/wicshopper/id614569159  
   **Used For:** Current product scope, user reviews, ratings, and supported-program limitations.

9. **Source/Organization:** Apple App Store, myWIC Mosaic  
   **URL:** https://apps.apple.com/us/app/mywic-mosaic/id1560485314  
   **Used For:** Current myWIC benefits, purchase tracking, scanner, reviews, and ratings.

10. **Source/Organization:** Apple App Store, Bnft  
    **URL:** https://apps.apple.com/us/app/bnft/id1286864895  
    **Used For:** Bnft balance-aware scanning, transaction history, user reviews, and ratings.

11. **Source/Organization:** New York State Department of Health, eWIC and ebtEDGE  
    **URL:** https://www.health.ny.gov/prevention/nutrition/wic/ewic/?os=android  
    **Used For:** ebtEDGE scanning, transaction history, transaction dispute, and WIC2Go legacy status.

12. **Source/Organization:** California WIC Program  
    **URL:** https://myfamily.wic.ca.gov/Home/WICCardAndApp  
    **Used For:** California WIC App scanning and benefit features.

13. **Source/Organization:** Arizona Department of Health Services, EzWIC brochure  
    **URL:** https://www.azdhs.gov/documents/prevention/azwic/exwic-appbroucher-eng.pdf  
    **Used For:** EzWIC balances, scanning, food-list, clinic, and vendor features.

14. **Source/Organization:** Michigan Department of Health and Human Services, WIC Connect  
    **URL:** https://www.michigan.gov/mdhhs/-/media/Project/Websites/mdhhs/Assistance-Programs/WIC-Media/Vendor-Promotional-Materials/WIC-Connect-Mobile-Clings.pdf  
    **Used For:** WIC Connect's distinct WIC-eligible, not-in-benefits, and not-eligible scan results.

15. **Source/Organization:** Florida Department of Health, Florida WIC Mobile App  
    **URL:** https://www.floridahealth.gov/individual-family-health/womens-health/wic/florida-wic-mobile-app/  
    **Used For:** Florida scanning, benefit information, and food-submission functionality.

16. **Source/Organization:** Maryland Department of Health, How to Use WIC  
    **URL:** https://health.maryland.gov/phpa/wic/Pages/how_to_use_WIC.aspx  
    **Used For:** Maryland WIC App UPC and household-benefit checking.

17. **Source/Organization:** Minnesota Department of Health, Help with Common Checkout Issues  
    **URL:** https://www.health.mn.gov/people/wic/vendor/checkout.html  
    **Used For:** Direct counterevidence: explanations and recovery guidance for app/checkout conflicts.

18. **Source/Organization:** Ibotta  
    **URL:** https://home.ibotta.com/  
    **Used For:** Confirming that the adjacent product handles offers and receipt-based rewards, not WIC mismatch recovery.

19. **Source/Organization:** Fetch  
    **URL:** https://fetch.com/receipt-scanning  
    **Used For:** Confirming that the adjacent product converts receipts to rewards, not WIC explanations.

20. **Source/Organization:** Checkout 51  
    **URL:** https://www.checkout51.com/how-it-works  
    **Used For:** Confirming its receipt-validation and cash-back scope.

21. **Source/Organization:** Out of Milk  
    **URL:** https://www.outofmilkapp.com/features  
    **Used For:** Confirming grocery-list and barcode-entry scope.

22. **Source/Organization:** AnyList  
    **URL:** https://www.anylist.com/features  
    **Used For:** Confirming list, recipe, and meal-planning scope.

23. **Source/Organization:** Review and Analysis of WIC Mobile-App Features  
    **URL:** https://pmc.ncbi.nlm.nih.gov/articles/PMC6277824/  
    **Used For:** Counterevidence that transaction-dispute functionality existed in at least one reviewed WIC app.

24. **Source/Organization:** California Department of Social Services, ebtEDGE Guidance  
    **URL:** https://www.cdss.ca.gov/inforesources/cdss-programs/ebt/ebtedge  
    **Used For:** Security, privacy, trust, and support barriers affecting third-party benefit applications.

25. **Source/Organization:** Apple App Store, Lulo: WIC Shopping  
    **URL:** https://apps.apple.com/us/app/lulo-wic-shopping/id6636156582  
    **Used For:** New-competitor check, current feature scope, ratings, and a scanner-reliability complaint.
