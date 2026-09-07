# Prompt 2 - Mine the Complaints

## Prompt
Below are real user complaints about products like ours: top issues from
their trackers, review excerpts, forum posts.

Cluster these complaints into themes. Rank the themes by frequency times
severity. For each theme, cite one of the provided complaints as evidence and
say whether any current product has fixed it. Do not invent or reconstruct
verbatim user quotes. The unfixed themes are our opportunity list.

Issues Found:
Product: WIC2Go
Complaint: Users report recurring login failures, "user not found" errors, and having to re-register with different email addresses.
Source: Apple App Store reviews

Product: WIC2Go
Complaint: Users report barcode scans saying products are not WIC-approved even when they actually are.
Source: Apple App Store reviews

Product: WIC Connect (Michigan)
Complaint: Users report frequent login failures and unreliable app behavior.
Source: Google Play reviews

Product: WIC Connect (Michigan)
Complaint: Users report products being marked approved by the app but denied at checkout.
Source: Google Play reviews

Product: WIC Connect (Michigan)
Complaint: Users report the scanner rarely working or crashing the app.
Source: Google Play reviews

Product: WICShopper
Complaint: Users report benefits or balances displaying incorrectly at the beginning of the month until the card is used.
Source: Apple App Store reviews

Product: WICShopper
Complaint: Users report items being marked covered in the app but not covered at checkout.
Source: Apple App Store reviews

Product: WICShopper
Complaint: Users report weak product-search functionality and generic product descriptions that require excessive manual scanning.
Source: Google Play reviews

Product: California WIC App
Complaint: Users report registration failing because the app rejects birthdate formatting.
Source: Apple App Store reviews

Product: California WIC App
Complaint: Users report logout and password-recovery problems.
Source: Apple App Store reviews

Product: Indiana WIC
Complaint: Users report the scanner failing to read barcodes or incorrectly marking covered products as ineligible.
Source: Apple App Store reviews

Product: Indiana WIC
Complaint: Users report app crashes and incorrect-password errors.
Source: Apple App Store reviews


Hard constraint: we are four graduate students with one month to build AND
test this new thing.



## Terra Output
•  Rank    Theme                          Frequency × severity    Evidence from provided         Has a current product fixed
                                                                  complaints                     it?
  ━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      1    Account access and recovery              5 × 4 = 20    WIC2Go users report login      Unknown. No verified fix is
           failures                                               failures, “user not found”     evidenced in the supplied
                                                                  errors, and re-                complaints.
                                                                  registration; California
                                                                  WIC users report
                                                                  registration, logout, and
                                                                  password-recovery problems.
  ──────  ─────────────────────────────  ──────────────────────  ─────────────────────────────  ─────────────────────────────
      2    Barcode scanning and                     3 × 5 = 15    Indiana WIC users report       Unknown. No verified fix is
           eligibility accuracy                                   scanners failing to read       evidenced.
                                                                  barcodes or wrongly marking
                                                                  covered products
                                                                  ineligible.
  ──────  ─────────────────────────────  ──────────────────────  ─────────────────────────────  ─────────────────────────────
      3    App prediction disagrees                 2 × 5 = 10    WIC Connect users report       Unknown. No verified fix is
           with checkout                                          products shown as approved     evidenced.
                                                                  in the app but denied at
                                                                  checkout.
  ──────  ─────────────────────────────  ──────────────────────  ─────────────────────────────  ─────────────────────────────
      4    Benefit-balance freshness                 1 × 4 = 4    WICShopper users report        Unknown. No verified fix is
           and correctness                                        incorrect benefit/balance      evidenced.
                                                                  displays at the beginning
                                                                  of the month until the card
                                                                  is used.
  ──────  ─────────────────────────────  ──────────────────────  ─────────────────────────────  ─────────────────────────────
      5    Poor product discovery and                1 × 3 = 3    WICShopper users report        Unknown. No verified fix is
           item information                                       weak search and generic        evidenced.
                                                                  descriptions that force
                                                                  excessive manual scanning.

  The best one-month opportunity is not “build every WIC feature.” Build a reliable shopping decision layer: manual UPC
  fallback, clear confidence/status states, a searchable local product catalog, and an explicit warning that app eligibility
  is not a checkout guarantee. Avoid direct eWIC account integration, authentication, and real-time balance synchronization
  unless a state partner provides access; those are the most consequential issues but likely infeasible for four students to
  build and test responsibly in one month.


## Initial Analysis Notes
- Terra identified account/login problems as the highest-ranked issue, but these may require state or eWIC system integration that is unrealistic for a one-month student project.
- Barcode eligibility accuracy, manual UPC fallback, and product search appear more feasible for our team to improve.
- Terra's frequency × severity rankings are qualitative LLM judgments rather than measured severity scores.
- The recommendation to focus on a reliable shopping-decision layer may be useful when deciding the Project 2 direction.