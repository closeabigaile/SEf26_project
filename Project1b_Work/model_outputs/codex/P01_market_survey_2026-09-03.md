# Codex P01 -- Market survey

- Model: GPT-5.6 Sol (Codex)
- Runner: Codex desktop
- Date: 2026-09-03
- Repository baseline: `c9daaac307b3` (`Project1b setup`)
- Prompt ID: P01
- Web access used: Yes
Input files/context: `Project1b_Work/inputs/product_context.md` and verified
Project 1a findings

## Exact prompt

```text
You are a market analyst. Our product, in one paragraph:

WolfBite is a cross-platform Flutter/Firebase shopping assistant for WIC
participants. It lets authenticated shoppers identify products through barcode
scanning or manual UPC entry, review nutrition information, compare healthier
alternatives, manage a basket against WIC category allowances, import products
recognized from receipts, review benefit balances, and generate a QR-based
checkout handoff. Project 1a found that the application has useful shopping and
benefit-management features but also has inconsistent behavior around
eligibility, shopper-paid overflow, missing nutrition data, receipt importing,
persistence failures, and checkout interoperability.

Hard constraint: our four-student team has one month to build AND test the new
product, with approximately ten hours per student per week.

List the ten closest competing products. Output a table: product | who uses
it | main strength | main weakness | price | evidence URL.

Rules: no invented products. If you are not sure a product exists, leave it
out. If you cannot support a claim, write "unknown" -- do not fill the cell
with something plausible.
```

## Complete raw response

| Product | Who uses it | Main strength | Main weakness | Price | Evidence URL |
|---|---|---|---|---|---|
| WICShopper | WIC participants in supported state and tribal programs | Broad WIC shopping coverage with real-time benefit balances and benefit-aware barcode scanning; JPMA also documents online-ordering and delivery deployments | It does not work outside supported WIC programs, and capabilities vary by agency | Free | https://apps.apple.com/us/app/wicshopper/id614569159 |
| Bnft | SNAP and WIC cardholders in supported programs, including North Carolina and Illinois WIC | Combines real-time balances, transaction/card management, store location, and a WIC scanner that checks both approval and available benefits | The current listing documents limited WIC-program availability | Free | https://apps.apple.com/us/app/bnft/id1286864895 |
| myWIC Mosaic | WIC participants in Texas, Louisiana, New Mexico, and listed tribal programs | Connects the shopping guide and scanner with benefits, purchase tracking, appointments, document upload, and certification tasks | Availability is limited to the WIC programs listed by the provider | Free | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 |
| ebtEDGE | EBT cardholders, including WIC participants in supported states and tribal programs | Strong benefit and card management: balances, expiration, transaction history, product eligibility, card locking, and replacement support | WIC and scanner availability vary by state and app version during the current rollout | Free for cardholders | https://apps.apple.com/us/app/ebtedge-new/id6751549725 |
| California WIC App | California WIC participants with a WIC Card | Integrates household food balances and expiration dates with WIC-food scanning, appointments, and store/clinic location | Restricted to the California WIC program | Free | https://myfamily.wic.ca.gov/Home/WICCardAndApp |
| EzWIC | Arizona WIC participants and vendors | Checks both whether a barcode is WIC approved and whether the household has benefits for it; also includes balances, food lists, locations, and complaint reporting | Restricted to the Arizona WIC program | Free | https://www.azdhs.gov/documents/prevention/azwic/exwic-appbroucher-eng.pdf |
| WIC Connect | Michigan WIC participants | Combines issued-benefit and appointment information with UPC scanning, store/clinic locations, and contact updates | Restricted to the Michigan WIC program | unknown | https://play.google.com/store/apps/details?id=gov.michigan.dhhs.miwic |
| Florida WIC App | Florida WIC participants | Combines benefit and appointment information with food scanning, secure document tasks, and submission of foods for WIC approval | Restricted to the Florida WIC program | unknown | https://www.floridahealth.gov/individual-family-health/womens-health/wic/florida-wic-mobile-app/ |
| Maryland WIC App (MD WIC) | Maryland WIC participants | Checks whether a UPC is WIC approved and available in the participant's balance, while also supporting appointments, locations, notifications, and document upload | Restricted to the Maryland WIC program | unknown | https://health.maryland.gov/phpa/wic/Pages/how_to_use_WIC.aspx |
| WIC2Go | New York WIC participants, plus users searching for WIC stores, clinics, and approved foods | Offers barcode checks, benefits and expiration information, appointments, and WIC location search | New York now directs people to ebtEDGE and describes WIC2Go as available to current users only, making it a legacy competitor | Free | https://apps.apple.com/us/app/wic2go/id1374515952 |

The recurring documented weakness is geographic and program fragmentation:
many otherwise close rivals work only for one state or a defined set of WIC
agencies. This table does **not** prove that all rivals lack WolfBite's
nutrition comparison, receipt-image import, or QR handoff. A feature missing
from a cited summary is not proof that the product lacks it; those possible
market-gap claims require a separate, deeper check.
