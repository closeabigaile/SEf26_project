# Complaint corpus

Required to collect real evidence before running
Prompt 2. The complaints must come from traceable sources rather than being
invented by an LLM.

| ID | Rival product | Complaint excerpt | Source URL | Source type | Date accessed | Notes |
|---|---|---|---|---|---|---|
| C01 | WICShopper | "doesn’t always show everything that’s available" | https://apps.apple.com/us/app/wicshopper/id614569159?platform=iphone&see-all=reviews | Apple App Store review | 2026-09-03 | Scanner coverage complaint; listing displays the review as May 23 without a year. Self-reported, so it establishes user experience rather than root cause. |
| C02 | WICShopper | "approved that isn’t actually approved" | https://apps.apple.com/us/app/wicshopper/id614569159?platform=iphone&see-all=reviews | Apple App Store review | 2026-09-03 | Reviewer describes a package-size mismatch at checkout; listing displays May 4 without a year. |
| C03 | WICShopper | "my benefits have expired" | https://apps.apple.com/us/app/wicshopper/id614569159?platform=iphone&see-all=reviews | Apple App Store review | 2026-09-03 | Reviewer reports an incorrect beginning-of-month status until the card is used; listing displays June 1 without a year. |
| C04 | WICShopper | "item descriptions are generic" | https://play.google.com/store/apps/details?id=com.jpma.EBTShopper | Google Play review | 2026-09-03 | Dated 2026-06-29; reviewer says poor search descriptions increase in-store shopping time. |
| C05 | Bnft | "logs me out multiple times" | https://apps.apple.com/us/app/bnft/id1286864895 | Apple App Store review | 2026-09-03 | The listing displays March 22 without a year. Same review as C06; count it as one independent reviewer when measuring frequency. |
| C06 | Bnft | "unknown error please try again" | https://apps.apple.com/us/app/bnft/id1286864895 | Apple App Store review | 2026-09-03 | Scanner failure reported in the C05 review after update/reinstall troubleshooting. |
| C07 | Bnft | "log in sometimes up to three times" | https://apps.apple.com/us/app/bnft/id1286864895 | Apple App Store review | 2026-09-03 | Review dated 2025-11-07 describes repeated login plus text verification during one shopping trip. |
| C08 | Bnft | "Cannot update phone number" | https://apps.apple.com/us/app/bnft/id1286864895 | Apple App Store review | 2026-09-03 | Review dated 2023-08-29 describes account lockout after loss of the old number; older report with no current resolution established. |
| C09 | myWIC Mosaic | "scanner stopped working" | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 | Apple App Store review | 2026-09-03 | Review dated 2025-08-27 reports that reinstalling restored the scanner; this is a workaround, not proof of a current universal failure. |
| C10 | myWIC Mosaic | "eligible items comes back ineligible" | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 | Apple App Store review | 2026-09-03 | Updated 2024-06-06 review says the scanner was repaired after roughly two months, so this incident is marked resolved. |
| C11 | myWIC Mosaic | "schedule Wic appointments ... not an available option" | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 | Apple App Store review | 2026-09-03 | Review dated 2025-01-30; may depend on clinic/program configuration rather than only the app. |
| C12 | myWIC Mosaic | "none of them will register" | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 | Apple App Store review | 2026-09-03 | Same C11 reviewer reports failed baby/pregnancy status changes. Treat C11 and C12 as one independent reviewer in frequency claims. |

## Corpus limitations

- These are 12 issue observations from ten independent reviewers, not 12
  independent people.
- App-store reviews are direct evidence that users reported a problem, but do
  not by themselves prove the technical cause or current prevalence.
- C08 is older, C10 was later reported fixed, and C09 has a reinstall
  workaround. They remain useful history but must not be described as confirmed
  current defects.
- Reviews shown without a year are recorded exactly that way rather than
  assigning a guessed year.
