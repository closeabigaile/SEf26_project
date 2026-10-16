# NC APL upload — October 3, 2026

The September 2, 2026 catalog is live in the default Firestore database of
`wolfbyte-proj1`, under `apl/{upc}`. All 16,861 imported documents were read back
and compared field-for-field with the approved JSON. They represent 16,862
spreadsheet product rows because two identical-UPC rows share a document and
retain both complete records in `sourceRecords`.

The four verified leading-zero corrections, five separate UPC-E entries and
their UPC-A counterparts, and all 14 accepted source-code exceptions are present.
The exceptions retain `dataQuality` flags and are documented in
[the follow-up note](data/apl/reviews/2026-09-02/follow-up-items.md).

The three pre-existing test records were backed up. Demo records `001` and `002`
now have `eligible: false` and `catalogStatus: retired_demo`; their other fields
were preserved. The already-ineligible `M2_TEST_20260927` record was unchanged.
The collection therefore contains 16,864 total documents: 16,861 catalog entries
and three inactive test records. No participant records were modified.

## Access verification

The existing deployed rules allow signed-in clients to read the APL and disallow
client writes. Rules were not modified or redeployed. Their old temporary broad
access clause expired on October 1, 2026.

Live Firebase client requests verified:

- Signed-out product lookup is denied (HTTP 403).
- A temporary signed-in account could retrieve `039400011606`, `01568707`,
  `015000006877`, `037842037680`, `72036686541`, and `003800000120`.
- The app's category-and-eligibility substitute query returned three real
  eligible cheese products.
- The temporary account was deleted after testing. No email was sent.

This checks live client API access, including Firestore rules, and the exact
query used by `AplService`. Physical barcode scanning and the full Flutter UI
were not exercised during the upload. Users must sign in to the app configured
for `wolfbyte-proj1`. Nutrition enrichment and participant benefit calculations
remain separate from the APL catalog.

## Local evidence and recovery records

Generated outputs are ignored by Git. Keep these files locally:

- Catalog: `data/apl/generated/2026-09-02-included/apl-ready.json`
- Pre-upload APL backup: `data/apl/generated/upload-2026-10-03/before.json`
- Original rules snapshot: `data/apl/generated/firestore-before-upload/snapshot.json`
- Import plan and created IDs: `data/apl/generated/upload-2026-10-03/plan.json`
  and `write-targets.json`
- Verified result: `data/apl/generated/upload-2026-10-03/result.json`
- Signed-in test: `data/apl/generated/upload-2026-10-03/client-access-check.json`

Approved JSON SHA-256:
`e7d30b62a2742b905e6d74fb055d54f7b462dea66eb96947e019e1fe02ea08e9`.

The backup contains the three original APL records, not the entire database.
Any rollback should use that backup and the created-ID manifest after checking
for subsequent edits. The importer never deletes existing records.

## Repeat the preview or resume an interrupted upload

Run from `Project3`, using Node and Firebase CLI 15.32.1. This importer uses the
CLI's authentication and REST helpers; its compatibility was tested with that
version. No credentials are written into this repository. If the temporary CLI
installation no longer exists, install that version in a tools directory and
change the `--firebase-tools` path accordingly.

```sh
node scripts/import.js \
  --project wolfbyte-proj1 \
  --file data/apl/generated/2026-09-02-included/apl-ready.json \
  --firebase-tools /private/tmp/wolfbyte-firebase-tools/node_modules/firebase-tools \
  --account closeabigaile@gmail.com \
  --retire-demo \
  --output data/apl/generated/new-import-preview
```

Without `--write`, this reads remote APL data and writes a local preview/backup
only. Add `--write` and choose another new output directory to execute an import.
An unchanged re-run skips already matching products. Different existing products
cause the operation to stop; they are never silently overwritten. `--retire-demo`
affects only the two explicitly identified demo records, `001` and `002`.

Writes are committed sequentially in batches of 200, with preconditions against
overwriting concurrent edits. A failure stops the import. A retry builds a fresh
plan and skips completed records. The whole catalog upload is not atomic.
Later APL refreshes need a separate update policy, including withdrawal handling;
the initial importer deliberately does not replace conflicting existing data.

Local importer checks:

```sh
node --test scripts/test_import.cjs
node scripts/import.js --project wolfbyte-proj1 \
  --file data/apl/generated/2026-09-02-included/apl-ready.json --validate-only
```

`scripts/verify_apl_access.cjs` is a live integration check, not an offline test.
It creates a temporary password account and deletes it afterward. It only reads
Firestore and does not alter catalog products or rules. Its report records any
cleanup failure explicitly.
