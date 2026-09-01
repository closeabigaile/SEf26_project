# Coverage-gap test results

**Scope:** UC8, UC14–UC17, and UC20  
**Test file:** `Project3/test/active/project1a_coverage_gaps_test.dart`  
**Execution date:** September 1, 2026

**Command:** team-only Project 1a suite command documented in `Project3/test/active/README.md`

**Result:** All 11 tests passed within the 86-test Project 1a run.

These tests were added after active-suite curation to cover state-transition,
widget-interaction, and persistence gaps. Expected results are defined by the
test assertions. Actual results below come from the expanded team-only run
preserved at
`Project1a_Work/raw_test_output/project1a_team_suite_2026-09-01.txt`.

## UC8 — Add product to basket

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `UC8 accepted addition persists basket and benefit usage` | The existing tests exercised local addition behavior but did not prove that an accepted covered product and its benefit usage were saved. | Adding milk succeeds; Firestore contains the milk basket line and records one used MILK benefit. | **PASS** — the saved basket contained UPC `milk-1`, and saved MILK usage was 1. |

## UC14 — Increase product quantity

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `available allowance increments quantity and covered usage` | Verify the normal under-cap state transition rather than only boundary or UI-delegation behavior. | The covered product quantity increases from 1 to 2, MILK usage increases from 1 to 2, and no PAID line is created. | **PASS** — quantity and covered usage both became 2, with no PAID basket line. |
| `missing covered product leaves quantity and usage unchanged` | Verify that an increment request for an unknown UPC cannot mutate another basket line or consume benefits. | The existing product remains at quantity 1 and MILK usage remains 1. | **PASS** — both the basket quantity and benefit usage remained unchanged. |
| `UC14 quantity increase persists quantity and covered usage` | Local mutation alone does not prove that the resumed session will contain the increased quantity and usage. | Firestore saves basket quantity 2 and MILK usage 2 after the increment. | **PASS** — the persisted basket quantity and persisted MILK usage were both 2. |

## UC15 — Add shopper-paid quantity

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `missing original product cannot create a shopper-paid line` | Verify that an at-cap increment for an unknown UPC cannot manufacture a PAID line without a source product. | The original basket remains the only line, no PAID line appears, and covered usage remains 1. | **PASS** — basket length stayed 1, no PAID line was created, and MILK usage stayed 1. |

## UC16 — Decrease product quantity

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `UC16 quantity decrease persists quantity and released usage` | Verify that decreasing a covered product saves both the new quantity and released benefit usage. | Firestore saves basket quantity 1 and MILK usage 1 after decreasing from quantity and usage 2. | **PASS** — the persisted basket quantity and persisted MILK usage were both 1. |

## UC17 — Clear basket

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `UC17 clear persists empty basket and reversed usage` | Verify that clearing is durable and releases the covered usage represented by the removed products. | Firestore saves an empty basket and MILK usage 0. | **PASS** — the persisted basket was empty and persisted MILK usage was 0. |
| `cancelling clear leaves the basket unchanged` | UC17 requires a confirmation choice; cancellation must not invoke the destructive state transition. | `clearBasket` is never called and Milk remains visible. | **PASS** — the mock received no clear call, and the Milk basket line remained visible. |
| `confirming clear invokes the state transition once` | Verify that confirmation delegates exactly once instead of doing nothing or clearing repeatedly. | Selecting `Clear All` calls `clearBasket` exactly once. | **PASS** — `clearBasket` was invoked once. |

## UC20 — Finish shopping session

| Test | Why we tried it | Expected | What happened |
|---|---|---|---|
| `checkout saves an empty basket and retains used benefits` | The inherited checkout test double resets benefit usage unlike production, so persistence must be checked against the real `AppState.checkout()` behavior. | Firestore saves an empty basket while retaining MILK usage of 2. | **PASS** — the persisted basket was empty and persisted MILK usage remained 2. |
| `save failure leaves the local basket cleared and reports failure` | Verify the current failure ordering when checkout clears local state before persistence rejects the write. | Checkout throws a `FirebaseException`; the local basket remains cleared and MILK usage remains 1. | **PASS** — the persistence exception propagated, the local basket was empty, and MILK usage stayed 1. |

## Execution evidence

The expanded September 1 team-only run names every gap test and records all 11
as passing. Its final counter is 82 passes and four failures across all 86
team-designed tests; the four named failures belong to the original UC1, UC3,
UC7, and UC9 files, not this gap-test file.
