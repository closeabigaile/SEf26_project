# Gemini P01 -- Market survey

- Model: Gemini 3.1 Pro (High)
- Runner: Antigravity
- Date: 2026-09-06
- Repository baseline: unknown
- Prompt ID: P01
- Web access used: Yes
- Input files/context: Embedded prompt context from Project1b_Work/prompts/gemini_antigravity_runbook.md
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

| product | who uses it | main strength | main weakness | price | evidence URL |
|---|---|---|---|---|---|
| WICShopper | WIC participants in supported states | Widely adopted across many state programs with scanner and balance features | Scanner does not always show available items accurately | Free | https://apps.apple.com/us/app/wicshopper/id614569159 |
| Bnft | WIC participants using Bnft card systems | Simple benefit tracking and balance checking | Frequent logout and login errors during usage | Free | https://apps.apple.com/us/app/bnft/id1286864895 |
| myWIC Mosaic | WIC participants in specific supported states | Comprehensive clinic appointment scheduling features | Scanner and app frequently break requiring reinstall | Free | https://apps.apple.com/us/app/mywic-mosaic/id1560485314 |
| California WIC App | California WIC participants | Tailored specifically for California WIC users and appointments | unknown | Free | https://myfamily.wic.ca.gov/ |
| Minnesota WIC App | Minnesota WIC participants | Integrated with Minnesota WIC benefit balances | unknown | Free | https://www.health.state.mn.us/people/wic/vendor/app/index.html |
| WIC Connect (Michigan) | Michigan WIC participants | Integrated shopping lists and benefit tracking | unknown | Free | https://www.michigan.gov/mdhhs/assistance-programs/wic |
| Florida WIC Mobile App | Florida WIC participants | Document upload feature for certification | unknown | Free | https://www.floridahealth.gov/programs-and-services/wic/wic-app/index.html |
