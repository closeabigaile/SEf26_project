# UC6-UC10 State-Transition Coverage

## Measurement method

A transition is an observable `pre-state -> trigger -> post-state` relationship
derived from the finalized use cases and production behavior. A transition is
**exercised** when a test drives its trigger from the stated pre-state and checks
the resulting state, even when that check fails. A transition is **conforming**
only when the observed post-state matches the finalized use case.

This is a requirements-level state-transition metric, not source-code branch or
line coverage.

| Use case | Identified transitions | Exercised | Conforming | Exercise coverage | Conformance coverage |
|---|---:|---:|---:|---:|---:|
| UC6 | 6 | 5 | 5 | 83.3% | 83.3% |
| UC7 | 8 | 7 | 6 | 87.5% | 75.0% |
| UC8 | 7 | 5 | 5 | 71.4% | 71.4% |
| UC9 | 5 | 3 | 2 | 60.0% | 40.0% |
| UC10 | 10 | 7 | 7 | 70.0% | 70.0% |
| **Total** | **36** | **27** | **25** | **75.0%** | **69.4%** |

## Transition inventory

| ID | Transition | Test/evidence | Result |
|---|---|---|---|
| UC6-S1 | Identified product -> normalized nutrition available | UC6-T1 | Pass |
| UC6-S2 | Missing/nonnumeric nutrition -> zero-valued nutrition | UC6-T2 | Pass |
| UC6-S3 | Exact threshold -> applicable qualities included | UC6-T3 | Pass |
| UC6-S4 | No rule matches -> no qualities | UC6-T4 | Pass |
| UC6-S5 | More than three qualities -> three compact qualities displayed | UC6-T5 | Pass |
| UC6-S6 | Nutrition reviewed -> product and basket unchanged | Not executed | Gap |
| UC7-S1 | Eligible same-category pool -> healthier candidates | UC7-T1 | Pass |
| UC7-S2 | Candidate pool -> original/ineligible/other-category candidates excluded | UC7-T2 | Pass |
| UC7-S3 | Unordered qualifying candidates -> score-ranked alternatives | UC7-T1 | Pass |
| UC7-S4 | More than five qualifying candidates -> five alternatives | UC7-T3 | Pass |
| UC7-S5 | Missing candidate nutrition -> zero score may qualify | UC7-T4 | Pass |
| UC7-S6 | No better candidate -> empty alternatives | UC7-T5 | Pass |
| UC7-S7 | Blank category -> no search/results | UC7-T6 | **Fail** |
| UC7-S8 | Search pending -> backend failure reported | Not executed | Gap |
| UC8-S1 | Identified covered product with capacity -> new basket line | UC8-T1 | Pass |
| UC8-S2 | New covered basket line -> benefit usage incremented | UC8-T1 | Pass |
| UC8-S3 | Exhausted allowance -> basket and usage unchanged | UC8-T2 | Pass |
| UC8-S4 | Existing UPC -> quantity increment without duplicate | UC8-T3 | Pass |
| UC8-S5 | Signed-out shopper -> addition rejected | UC8-T4 | Pass |
| UC8-S6 | Accepted in-memory addition -> persisted state | Not executed | Gap |
| UC8-S7 | Accepted in-memory addition -> persistence failure exposed | Not executed | Gap |
| UC9-S1 | Alternatives available -> chosen identity submitted | UC9-T1 | Pass |
| UC9-S2 | Basket accepts alternative -> success reported | UC9-T1 | Pass |
| UC9-S3 | Basket rejects alternative -> success not reported | UC9-T2 | **Fail** |
| UC9-S4 | Existing alternative -> quantity increment without duplicate | Not executed | Gap |
| UC9-S5 | Alternative accepted in memory -> persistence failure exposed | Not executed | Gap |
| UC10-S1 | Ready -> source dialog displayed | UC10-T1 | Pass |
| UC10-S2 | Source dialog -> cancelled -> ready | UC10-T1 | Pass |
| UC10-S3 | Source selected -> image selection pending | UC10-T2 | Pass |
| UC10-S4 | Image selection pending -> picker cancelled -> ready | UC10-T2 | Pass |
| UC10-S5 | Image selected -> OCR failure -> visible error | UC10-T3 | Pass |
| UC10-S6 | OCR text without 12-14 digit candidate -> no-candidate status | UC10-T4 | Pass |
| UC10-S7 | Spaced/hyphenated digits -> no-candidate status | UC10-T5 | Pass |
| UC10-S8 | 13/14-digit candidate -> matching 12-digit window found | Not executed | Gap |
| UC10-S9 | Candidates found but unmatched -> zero-match summary | Not executed | Gap |
| UC10-S10 | Repeated matching code -> one unique displayed product | Not executed | Gap |

## Interpretation

- **75.0% transition exercise coverage** means tests executed 27 of the 36
  identified transitions.
- **69.4% transition conformance coverage** means 25 of the 36 transitions were
  both executed and observed to satisfy the finalized use case.
- The difference is caused by two inherited behavior mismatches, not by test
  harness failures.
- Remaining gaps principally require dependency injection that the inherited
  production code does not expose. Production was not changed to improve
  testability.
