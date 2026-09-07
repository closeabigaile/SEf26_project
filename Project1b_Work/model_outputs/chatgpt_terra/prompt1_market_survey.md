# Prompt 1 - Market Survey

## Prompt
You are a market analyst. Our product, in one paragraph:

Our product is a WIC-focused grocery shopping assistant designed to help shoppers manage WIC-eligible grocery purchases. Users can identify grocery products through barcode scanning or manual UPC entry, view product and nutrition information, compare healthier alternatives, and add products to a basket while tracking benefit-category allowances. The system can also scan receipts using OCR to identify approved products, restore saved shopping sessions, show remaining benefit balances, distinguish benefit-covered quantities from shopper-paid quantities when appropriate, and generate a QR-code representation of the basket for checkout.

List the ten closest competing products. Output a table:
product | who uses it | main strength | main weakness | price | evidence URL.

Rules:
- No invented products.
- If you are not sure a product exists, leave it out.
- If you cannot support a claim, write "unknown" — do not fill the cell with something plausible.

Hard constraint: we are four graduate students with one month to build AND test the next version of this product.

## Terra Output
Closest competitors are mostly state-administered WIC apps; that fragmentation is a
  meaningful opportunity for a one-month MVP focused on a single state or demo
  dataset.

   product        WICShopper
   who uses it    WIC participants in supported U.S. states
   main strength  Barcode eligibility checks and benefit-balance access
   main weakness  Feature availability varies by state
   price          Free
   evidence URL   Washington State DOH
  ───────────────────────────────────────────────────────────────────────────────────
   product        California WIC App
   who uses it    California WIC participants
   main strength  Scans WIC foods and shows food balance
   main weakness  California-specific
   price          unknown
   evidence URL   California WIC
  ───────────────────────────────────────────────────────────────────────────────────
   product        FL WIC
   who uses it    Florida WIC participants with eWIC cards
   main strength  UPC scanning, issued-benefit viewing, and store/clinic lookup
   main weakness  Florida-specific
   price          unknown
   evidence URL   Google Play listing
  ───────────────────────────────────────────────────────────────────────────────────
   product        WIC2Go
   who uses it    New York State WIC participants; anyone can use store/clinic lookup
                  and barcode scan
   main strength  eWIC balance plus barcode eligibility lookup
   main weakness  New York State-specific
   price          unknown
   evidence URL   Google Play listing
  ───────────────────────────────────────────────────────────────────────────────────
   product        myWIC
   who uses it    Texas WIC clients
   main strength  Benefits/purchase tracking, item scanning, shopping guide,
                  appointments, and card locking
   main weakness  Texas-specific
   price          Free
   evidence URL   Texas WIC
  ───────────────────────────────────────────────────────────────────────────────────
   product        WIC Connect
   who uses it    Michigan WIC clients
   main strength  UPC scan identifies eligibility and shows remaining quantity for
                  approved items
   main weakness  Michigan-specific
   price          Free
   evidence URL   Michigan WIC
  ───────────────────────────────────────────────────────────────────────────────────
   product        Indiana WIC
   who uses it    Indiana WIC clients
   main strength  Current/future benefit balances, UPC scan, store locator, and
                  appointments
   main weakness  Indiana-specific
   price          Free
   evidence URL   App Store listing
  ───────────────────────────────────────────────────────────────────────────────────
   product        Wisconsin MyWIC
   who uses it    Wisconsin WIC participants
   main strength  Benefit balance, UPC scan, WIC-food search, store search, and
                  reminders
   main weakness  Wisconsin-specific
   price          unknown
   evidence URL   Wisconsin WIC shopping guide
  ───────────────────────────────────────────────────────────────────────────────────
   product        SC WIC Mobile App
   who uses it    South Carolina WIC participants
   main strength  Remaining balance by food category plus UPC approval scan
   main weakness  South Carolina-specific
   price          unknown
   evidence URL   South Carolina instruction guide
  ───────────────────────────────────────────────────────────────────────────────────
   product        my Minnesota WIC App
   who uses it    Minnesota WIC participants
   main strength  Food Finder supports UPC scanning or manual UPC entry
   main weakness  Minnesota-specific
   price          unknown
   evidence URL   Minnesota WIC shopping guide


## Initial Verification Notes

- Most listed competitors appear to be real WIC applications supported by official state or app-store sources.
- A major pattern is that many competitors are state-specific, creating fragmentation across WIC shopping tools.
- WIC2Go is still supported for existing users in New York, but New York is also directing users toward ebtEDGE, so its current competitive relevance should be reviewed.
- Full evidence URLs should be collected before the final D1 market survey.