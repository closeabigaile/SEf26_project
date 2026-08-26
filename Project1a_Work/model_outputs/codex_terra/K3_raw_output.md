Model: GPT-5.6-terra
Interface: OpenAI Codex CLI
Nme: Supreme
Date: August 25, 2026
Prompt ID: K2 - State-transition and invariant audit
Repository commit: EAD 03bc584b9a4e03aa8eca51b872435d07b4e7009f


#                                    1
   Boundary / input partition           Login email without @ vs. containing @
   Expected behavior supported by code  EVIDENCE: Invalid email is rejected before authentication; any value containing @ passes local email
                                        validation.
   Actual ambiguity or risk             The local rule accepts many malformed addresses.
   Candidate use-case extension         Invalid email → remain on login with field error.
   File:line evidence                   Project3/lib/screens/login_screen.dart:99
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    2
   Boundary / input partition           Login password length 5 vs. 6
   Expected behavior supported by code  EVIDENCE: A password shorter than six characters is rejected locally; six characters permits submission.
   Actual ambiguity or risk             Firebase may apply additional password rules not represented locally.
   Candidate use-case extension         Short password → block sign-in attempt.
   File:line evidence                   Project3/lib/screens/login_screen.dart:120
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    3
   Boundary / input partition           Account creation succeeds but profile write fails
   Expected behavior supported by code  EVIDENCE: Authentication account creation occurs before writing the Firestore profile.
   Actual ambiguity or risk             The catch handles only FirebaseAuthException; a profile-write failure can leave a created account without the
                                        profile and without the displayed signup error.
   Candidate use-case extension         Signup profile-write failure → account/profile state is partial.
   File:line evidence                   Project3/lib/screens/signup_page.dart:52
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    4
   Boundary / input partition           Whitespace-only UPC vs. nonempty UPC
   Expected behavior supported by code  EVIDENCE: Empty trimmed UPCs return without an APL request or visible message.
   Actual ambiguity or risk             A shopper receives no explanation for why lookup did not start.
   Candidate use-case extension         Empty UPC → remain ready without querying or changing result.
   File:line evidence                   Project3/lib/screens/scan_screen.dart:130
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    5
   Boundary / input partition           A second barcode arrives while a lookup is active
   Expected behavior supported by code  EVIDENCE: _busy prevents concurrent detection/lookup handling.
   Actual ambiguity or risk             A later, distinct barcode can be silently discarded.
   Candidate use-case extension         Lookup in progress → ignore subsequent barcode detection.
   File:line evidence                   Project3/lib/screens/scan_screen.dart:130; Project3/lib/screens/scan_screen.dart:409
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    6
   Boundary / input partition           UPC absent from APL
   Expected behavior supported by code  EVIDENCE: The current product result is cleared and a “not found” snackbar is shown.
   Actual ambiguity or risk             Previously loaded healthier alternatives are not explicitly cleared in this branch.
   Candidate use-case extension         Unknown UPC → no addable current product.
   File:line evidence                   Project3/lib/screens/scan_screen.dart:139
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    7
   Boundary / input partition           Existing APL document has eligible: false or no eligibility field
   Expected behavior supported by code  EVIDENCE: Direct UPC lookup returns any existing document; it does not filter on eligible.
   Actual ambiguity or risk             The flow can present a found product as an eligibility result without independently enforcing eligibility.
   Candidate use-case extension         Existing but ineligible APL record → distinguish lookup result from WIC eligibility.
   File:line evidence                   Project3/lib/services/apl_service.dart:31; Project3/lib/screens/scan_screen.dart:130
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    8
   Boundary / input partition           Product lacks foodNutrients, or nutrient values are nonnumeric
   Expected behavior supported by code  EVIDENCE: Missing/non-numeric nutrient amounts become 0.0.
   Actual ambiguity or risk             Unknown nutrition can qualify for low-fat, low-sodium, low-sugar, low-calorie, and heart-healthy badges.
   Candidate use-case extension         Missing nutrition → show zero-derived nutrition/badge behavior.
   File:line evidence                   Project3/lib/utils/nutritional_utils.dart:29; Project3/lib/utils/nutritional_utils.dart:73
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    9
   Boundary / input partition           Nutrition value exactly equals a badge threshold
   Expected behavior supported by code  EVIDENCE: Threshold comparisons are inclusive: for example fat ≤3, sodium ≤140, and protein ≥10.
   Actual ambiguity or risk             Threshold policy is code-defined rather than explained to shoppers.
   Candidate use-case extension         Nutrient exactly at threshold → include the applicable badge.
   File:line evidence                   Project3/lib/utils/nutritional_utils.dart:73
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    10
   Boundary / input partition           More than three qualifying badges in compact display
   Expected behavior supported by code  EVIDENCE: Compact badges render only the first three computed badges.
   Actual ambiguity or risk             The order of badge generation can hide later badges, including WIC eligibility.
   Candidate use-case extension         Four or more qualifying badges → compact display truncates to three.
   File:line evidence                   Project3/lib/widgets/nutritional_badges.dart:103
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    11
   Boundary / input partition           Scanned product has blank category
   Expected behavior supported by code  EVIDENCE: Healthier-alternative lookup returns early for an empty category.
   Actual ambiguity or risk             Existing alternative state may remain until replaced by another successful lookup.
   Candidate use-case extension         Blank category → do not request alternatives.
   File:line evidence                   Project3/lib/screens/scan_screen.dart:217
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    12
   Boundary / input partition           Candidate has the same FDC ID or UPC as the scanned product
   Expected behavior supported by code  EVIDENCE: The healthier-alternative query excludes such candidates.
   Actual ambiguity or risk             Missing IDs can weaken self-exclusion, though UPC comparison remains.
   Candidate use-case extension         Base product appears in candidate set → omit it.
   File:line evidence                   Project3/lib/services/apl_service.dart:154
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    13
   Boundary / input partition           More than five better alternatives, or more than fifty same-category candidates
   Expected behavior supported by code  EVIDENCE: The Firestore query reads at most 50 records and the method returns at most five better-scoring
                                        records.
   Actual ambiguity or risk             The displayed five are the best among the first 50 fetched, not necessarily all category products.
   Candidate use-case extension         Large candidate set → show up to five best queried alternatives.
   File:line evidence                   Project3/lib/services/apl_service.dart:145; Project3/lib/services/apl_service.dart:177
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    14
   Boundary / input partition           Shopper selects a healthier alternative when adding is rejected
   Expected behavior supported by code  EVIDENCE: The UI calls addItem and always shows “Added healthier item,” without checking its Boolean result.
   Actual ambiguity or risk             A rejected addition can still receive success feedback.
   Candidate use-case extension         Alternative addition rejected → verify displayed result against basket state.
   File:line evidence                   Project3/lib/screens/scan_screen.dart:374; Project3/lib/state/app_state.dart:353
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    15
   Boundary / input partition           New category contains FRUIT, VEGETABLE, or CVB
   Expected behavior supported by code  EVIDENCE: Such categories receive an uncapped allowance; other recognized categories receive derived caps.
   Actual ambiguity or risk             Substring matching can classify unintended category names as unlimited.
   Candidate use-case extension         Produce-like category → show unlimited balance behavior.
   File:line evidence                   Project3/lib/state/app_state.dart:122
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    16
   Boundary / input partition           New, unrecognized covered category
   Expected behavior supported by code  EVIDENCE: Its default allowance is two items.
   Actual ambiguity or risk             The cap is derived locally, not sourced from a user’s actual benefit record.
   Candidate use-case extension         Unknown category → initialize cap at two and usage at zero.
   File:line evidence                   Project3/lib/state/app_state.dart:156; Project3/lib/state/app_state.dart:167
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    17
   Boundary / input partition           New distinct receipt item arrives after its covered category is full
   Expected behavior supported by code  EVIDENCE: addItem rejects a new line when the category cannot accept another item.
   Actual ambiguity or risk             This differs from basket increment behavior, which creates PAID overflow; receipt import can therefore add
                                        fewer recognized items than found.
   Candidate use-case extension         Receipt item at covered cap → reject rather than create a paid line.
   File:line evidence                   Project3/lib/state/app_state.dart:366; Project3/lib/screens/receipt_scanner_screen.dart:169
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    18
   Boundary / input partition           Same UPC is added again below category cap
   Expected behavior supported by code  EVIDENCE: addItem increments the existing product via incrementItem but returns false.
   Actual ambiguity or risk             Callers that interpret false as “not added” can misreport a successful quantity change.
   Candidate use-case extension         Duplicate UPC → increase quantity without creating a second covered line.
   File:line evidence                   Project3/lib/state/app_state.dart:358
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    19
   Boundary / input partition           Existing item is incremented exactly at its covered-category cap
   Expected behavior supported by code  EVIDENCE: The app creates or increments a PAID line for the same UPC.
   Actual ambiguity or risk             PAID is tracked in the same balances structure despite not being a benefit category.
   Candidate use-case extension         Increment at cap → create paid overflow.
   File:line evidence                   Project3/lib/state/app_state.dart:451
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    20
   Boundary / input partition           Paid and covered lines both exist; shopper decrements
   Expected behavior supported by code  EVIDENCE: Decrement targets the paid line first, removes it at zero, and only then can reduce the covered line.
   Actual ambiguity or risk             The caller supplies a category argument, but paid-first selection is driven solely by UPC.
   Candidate use-case extension         Mixed covered/paid quantity → remove paid overflow first.
   File:line evidence                   Project3/lib/state/app_state.dart:502
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    21
   Boundary / input partition           Receipt OCR yields no contiguous 12–14 digits, a 12-digit UPC, or a 13/14-digit candidate
   Expected behavior supported by code  EVIDENCE: Only 12–14 contiguous digits are considered; longer candidates are also tested through each 12-digit
                                        window.
   Actual ambiguity or risk             Formatted UPCs with spaces/hyphens are missed; longer values cause sequential APL lookups and the first match
                                        wins.
   Candidate use-case extension         OCR code-length boundary → accept only direct or sliding-window matches.
   File:line evidence                   Project3/lib/screens/receipt_scanner_screen.dart:124
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    22
   Boundary / input partition           OCR contains the same valid UPC repeatedly
   Expected behavior supported by code  EVIDENCE: The recognized-items list deduplicates by UPC before rendering.
   Actual ambiguity or risk             foundCount still counts every numeric candidate, so its status can exceed the number of offered products.
   Candidate use-case extension         Repeated receipt UPC → offer one item despite multiple detections.
   File:line evidence                   Project3/lib/screens/receipt_scanner_screen.dart:133; Project3/lib/screens/receipt_scanner_screen.dart:151
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    23
   Boundary / input partition           Basket mutation succeeds locally but Firestore persistence fails
   Expected behavior supported by code  EVIDENCE: Add, increment, decrement, and clear call _persist() without awaiting it.
   Actual ambiguity or risk             The UI can update and report success before persistence completes or fails.
   Candidate use-case extension         Basket persistence failure → compare local visible state with restored state.
   File:line evidence                   Project3/lib/state/app_state.dart:400; Project3/lib/state/app_state.dart:488; Project3/lib/state/
                                        app_state.dart:551
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    24
   Boundary / input partition           Saved state’s updatedAt is from a prior month/year
   Expected behavior supported by code  EVIDENCE: The app sets every used value to zero, clears the basket, and calls persistence.
   Actual ambiguity or risk             Reset persistence is unawaited; a failed write has no recovery path.
   Candidate use-case extension         New benefit month → reset usage and discard saved basket.
   File:line evidence                   Project3/lib/state/app_state.dart:195; Project3/lib/state/app_state.dart:203; Project3/lib/state/
                                        app_state.dart:282
  ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   #                                    25
   Boundary / input partition           Checkout persistence fails after Finish is selected
   Expected behavior supported by code  INFERENCE: A failed checkout should not be represented as a completed transaction.
   Actual ambiguity or risk             EVIDENCE: checkout clears the local basket before awaiting persistence; an exception bypasses the success
                                        snackbar but there is no rollback.
   Candidate use-case extension         Checkout write failure → inspect whether pending basket contents remain available.
   File:line evidence                   Project3/lib/state/app_state.dart:556; Project3/lib/screens/qr_checkout_screen.dart:34