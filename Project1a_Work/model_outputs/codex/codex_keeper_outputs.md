# Codex keeper-prompt outputs (K1-K4)

Run date: 2026-08-24  
Repository: `closeabigaile/SEf26_project`, commit `cc22b3c`  
Scope: production source, README, configuration, workflow, and history. Inherited
tests were deliberately excluded. No repository files were edited.

Paths below are relative to `Project3/` unless they begin with `README.md` or
`.github/`.

## K1 — Evidence-ranked actor goals

| Rank | Verb+noun actor goal | Primary actor | Trigger | Success outcome | Strongest evidence | Confidence |
|---:|---|---|---|---|---|---|
| 1 | Check product eligibility | WIC shopper | Shopper scans a barcode | Matching APL product details are shown | `lib/screens/scan_screen.dart:130-152` | high |
| 2 | Add eligible product | WIC shopper | Shopper selects Add after lookup | Product enters basket and category usage increases | `lib/screens/scan_screen.dart:171-195`; `lib/state/app_state.dart:347-404` | high |
| 3 | Review shopping basket | Shopper | Shopper opens Basket | Current lines and total quantity are displayed | `lib/screens/basket_screen.dart:98-135` | high |
| 4 | Adjust product quantity | Shopper | Shopper presses plus or minus | Covered/paid quantities and usage change together | `lib/state/app_state.dart:431-553` | high |
| 5 | Complete QR checkout | Shopper | Shopper selects Ready to Checkout, then Finish | Basket JSON is encoded as QR and basket is cleared | `lib/screens/qr_checkout_screen.dart:12-45`; `lib/state/app_state.dart:556-563` | high |
| 6 | Review benefit balances | WIC shopper | Shopper opens Benefits | Per-category used/allowed balances are displayed | `lib/screens/balances_screen.dart:45-74,134-173` | high |
| 7 | Scan receipt | WIC shopper | Shopper selects receipt camera/upload | OCR-derived UPCs are matched to APL products | `lib/screens/receipt_scanner_screen.dart:29-85,124-165` | high |
| 8 | Add receipt products | WIC shopper | Shopper selects Add All | Accepted receipt products enter basket | `lib/screens/receipt_scanner_screen.dart:169-181` | high |
| 9 | Compare healthier alternatives | Health-conscious shopper | Product lookup returns a category | Up to five better-scoring eligible products are available | `lib/services/apl_service.dart:139-180` | high |
| 10 | Add healthier alternative | Health-conscious shopper | Shopper selects an alternative's add icon | Selected alternative is sent to basket state | `lib/screens/scan_screen.dart:367-385` | high |
| 11 | Enter product UPC | Web/desktop shopper | Shopper submits typed UPC | Trimmed UPC is looked up and shown | `lib/screens/scan_screen.dart:130-152,600-648` | high |
| 12 | Review product nutrition | Health-conscious shopper | Product result or basket line is displayed | Nutrition values and compact badges are shown | `lib/utils/nutritional_utils.dart:26-104`; `lib/widgets/nutritional_badges.dart:94-133` | high |
| 13 | Create account | New shopper | Shopper submits registration form | Auth account/profile are created, then user returns to login | `lib/screens/signup_page.dart:46-75` | high |
| 14 | Sign in | Returning shopper | Shopper submits credentials | Firebase authenticates and scan screen opens | `lib/screens/login_screen.dart:38-55` | high |
| 15 | Resume saved session | Returning shopper | Auth state becomes signed in | Basket and balance state are restored from Firestore | `lib/state/app_state.dart:75-86,227-294` | high |
| 16 | Sign out | Authenticated shopper | Shopper presses logout | Auth ends and user-scoped local state is cleared | `lib/state/app_state.dart:75-99`; `lib/screens/balances_screen.dart:33-38` | high |
| 17 | Buy excess quantity | Shopper | Shopper increments at a WIC category cap | Extra quantity is represented by a PAID line | `lib/state/app_state.dart:431-486` | high |
| 18 | Clear basket | Shopper | Shopper confirms Clear All | Lines are removed and covered usage is decremented | `lib/screens/basket_screen.dart:205-229`; `lib/state/app_state.dart:565-581` | high |
| 19 | Start new benefit month | Returning shopper | Saved state loads in a later month/year | Used counts reset and basket clears | `lib/state/app_state.dart:195-212,282-287` | medium (system-triggered; better as UC4 extension) |
| 20 | Inspect basket nutrition | Health-conscious shopper | Shopper expands a basket item | Saved nutrition details become visible | `lib/screens/basket_screen.dart:293-390` | high |

README claims unsupported by code:

- `README.md:76` claims real-time order tracking, but the complete route inventory
  contains only authentication, scan, basket, balances, and receipt routes
  (`lib/app_router.dart:65-139`). No order/tracking module exists.
- The product calls itself a food-delivery application (`README.md:22,37`), but
  there is no ordering, restaurant, delivery, driver, or tracking workflow.

Implemented user-visible behavior omitted or materially underexplained by README:

- Saved basket/balance restoration and monthly reset (`lib/state/app_state.dart:227-294`).
- PAID overflow at a WIC cap and paid-first decrement (`lib/state/app_state.dart:431-553`).
- Direct UPC entry on wide layouts (`lib/screens/scan_screen.dart:600-648`).
- Authentication route guards (`lib/app_router.dart:143-190`).

## K2 — State-transition and invariant audit

| Flow | Starting state | State transitions | Persisted fields | Visible outcome | Invariant that should always hold | Evidence status and location |
|---|---|---|---|---|---|---|
| UPC input → lookup → basket → balance | Signed-in; UPC text or scan; no active request | trim UPC → APL lookup → cache product → construct nutrition → canonicalize category → add line → increment `used` → fire-and-forget persist | `balances`, `basket`, `updatedAt` | Product result, then add confirmation and updated basket/balance | For each covered category, `used` equals covered basket quantity and does not exceed `allowed` | EVIDENCE: `lib/screens/scan_screen.dart:130-203`; `lib/state/app_state.dart:303-309,347-404`. INFERENCE: equality invariant is intended, not explicitly checked. |
| Quantity at cap → PAID overflow → decrement | Existing covered line; `used == allowed` | increment → create/increment same-UPC `PAID` line → increment PAID usage → decrement removes PAID first → only then covered line | basket split across original/PAID; both balances; timestamp | Basket shows covered and paid quantities | Covered usage remains capped; removing quantity never reduces covered usage while paid overflow exists | EVIDENCE: `lib/state/app_state.dart:431-553`. |
| Receipt image → OCR → UPC matches → basket | Signed-in; source available | pick image → base64 → OCR.space POST → extract 12–14 digits/windows → sequential APL lookup → deduplicate → Add All calls `addItem` | Nothing during OCR; basket/balances/timestamp after Add All | Recognition count, product list, then “Added N items” and basket | Each unique recognized UPC is offered once; reported added count equals successful `addItem` calls | EVIDENCE: `lib/screens/receipt_scanner_screen.dart:29-181`. |
| Basket → QR handoff → finish | Nonempty basket | JSON-encode basket → render QR → Finish calls checkout → clear basket → persist → show success → scan route | empty basket, existing balances, timestamp | QR then “Transaction Complete! Balances updated.” | Checkout must not decrease benefit `used`; it commits already-counted usage and removes only basket lines | EVIDENCE: `lib/screens/qr_checkout_screen.dart:12-45`; `lib/state/app_state.dart:556-563`. |
| Sign-in → restore → new month | Firebase user becomes non-null | set UID → load `users/{uid}` → normalize/default data → compare timestamp month/year → reset used and basket if stale → persist | loaded or reset basket/balances/timestamp | Protected app opens; restored or empty current-month state appears | State belongs to current UID; stale-month basket is empty and every `used` is zero | EVIDENCE: `lib/state/app_state.dart:75-86,195-212,227-294`. |

Contradictions and silent-failure paths:

- EVIDENCE: scan add changes local state, calls `_persist()` without awaiting it,
  and always reports success (`scan_screen.dart:188-202`; `app_state.dart:400-404`).
  Persistence failure can therefore leave a successful-looking but unsaved change.
- EVIDENCE: adding a healthier alternative ignores `addItem`'s Boolean result and
  always reports success (`scan_screen.dart:374-385`). It can claim success when
  signed out or rejected at a cap.
- EVIDENCE: Receipt “Add All” adds products to the basket (`receipt_scanner_screen.dart:169-181`),
  contradicting README language that receipt import automatically checks out items
  (`README.md:67-69`).
- EVIDENCE: `checkout()` clears the basket but intentionally leaves balance usage
  unchanged (`app_state.dart:556-563`). The success wording is compatible with a
  commit, but does not prove a cashier consumed the QR.
- EVIDENCE: monthly reset calls an unawaited `_persist()` during a load and then the
  load completes (`app_state.dart:204-212,282-293`); persistence failure has no
  visible recovery.
- EVIDENCE: `loadUserState` has `try/finally` but no `catch`; it marks balances loaded
  even when retrieval throws (`app_state.dart:234-293`).

## K3 — Boundary and extension miner (exactly 25)

| # | Boundary/input partition | Expected behavior supported by code | Ambiguity or risk | Candidate extension | Evidence |
|---:|---|---|---|---|---|
| 1 | Email without `@` | Reject before Firebase call | Very weak email validation accepts many malformed forms | Invalid email → remain signed out with field error | `lib/screens/login_screen.dart:99-101` |
| 2 | Password length 5 vs 6 | Five rejected; six accepted for submission | Provider may impose other rules | Password under six → block request | `lib/screens/login_screen.dart:120-121` |
| 3 | Registration auth succeeds but profile write fails | No supported complete outcome | Partial orphaned auth account; only FirebaseAuthException is caught | Profile persistence fails → account creation is partial | `lib/screens/signup_page.dart:52-75` |
| 4 | Empty/whitespace UPC | No lookup | No explanation is shown | Empty UPC → remain ready without query | `lib/screens/scan_screen.dart:130-133` |
| 5 | Concurrent barcode detections | Ignore while `_busy` | Rapid distinct scans can be silently discarded | Lookup active → ignore subsequent detection | `lib/screens/scan_screen.dart:130-134,409-414` |
| 6 | UPC document absent | Show not-found and clear product info | Previously loaded alternatives are not explicitly cleared in this branch | Unknown UPC → no addable product | `lib/screens/scan_screen.dart:139-145` |
| 7 | Product category empty | Do not search alternatives | Existing option state may remain stale | Empty category → no comparison request | `lib/screens/scan_screen.dart:217-226` |
| 8 | Exactly five vs more healthier matches | Return no more than five | Firestore first limits candidates to 50; global best beyond 50 may be missed | More than five candidates → display lowest five among queried set | `lib/services/apl_service.dart:145-180` |
| 9 | Candidate has same FDC ID or UPC as base | Exclude it | Missing IDs can weaken self-exclusion | Base product in candidate query → omit it | `lib/services/apl_service.dart:154-159` |
| 10 | Missing nutrient amount | Treat as zero | Unknown nutrition can appear artificially healthy | Missing nutrient → score/badges use zero (risk noted) | `lib/services/apl_service.dart:83-115`; `lib/utils/nutritional_utils.dart:29-52` |
| 11 | Badge threshold exactly equal | Qualifies for low/maximum rules | Equality semantics are undocumented | Value exactly threshold → include low badge | `lib/utils/nutritional_utils.dart:73-101` |
| 12 | More than three badges in compact display | Show first three | Important WIC badge can crowd out later badges depending on order | Four-plus qualifying badges → compact list truncated | `lib/widgets/nutritional_badges.dart:103-110` |
| 13 | New category containing FRUIT/VEGETABLE/CVB | Set uncapped allowance | Substring matching may classify unintended names | Produce-like category → unlimited balance | `lib/state/app_state.dart:122-157` |
| 14 | First new covered item when category below cap | Create qty 1 and used 1 | Empty UPC is accepted by state even though UI normally prevents it | First valid item → create one covered line | `lib/state/app_state.dart:347-404` |
| 15 | New distinct UPC when category already full | `addItem` returns false | Scan UI rewrites category to PAID, receipt path does not; inconsistent behavior | New item at cap → reject or paid behavior depends on entry path | `lib/state/app_state.dart:366-375`; `lib/screens/scan_screen.dart:183-193` |
| 16 | Existing UPC below cap | Increment covered line instead of duplicate | `addItem` returns false even though mutation succeeds, so callers may misreport | Duplicate UPC → increase existing quantity | `lib/state/app_state.dart:358-364,431-450` |
| 17 | Existing UPC exactly at cap | Create/increment PAID line | PAID balance is a quantity counter although called a benefit balance | Increment at cap → create paid overflow | `lib/state/app_state.dart:451-486` |
| 18 | Increment UPC not currently in basket | No line change, but persist/notify still occur | Silent no-op is presented as valid action | Missing basket line → quantity unchanged | `lib/state/app_state.dart:437-490` |
| 19 | Decrement when paid and covered lines both exist | Reduce/remove PAID first | Caller-provided category can be PAID, making original-category reasoning fragile | Mixed quantity decrement → consume paid overflow first | `lib/state/app_state.dart:502-549` |
| 20 | Decrement qty 1 | Remove line and clamp usage at zero | Corrupt preexisting usage is hidden by clamp | Last unit removed → line disappears; usage nonnegative | `lib/state/app_state.dart:513-547` |
| 21 | Saved record lacks nutrition | Insert all-zero nutrition | Generates potentially false healthy badges | Missing saved nutrition → restore zero defaults | `lib/state/app_state.dart:254-279` |
| 22 | Timestamp same month different year | Reset | Correctly checks year as well as month | Same month number, later year → reset | `lib/state/app_state.dart:195-200,282-287` |
| 23 | OCR has 11 digits vs 12–14 | Eleven ignored; 12–14 examined | Common formatted UPCs with spaces/hyphens are missed | No contiguous 12–14 digits → no candidates | `lib/screens/receipt_scanner_screen.dart:124-164` |
| 24 | OCR 13/14-digit candidate | Try whole string then every 12-digit window | Multiple windows cause sequential database calls; first match wins | Longer code → test candidate and sliding windows | `lib/screens/receipt_scanner_screen.dart:133-156` |
| 25 | Finish QR checkout with persistence failure | INFERENCE: basket should remain or failure should be shown | Code clears locally before awaited persistence; exception prevents success UI but local basket is already empty | Checkout persistence fails → no false completion and state consistency must be examined | `lib/state/app_state.dart:556-563`; `lib/screens/qr_checkout_screen.dart:34-45` |

## K4 — Contradiction adjudicator

| Claim | Claim source | Confirming/contradicting evidence | Verdict | Top 20? |
|---|---|---|---|---|
| Users can track orders in real time | `README.md:76` | Complete route list has no order/tracking route or production module (`lib/app_router.dart:65-139`) | absent/misleading | no |
| Receipt import automatically checks out items and updates monthly balance | `README.md:67-69` | OCR finds products, then user presses Add All; code calls `addItem` and navigates to basket, not checkout (`lib/screens/receipt_scanner_screen.dart:124-181`) | partial/misleading | yes, as “scan receipt” and “add receipt products,” not auto-checkout |
| QR checkout creates a platform-agnostic transaction representation | `README.md:63-65` | `QRCheckoutScreen` JSON-encodes basket and renders a real QR (`lib/screens/qr_checkout_screen.dart:12-26`); an older separate `_showQRDialog` displays only an icon (`lib/screens/basket_screen.dart:30-56`) but current button pushes the real screen (`basket_screen.dart:174-184`) | implemented, with misleading dead/unused dialog | yes |
| Barcode scanning verifies WIC eligibility | `README.md:37,41,73` | UPC is used as APL document ID and any existing document is presented; lookup does not itself require `eligible == true` (`lib/services/apl_service.dart:31-35`; `lib/screens/scan_screen.dart:130-156`) | partial | yes, word as APL lookup rather than guaranteed verification |
| Nutritional/WIC icons reflect known nutrition | `README.md:59-61` | Missing/nonnumeric values default to zero and can qualify for several low badges (`lib/utils/nutritional_utils.dart:26-52,59-104`) | partial/misleading at missing-data boundary | yes |
| App is cross-platform and optimized for mobile/web | `README.md:37,77` | Flutter platform shells exist; scan UI has mobile/wide layouts, receipt uses web-safe bytes (`lib/screens/scan_screen.dart:417-430`; `lib/screens/receipt_scanner_screen.dart:68-72`) | implemented in structure; not evidence of equal platform reliability | not a separate actor goal |
| App is a food-delivery application | `README.md:22,37` | Production routes support shopping assistance, basket, benefits, receipt, and checkout handoff but no restaurant/order/delivery flow (`lib/app_router.dart:65-139`) | misleading | no |
| CI validates current project | `.github/workflows/flutter-ci.yml:17-46` | Workflow working directories point to `./Project2`, while current source is `Project3` (`.github/workflows/flutter-ci.yml:22-25,68-80`) | absent for current layout | no, but important health finding |
| Dependencies are automatically installable/reproducible | `README.md:140-154` | Broad version constraints and no committed lockfile allowed incompatible Firestore/fake-Firestore resolution during the recorded baseline run | partial/misleading | no, but important test-health finding |

Three mistakes an LLM is most likely to make:

1. Promote README-only “real-time order tracking” or food delivery into a use
   case despite no route or module implementing it.
2. Describe receipt scanning as automatic checkout; code only recognizes products
   and adds user-selected matches to the basket.
3. Treat QR checkout and WIC verification as stronger than the implementation:
   the QR is local basket JSON with no cashier acknowledgement, and UPC lookup
   returns any existing APL document without independently enforcing `eligible`.

## Codex verdicts for the reconciliation worksheet

| Prompt | Codex verdict |
|---|---|
| K1 | The production code supports 20 defensible user goals, but monthly reset is system-triggered and is better retained as an extension of session restoration. Exclude order tracking and food delivery. |
| K2 | Basket/balance transitions are testable, but several UI paths report success before or regardless of persistence/state acceptance. Receipt import is not automatic checkout. |
| K3 | The strongest nontrivial test boundaries are cap-to-PAID overflow, paid-first decrement, same-month/different-year reset, OCR sliding windows/deduplication, missing-nutrition-as-zero, and ignored Boolean add results. |
| K4 | README is materially stale: order tracking is absent, receipt checkout is overstated, WIC verification is weaker than claimed, and CI targets the missing `Project2`. |
