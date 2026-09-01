# Aditya's UC6-UC10 Test Results

**Scope:** UC6-UC10

**Product:** WolfBite

**Execution date:** September 1, 2026

**Command:** team-only Project 1a suite command documented in `Project3/test/active/README.md`
**Result:** 23 tests executed: 21 passed and 2 failed because inherited behavior differs from the finalized use cases.

Production files were not changed. Actual results come from the expanded team-only run preserved at `Project1a_Work/raw_test_output/project1a_team_suite_2026-09-01.txt`. State-transition coverage is reported separately in `Project1a_Work/tables/aditya_uc06_uc10_transition_coverage.md`.

## UC6 - Review product nutrition

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `UC6-T1 identified product -> normalized nutrition` | Verify raw APL nutrient names become the fields used by the product UI. | Calories, fat, saturated fat, sodium, sugar, protein, and WIC eligibility match the supplied product. | **PASS** - all seven normalized fields matched. |
| `UC6-T2 missing or nonnumeric nutrients -> zero defaults` | Missing or malformed nutrition must not crash the review or create nonnumeric UI values. | Missing values and nonnumeric energy become `0.0`. | **PASS** - calories, fat, sodium, and protein defaulted to `0.0`. |
| `UC6-T3 exact thresholds -> all inclusive qualities apply` | Check the boundary values of every nutrition-quality rule. | Exact thresholds receive low-fat, low-sodium, low-sugar, high-protein, low-calorie, and heart-healthy qualities. | **PASS** - all six qualities were present. |
| `UC6-T4 nutrition matching no rule -> no qualities` | Ensure no quality is awarded when every value is outside its rule. | The qualities list is empty. | **PASS** - no quality was returned. |
| `UC6-T5 more than three qualities -> compact view shows three` | Keep the compact product view bounded when many qualities apply. | Exactly three quality tooltips render. | **PASS** - three tooltips rendered. |

## UC7 - Compare healthier alternatives

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `UC7-T1 eligible same-category candidates -> ranked healthier list` | Verify the normal comparison path and ordering by health score. | Only the two healthier candidates return, best before good, with ascending scores. | **PASS** - UPCs were `best`, `good`, in ascending score order. |
| `UC7-T2 candidate pool -> excludes original, ineligible, and other category` | Exclude the scanned product, ineligible products, and other benefit categories. | No candidate remains. | **PASS** - the result was empty. |
| `UC7-T3 more than maximum healthier candidates -> first five ranked` | Check the five-alternative limit and ranking when seven qualify. | Five candidates return with scores `0.1` through `0.5`. | **PASS** - exactly those five ranked scores returned. |
| `UC7-T4 candidate missing nutrition -> zero-score candidate can qualify` | Record how missing nutrition participates in inherited scoring. | The candidate qualifies with score `0.0`. | **PASS** - UPC `missing` returned with score `0.0`. |
| `UC7-T5 no better candidate -> empty alternatives` | Equal nutrition should not be presented as healthier. | The alternatives list is empty. | **PASS** - no alternative returned. |
| `UC7-T6 blank category -> no search results` | Probe the blank-category boundary in the UC7 screen flow. | A blank category produces no alternatives. | **FAIL (test-scope mismatch)** - the direct service call returned `blank-category`; the production screen guards this call. |

## UC8 - Add product to basket

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `UC8-T1 identified covered product -> basket and usage increment` | Verify the normal covered-product transition. | Addition returns true, creates one quantity-one line, and raises MILK usage to 1. | **PASS** - all basket and usage assertions matched. |
| `UC8-T2 exhausted allowance -> unchanged basket and usage` | Prevent benefit use beyond the allowed balance. | Addition returns false; basket stays empty and usage stays 1. | **PASS** - rejected with no state change. |
| `UC8-T3 existing UPC -> quantity flow without duplicate line` | Re-adding the same UPC should increase quantity without a duplicate row. | No new line is reported; one line remains at quantity 2 and usage becomes 2. | **PASS** - one quantity-two line remained and usage became 2. |
| `UC8-T4 signed-out shopper -> rejected unchanged basket` | Basket mutation requires an authenticated shopper. | Addition returns false and basket and balances remain empty. | **PASS** - rejected without mutation. |
| `UC8-T5 raw category -> canonical in-memory basket state` | Inconsistent spacing and case must not split benefit balances. | Addition succeeds and stores `MILK PRODUCTS` in basket and balances. | **PASS** - category canonicalized in both locations. |

## UC9 - Choose healthier alternative

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `UC9-T1 available alternative -> exact product submitted` | Verify the chosen alternative, not the original, is sent to basket state. | `addItem` receives the exact UPC, name, category, and nutrition; UI reports success. | **PASS** - the exact alternative was submitted once and success appeared. |
| `UC9-T2 rejected alternative -> must not report success` | The UI must honor a false result from `AppState.addItem`. | No success message appears after rejection. | **FAIL** - UI displayed `Added healthier item: Better cereal`. |

## UC10 - Scan receipt

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `UC10-T1 ready -> source dialog cancelled -> ready unchanged` | Cancelling before choosing a source should be a no-op. | The ready prompt and `Select Image` remain visible. | **PASS** - both ready-state elements remained visible. |
| `UC10-T2 source chosen -> image selection cancelled -> ready` | Cancelling the platform picker must return control without processing. | `Select Image` remains available and the upload/analyze control remains rendered for another attempt. | **PASS** - both controls remained present after picker cancellation. |
| `UC10-T3 OCR failure -> visible error and ready state` | A failed OCR request must be explained and allow retry. | API 500 error is visible and `Select Image` is available. | **PASS** - error text and retry control were visible. |
| `UC10-T4 OCR text without candidate -> zero-candidate status` | Successful OCR can contain no 12-14 digit product candidate. | Screen reports `No UPC candidates found.` and permits retry. | **PASS** - zero-candidate status and selection control appeared. |
| `UC10-T5 spaced or hyphenated code -> no candidate` | Separated digits must not silently become one UPC. | Spaced and hyphenated groups produce no candidate. | **PASS** - screen reported no UPC candidates. |

## Testability limitations

The receipt screen directly creates `AplService`, `ImagePicker`, and its HTTP request inside private state. Public-UI tests can replace image-picker and HTTP platform behavior, but cannot replace the receipt screen's APL service without changing production code. The 13/14-digit sliding-window, unmatched-candidate, and duplicate-valid-product transitions therefore remain unexecuted. Persistence failure transitions in UC8 and UC9 also remain unexecuted because mutations use fire-and-forget private persistence.
