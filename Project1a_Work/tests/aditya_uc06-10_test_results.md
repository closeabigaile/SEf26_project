# Aditya's UC6-UC10 Test Results

**Scope:** UC6-UC10
**Product:** WolfBite
**Execution date:** August 30, 2026
**Command:** `flutter test --no-pub test/project1a/aditya_uc6-10_test.dart --reporter expanded`
**Result:** 23 tests executed: 21 passed and 2 failed because inherited behavior differs from the finalized use cases.

Production files were not changed. The tests use requirement, state-transition,
decision, and boundary coverage. State-transition coverage is reported separately
in `Project1a_Work/tables/aditya_uc06_uc10_transition_coverage.md`.

## Passing areas

- UC6: nutrition normalization, missing-value defaults, inclusive thresholds,
  no-match behavior, and the compact three-badge display limit.
- UC7: healthier-candidate filtering, original-product exclusion, ranking,
  five-result limiting, missing nutrition, and no-better-option behavior.
- UC8: accepted addition, exhausted allowance, duplicate UPC quantity flow,
  signed-out rejection, and category canonicalization.
- UC9: selecting an available alternative submits its exact identity and
  nutrition to the basket state.
- UC10: source-dialog cancellation, image-picker cancellation, OCR failure,
  no numeric candidate, and rejection of spaced or hyphenated codes.

## Retained failures

1. `UC7-T6 blank category -> no search results`
   - Expected: a blank category does not produce alternatives.
   - Actual: the service queries the blank category and returns an eligible
     blank-category product.
2. `UC9-T2 rejected alternative -> must not report success`
   - Expected: when `AppState.addItem` returns `false`, the interface does not
     claim the alternative was added.
   - Actual: the interface displays `Added healthier item: Better cereal`.

These expectations were retained rather than changed to match inherited
behavior.

## Testability limitations

The receipt screen directly creates `AplService`, `ImagePicker`, and its HTTP
request inside private state. Public-UI tests can replace image-picker and HTTP
platform behavior, but cannot replace the receipt screen's APL service without
changing production code. The 13/14-digit sliding-window, unmatched-candidate,
and duplicate-valid-product transitions therefore remain unexecuted. Persistence
failure transitions in UC8 and UC9 also remain unexecuted because mutations use
fire-and-forget private persistence.
