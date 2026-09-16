# Prompt-by-model comparison

This file separates model suggestions from verified facts and the team's final
judgment. Raw outputs remain unchanged under `Project1b_Work/model_outputs/`;
product and feature claims were checked in `Project1b_Work/rivals/` before they
were used in the report.

## Prompt 1 -- market survey

| Model | Most useful result | Weakness or error | Rivals proposed | Result after verification |
|---|---|---|---:|---|
| Codex | Supplied ten relevant candidates with live URLs and warned that a missing feature in a product summary does not prove a market gap | Mixed platform products with state-specific applications that may share infrastructure; detailed scope and price claims still needed checking | 10 | All ten qualified under the one-model-plus-live-URL branch, but only the strongest direct rivals were used for D1 |
| ChatGPT Terra | Concentrated on direct WIC applications and exposed state/program fragmentation | Supplied source labels rather than URL strings; three Terra-only candidates could not qualify | 10 | Seven were corroborated or separately verified; Indiana WIC, Wisconsin MyWIC, and SC WIC Mobile App were excluded |
| Gemini | Corroborated WICShopper, Bnft, myWIC Mosaic, and several state applications with relevant links | Returned seven products rather than ten and attached weakness claims not established by its linked pages | 7 | All seven product identities survived, but unsupported failure-frequency claims were discarded |
| Local Ollama | Named WICShopper and showed how a non-browsing model expands toward adjacent grocery/rebate tools | Supplied dead, irrelevant, or unverified links; most candidates were not direct WIC rivals, and some receipt-scanning claims were unsupported | 10 | Six products met the literal URL rule, but only normalized WICShopper was a direct rival |

### Overlap and final judgment

- **Model suggestions:** WICShopper appeared in all four outputs after
  normalizing Ollama's `WIC Shopper`; myWIC Mosaic appeared in three after
  normalizing Terra's `myWIC`; Bnft appeared in Codex and Gemini. California
  WIC App, Florida WIC App, and WIC Connect also had three-model overlap.
- **Verified facts:** A candidate survived when two models named it or one
  model supplied a live, relevant URL. A separate feature audit checked what
  each product actually documented; a live product page did not automatically
  verify every strength, weakness, price, or missing feature in a model answer.
- **Team judgment:** WICShopper, myWIC Mosaic, and Bnft are the strongest final
  direct rivals. ebtEDGE and several state applications remain useful secondary
  comparisons. Adjacent rebate/list products were not treated as direct rivals,
  and unsupported Terra/local candidates were rejected.

The models' disagreement was useful: the browsing runs produced a stronger
direct-rival set, while the local run exposed why URL existence, product scope,
and feature claims must be checked separately. Prompt 1 generated candidates;
it did not itself establish the selected market gap.

## Prompt 10 -- red-team comparison

All four outputs addressed market need, one-month feasibility, and competitor
advantage. They agreed that user demand for checkout-time recovery is not yet
directly demonstrated, the five-milestone plan has scope risk, and WolfBite
lacks the authoritative data available to deployed WIC systems. They differed
in severity and in what they considered the strongest competitor.

| Model | Strongest attack | Evidence needed to defeat it | Team response | Weakness or unsupported point |
|---|---|---|---|---|
| Codex | The evidence supports checkout friction but not demand for this exact workflow; M1--M3 may crowd out the M4-to-M0 critical path | Direct participant/staff evidence, a fair counterbalanced M0 study, current rival workflow checks, and an owner/hour plan | Treat the proposal as an evaluation-first prototype; prioritize M4 and M0 and defer secondary scope if the critical path slips | Could not directly inspect deployed rivals or users; its conclusion remains conditional on evidence the team has not yet collected |
| ChatGPT Terra | Agencies, EBT processors, retailers, and POS systems own the authoritative evidence WolfBite lacks; the roadmap also devotes most effort outside the stated mission | Jurisdiction-specific capability checks, evidence that official systems lack usable explanations, a credible future data path, and comparative testing | Keep all checkout claims non-authoritative, use fixed scenarios, make M4/M0 the critical path, and treat live integration as Future work | Correctly identified a structural dependency, but broadened “competitor” to include institutions and infrastructure rather than only competing software products |
| Gemini | The plan is over-scoped for roughly 160 hours and WICShopper is better positioned because it uses program-connected data | A detailed work breakdown, evidence that M1--M3 are small extensions, direct user research, and live-rival workflow evidence | Preserve the agreed milestones in bounded form, with explicit completion tests and a cut order protecting M4/M0 | Calling the plan “impossible” and requiring abandonment of M1--M3 was stronger than the evidence; the response supplied no measured effort breakdown |
| Local Ollama | Established rivals have more development, testing, and adoption, so WolfBite needs a clear differentiator | User interviews, an owner-assigned schedule, and a detailed rival-feature audit | Retain the medium-confidence gap and require M0 to test usefulness rather than assuming it | The attacks were generic, the “edge case” claim was unsupported, the M1--M3 scope conflict was missed, and the saved rerun did not include its exact prompt |

### Supported concerns, disagreements, and team conclusion

- The **market-need criticism is partly supported**: participant research
  verifies eligibility difficulty and checkout stigma, but not that shoppers
  will use a non-authoritative recovery screen at the register. M0 is intended
  to test that question; its targets are not achieved results.
- The **feasibility criticism is supported as a risk**, not as proof of
  failure. The existing code, tests, and bounded mock data reduce build effort,
  but M2 and broad interface polish cannot be allowed to delay the M4-to-M0
  vertical slice, regression testing, or evaluation.
- The **competitor criticism is supported structurally**: WICShopper, myWIC
  Mosaic, Bnft, and official transaction systems possess data WolfBite lacks.
  It does not refute the narrower finding that their reviewed public material
  does not document one integrated explanation-and-recovery workflow.
- Gemini recommended removing M1--M3; Codex and Terra instead defended a
  bounded evaluation-first prototype with a cut order. Ollama did not recommend
  a pivot. The team adopts the latter position because no transcript supplies
  evidence that the selected gap is refuted or that the bounded features are
  individually impossible.

**Team conclusion:** Prompt 10 did not reveal a reason to abandon or pivot from
WolfBite. It did reveal a reason to protect and narrow execution: M4 and M0 are
the critical path, M1--M3 remain bounded supporting improvements, and secondary
scope is deferred if the core flow slips. The main remaining risk is unproven
participant demand combined with the absence of authoritative checkout data.
The available evidence still supports proceeding with Project 2 as a simulated,
evaluation-first prototype, not as a production or superiority claim.

## Concrete errors and how they were caught

- **Gemini P01 returned seven rivals, not ten.** The team counted its raw table
  rows and did not invent replacements. Its scanner/login/reinstall claims were
  not established by the linked product pages, so those claims were discarded.
- **Terra P01 supplied source labels instead of URLs.** Direct inspection of
  the evidence column meant its three uncorroborated candidates failed the
  team's qualification rule.
- **Local P01 supplied unsupported candidates and features.** Live URL and
  scope checks rejected FreshConnect, generic `WIC Mobile App`, StoreWise, and
  Grocery IQ; product pages did not support its receipt-scanning claims for Out
  of Milk or AnyList.
- **The first team note about local P01 was also wrong.** It said the local run
  had zero Terra overlap and treated the WICShopper URL as fabricated. Name
  normalization and the live redirect showed that `WIC Shopper` was the same
  real product, so WICShopper was credited to all four models.
- **Gemini P10 overstated feasibility evidence.** Its “impossible” verdict was
  compared with the inherited code/test baseline and the bounded milestone
  definitions. The risk was retained, but the unsupported certainty and demand
  to abandon three agreed milestones were rejected.
- **Local P10 called mismatch recovery an edge case without prevalence data.**
  The claim was treated as an attack to test, not a finding; M0 and future user
  evidence remain necessary.

## Per-model reflection

- **Codex -- Strength:** strongest source completeness and careful distinction
  between a documented problem and a validated solution. **Weakness:** verbose,
  broad candidate sets and conclusions still dependent on external validation.
- **ChatGPT Terra -- Strength:** strongest mission-versus-roadmap and
  authoritative-data critique. **Weakness:** incomplete P01 URL evidence and a
  P10 competitor category broader than software products.
- **Gemini -- Strength:** concise, forceful scope and user-demand challenge.
  **Weakness:** incomplete P01 output and overconfident P10 feasibility verdict.
- **Local Ollama -- Strength:** completed the required attack structure locally
  and named the verified rivals in P10. **Weakness:** weak factual reliability
  without browsing and a shallow, incompletely preserved P10 rerun.

## Most and least useful prompts

- **Most useful:** P07 (focused gap validation) forced the team to separate
  competitor-feature absence from participant demand, reject nutrition
  comparison and broad receipt reconciliation as the primary gaps, and retain
  only a medium-confidence explanation-and-recovery gap. P10 was similarly
  useful because three independent runs exposed the same scope and validation
  risks and produced the M4/M0 priority rule.
- **Useful but limited:** P01 was essential for rival discovery and
  cross-model corroboration, but every answer required independent checking.
- **Least useful for the final decision:** P06 (three futures) generated SAFE,
  BOLD, and WILD concepts, including OCR- and community-based directions, but
  those speculative concepts supplied no market validation and did not decide
  the final gap or one-month plan. It remained useful as ideation, not evidence.
