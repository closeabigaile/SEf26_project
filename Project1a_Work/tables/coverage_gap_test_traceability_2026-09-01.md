# Coverage-gap test-to-use-case traceability

**Test file:** `Project3/test/active/project1a_coverage_gaps_test.dart`

**Execution date:** September 1, 2026
**Scope:** all 11 post-curation gap tests

Each row maps one exact test declaration to the finalized use case behavior proved by its assertions. Expected-versus-actual results are recorded separately in `Project1a_Work/tests/coverage_gap_test_results_2026-09-01.md`.

| Exact test name | Use case | What the assertions prove |
|---|---|---|
| `UC8 accepted addition persists basket and benefit usage` | UC8 - Add product to basket | An accepted covered product and its consumed benefit are saved together. |
| `available allowance increments quantity and covered usage` | UC14 - Increase product quantity | Below the cap, one increment changes covered quantity and usage without a PAID line. |
| `missing covered product leaves quantity and usage unchanged` | UC14 - Increase product quantity | An unknown UPC cannot mutate the basket or consume benefits. |
| `UC14 quantity increase persists quantity and covered usage` | UC14 - Increase product quantity | Increased quantity and used-benefit count are both persisted. |
| `missing original product cannot create a shopper-paid line` | UC15 - Add shopper-paid quantity | An unknown UPC cannot manufacture a PAID line without a source product. |
| `UC16 quantity decrease persists quantity and released usage` | UC16 - Decrease product quantity | Decreasing a covered line persists lower quantity and released usage. |
| `UC17 clear persists empty basket and reversed usage` | UC17 - Clear basket | Clearing persists an empty basket and reverses removed covered usage. |
| `cancelling clear leaves the basket unchanged` | UC17 - Clear basket | Cancellation does not call `clearBasket` and leaves the displayed line intact. |
| `confirming clear invokes the state transition once` | UC17 - Clear basket | Confirmation calls `clearBasket` exactly once. |
| `checkout saves an empty basket and retains used benefits` | UC20 - Finish shopping session | Checkout persists an empty basket while retaining purchased benefit usage. |
| `save failure leaves the local basket cleared and reports failure` | UC20 - Finish shopping session | Persistence failure propagates after local clearing, with used benefits retained. |
