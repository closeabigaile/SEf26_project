# Project 1b keeper prompts

Store the exact prompts the team designates for cross-model comparison here.
Do not revise a keeper between models; if a correction is necessary, create a
new version and record which models received each version.

## Required cross-model prompts

- P01 -- Market survey (starter Prompt 1)
- P10 -- Red team (starter Prompt 10; run only after a draft market survey,
  mission statement, and milestones exist)

### P01 -- Market survey (exact keeper version)

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

## Current discovery prompts

- P02 -- Mine the complaints
- P05 -- Extend the stakeholder list
- P12 -- Stay or pivot


### Run metadata template

```text
Model:
Runner:
Date:
Repository commit:
Prompt ID:
Web access used:
Input files/context:
```
