# Prompt 5 - Who Else Is in the Room?

## Prompt
Our stakeholders so far: customer, staff, admin.

Our product is a WIC-focused grocery shopping assistant designed to help shoppers manage WIC-eligible grocery purchases. Users can identify grocery products through barcode scanning or manual UPC entry, view product and nutrition information, compare healthier alternatives, and add products to a basket while tracking benefit-category allowances. The system can also scan receipts using OCR to identify approved products, restore saved shopping sessions, show remaining benefit balances, distinguish benefit-covered quantities from shopper-paid quantities when appropriate, and generate a QR-code representation of the basket for checkout.

That stakeholder list is incomplete. Extend it. Consider: who pays, who profits, who is harmed, who is ignored, who regulates, who maintains this at 3 a.m., who gets sued when it fails, and whose job changes because it exists.

For each new stakeholder: what they fear about our product, and one design decision that would win them over. Output as a table.

Hard constraint: we are four graduate students with one month to build AND test the next version of this product.


## Terra Output
•  New stakeholder                               WIC participants and caregivers
   What they fear                                Being embarrassed at checkout after the
                                                 app says an item is covered
   One design decision that could win them over  Label eligibility as “estimated,” show the
                                                 reason and remaining allowance, and retain
                                                 a clear shopper-paid fallback
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Infants and children receiving WIC
                                                 benefits
   What they fear                                Caregivers may choose nutritionally
                                                 unsuitable alternatives based on
                                                 simplistic recommendations
   One design decision that could win them over  Limit “healthier alternative” suggestions
                                                 to explicit, explainable nutrition rules
                                                 and clearly separate them from WIC
                                                 eligibility
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               WIC clinic staff / nutritionists
   What they fear                                More support calls caused by incorrect app
                                                 guidance
   One design decision that could win them over  Add a “what to do next” screen for
                                                 rejected items and a simple issue-report
                                                 flow with UPC, store, and receipt evidence
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               State WIC program administrators
   What they fear                                Inaccurate benefit information,
                                                 noncompliance, or confusion with the
                                                 official WIC program
   One design decision that could win them over  Scope the MVP to a clearly labeled demo or
                                                 one validated food list; do not claim
                                                 real-time official benefit status without
                                                 an approved data source
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               WIC state IT teams
   What they fear                                Another unsupported system, security risk,
                                                 or request for costly integrations
   One design decision that could win them over  Make the MVP work without access to state
                                                 systems; document its data model, privacy
                                                 boundaries, and integration assumptions
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Authorized grocery retailers
   What they fear                                More checkout delays and disputes when the
                                                 app disagrees with the point-of-sale
                                                 system
   One design decision that could win them over  Design QR output as a basket summary, not
                                                 payment authorization, and state that
                                                 store POS/eWIC is authoritative
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Cashiers and customer-service staff
   What they fear                                Shoppers treating the app as proof that a
                                                 denied item must be covered
   One design decision that could win them over  Put a concise “checkout can differ” notice
                                                 beside each eligibility result and give
                                                 shoppers a readable fallback explanation
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Store managers / WIC vendor coordinators
   What they fear                                Incorrect UPC or package-size data leading
                                                 to complaints and lost sales
   One design decision that could win them over  Include a lightweight “report mismatch”
                                                 workflow that captures UPC, product photo,
                                                 store, and outcome for later review
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Product-data and barcode-data providers
   What they fear                                Their data being copied, stale, or
                                                 attributed incorrectly
   One design decision that could win them over  Use a small, licensed or public demo
                                                 dataset and record the source and last-
                                                 verified date for every catalog record
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               OCR / AI service provider
   What they fear                                Receipt images containing sensitive
                                                 purchase and household information
   One design decision that could win them over  Minimize retained images: process locally
                                                 or delete uploads immediately after
                                                 extracting line items, with explicit
                                                 consent
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Privacy and security reviewers
   What they fear                                Exposure of benefit balances, receipts,
                                                 location, or household data
   One design decision that could win them over  Require no account for the prototype;
                                                 encrypt any saved session locally and
                                                 provide a one-tap delete-data control
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               University / project sponsor
   What they fear                                Student team making misleading public-
                                                 benefit or health claims
   One design decision that could win them over  Use a prototype disclaimer, test only with
                                                 consented participants, and avoid
                                                 presenting it as an official WIC service
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Legal counsel / insurer
   What they fear                                Liability if eligibility advice causes a
                                                 failed transaction, missed benefit, or
                                                 privacy incident
   One design decision that could win them over  Make non-authoritative status and
                                                 limitations visible at decision points;
                                                 keep an audit log only for consented test
                                                 sessions
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Accessibility and language-access
                                                 advocates
   What they fear                                The app excluding users with low vision,
                                                 limited English, low digital literacy, or
                                                 unreliable connectivity
   One design decision that could win them over  Build the core flow with large tap
                                                 targets, plain language, Spanish support
                                                 if feasible, and manual UPC entry
                                                 alongside scanning
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Maintainer / on-call developer
   What they fear                                A broken barcode, OCR, or QR service at 3
                                                 a.m. with no way to diagnose it
   One design decision that could win them over  Keep the architecture small, add error
                                                 logging and a status page, and ensure
                                                 manual entry works when scanning fails
  ─────────────────────────────────────────────────────────────────────────────────────────
   New stakeholder                               Future development team
   What they fear                                A one-month prototype becoming
                                                 unmaintainable feature sprawl
   One design decision that could win them over  Deliver one narrow, tested flow—UPC/manual
                                                 lookup → basket → allowance explanation—
                                                 behind clean interfaces; defer live
                                                 benefits, OCR, and checkout integrations
                                                 unless they can be validated
                                

## Initial Analysis Notes
- Terra expanded the stakeholder list well beyond customer/staff/admin and identified several groups affected indirectly by the product.
- Grocery retailers, cashiers, WIC administrators, state IT teams, privacy reviewers, and maintainers appear especially relevant to the design.
- Some entries, such as WIC participants/caregivers, overlap with our original "customer" stakeholder rather than being entirely new.
- Several recommendations reinforce a narrow MVP: manual fallback, clear eligibility disclaimers, limited external integrations, and strong privacy boundaries.