# Prompt-by-model comparison

## Market survey (P01)

| Model | Most useful result | Weakness/error | Rivals proposed | Rivals surviving validation |
|---|---|---|---:|---:|
| Codex | Identified ten real, direct WIC-shopping rivals with live evidence URLs and warned that missing features in short product summaries do not establish a market gap | Mixed platform-level products with state-specific apps that may share vendors or infrastructure; detailed scope and price claims still required independent checking | 10 | 10 |
| ChatGPT Terra | Identified ten mostly direct state WIC applications and highlighted geographic and program fragmentation | Supplied source descriptions rather than URL strings; three Terra-only candidates therefore failed the team's evidence rule | 10 | 7 |
| Gemini | Corroborated WICShopper, Bnft, myWIC Mosaic, and several state applications with relevant product or government links | Returned seven products rather than ten and stated several weakness claims that the supplied product listings did not establish | 7 | 7 |
| Local Ollama | Identified WICShopper and exposed how a non-browsing local model broadens the answer toward adjacent grocery, rebate, and list applications | Supplied several dead, irrelevant, or unverified URLs; most candidates were not direct WIC rivals, and some receipt-scanning claims were unsupported | 10 | 6 qualifying; 1 direct |

## Red team (P10)

| Model | Strongest attack | Evidence needed to defeat it | Team response | Weakness/error |
|---|---|---|---|---|
| Codex | | | | |
| ChatGPT Terra | Argued that WolfBite is structurally disadvantaged because state WIC agencies, EBT processors, retailers, and POS systems control the authoritative eligibility, balance, and transaction data that WolfBite lacks. | A jurisdiction-specific competitor audit, evidence that authoritative systems do not provide useful rejection explanations, a credible future integration/data path, and comparative testing showing WolfBite improves users' next-step decisions. | Keep WolfBite positioned as a bounded prototype that explains possible causes rather than claiming authoritative checkout decisions; use fixed mismatch scenarios and evaluate whether the recovery workflow actually improves task success. | Terra broadened the competitor attack beyond user-facing apps to agencies, EBT processors, retailers, and POS systems. This is a useful structural threat, but those systems are not directly comparable products in the same sense as WICShopper, myWIC Mosaic, or Bnft. |
| Gemini | | | | |
| Local Ollama | | | | |

## Reflection

- Prompt 1 was useful for candidate generation and cross-model corroboration,
  but no model's response was accepted as final market evidence. The strongest
  output still required normalization, live-source checks, and separation of
  direct rivals from adjacent products.
- Most/least useful prompt judgment: **TODO — awaiting team input.** Compare
  the completed, common-version Prompt 10 runs before making the final choice.
- Codex strength/weakness from P01: strongest source completeness and explicit
  uncertainty warning, but an overbroad mix of platform and state-level rivals.
- ChatGPT Terra strength/weakness from P01: strong direct-WIC focus and useful
  fragmentation theme, but it did not provide the requested URL strings.
- Gemini strength/weakness from P01: relevant corroborating candidates and
  links, but incomplete row count and unsupported failure-frequency claims.
- Local Ollama strength/weakness from P01: useful evidence of local-model
  limitations and one normalized direct rival, but no live verification and
  many irrelevant or unsupported candidates and claims.
