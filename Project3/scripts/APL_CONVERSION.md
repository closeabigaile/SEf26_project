# Convert an NC WIC APL spreadsheet

The converter reads the `.xlsx` directly. Do not manually retype products or
resave the UPC column as numbers. The source workbook is never modified, and
conversion never contacts Firebase or requires credentials.

From `Project3`, install the read-only spreadsheet dependency in a local environment:

```sh
python3 -m venv scripts/.venv-apl
scripts/.venv-apl/bin/python -m pip install -r scripts/requirements-apl.txt
scripts/.venv-apl/bin/python scripts/convert_nc_apl.py \
  "$HOME/Desktop/NC WIC APL September_02_2026.xlsx" \
  --source-date 2026-09-02 \
  --output data/apl/generated/2026-09-02
```

Use a new output directory on every run. The date is the source publication date,
not today's date. Verify it against the workbook title. The converter expects
the `NC WIC APL` sheet, title in row 1, and the seven source headers in row 2.
Unknown headers fail conversion; unsupported formulas or unexpected data are
held for review. Products after the dated notice are included.

## Outputs

- `report.html`: readable counts, review rows, and source category labels.
- `apl-ready.json`: prepared unique UPC documents (including explicitly accepted
  source-code exceptions when the review policy below is applied), using
  `apl/{documentId}` with the exact source identifier. This is importer input,
  **not a Firestore managed export** or a Firebase-console upload file.
- `apl-review.json`: all rows with ambiguous formats, check-digit mismatches,
  or duplicate identifiers. No duplicate is silently selected over another.
- `source-rows.jsonl`: every nonblank data/note row, original cell values,
  formulas, cached values, and number formats, including held rows.
- `conversion-summary.json`: counts, notes, source filename, version, and SHA-256.

Generated files are ignored by Git; the converter and dependency pin are tracked.
Keep the original workbook for reproducibility. No product row is discarded:
the initial conversion's ready document count + review row count must equal source
product row count. Reviewed exports account for identical-UPC rows separately.

## Mapping and review policy

| Excel column | Document field |
| --- | --- |
| UPC | `upc` and document ID, always strings |
| PRODUCT DESCRIPTION | `name` |
| CATEGORY | `categoryCode`, two digits |
| CATEGORY DESCRIPTION | `category`, uppercase and whitespace normalized |
| SUBCATEGORY | `subcategoryCode`, three digits |
| SUBCATEGORY DESCRIPTION | `subcategory`, uppercase and whitespace normalized |
| UOM | `unitOfMeasure`, uppercase |

Documents also include `eligible: true`, `state: NC`, identifier type, and source
provenance including the Excel row. Eligibility means listed in this supplied
APL version; it does not establish a participant's benefits or remaining balance.
UOM is the source accounting unit, not an inferred package size. No brands,
nutrition data, FDC IDs, or package-size quantities are fabricated.

Text UPCs retain leading zeros. Numeric UPCs are padded only when their Excel
number format is an explicit run of zeros. Five/six-digit category-19 identifiers
are preserved as source short codes; no PLU transformation is assumed. Eight-digit
codes are held until their barcode format is established. Eleven-digit codes
are held rather than guessing missing digits. For 12–14 digits, the converter
uses the [GS1 check-digit calculation](https://www.gs1.org/services/how-calculate-check-digit-manually).
A mismatch flags source review, not a conclusion about WIC eligibility.

The only supported formulas are `UPPER("literal text")`; they are resolved
without running Excel code and checked against cached results when present.

## Next step: importer and application verification

### Applied review policy (October 3, 2026)

The user requested that duplicate products and multiple UPCs be kept. The reviewed
current export is `data/apl/generated/2026-09-02-included/`. Reproduce it after the initial
conversion with:

```sh
scripts/.venv-apl/bin/python scripts/apply_apl_review.py \
  --input data/apl/generated/2026-09-02 \
  --decisions data/apl/reviews/2026-09-02/review-decisions.json \
  --include-pending-as-is \
  --output data/apl/generated/2026-09-02-included
```

Every distinct UPC has its own document. The five reviewed Gerber UPC-E codes
remain separate from their existing UPC-A entries, with reciprocal `alternateUpcs`
metadata. There is no deduplication by product name. Identical-UPC rows share one
lookup document, with both complete source records in `sourceRecords`; the latest
source row provides its top-level display fields. Category/unit conflicts stop
the update instead of silently choosing one row.

The four supported leading-zero corrections are applied and the original values
are retained in provenance. At the user's request, the remaining four 11-digit
codes are included without adding a zero, and the ten check-digit mismatches
are also included unchanged. Those 14 documents have `dataQuality` metadata
marking verification as open, and are listed in `follow-up-items.md` and
`follow-up-items.json`. They are not held out of the catalog. The original conversion and
source workbook are preserved. The applied export includes `applied-review.json`.
For reconciliation, `readySourceRows + reviewRows = productRows`; document counts
are smaller because identical UPCs share one document.

The earlier review's suggestion to collapse Gerber UPCs into aliases is superseded
by this retention policy. These scripts perform no Firebase writes.

The current export contains 16,861 UPC documents representing all 16,862 source
product rows, zero held rows, and 14 included entries with open identifier
questions. The retained follow-up note is also saved at
`data/apl/reviews/2026-09-02/follow-up-items.md`. Including the exceptions does not
mean their barcodes passed validation. The earlier `-reviewed` export is historical.

`scripts/import.js` now imports the reviewed JSON with a read-only preview,
explicit `wolfbyte-proj1` destination, awaited writes, precondition checks,
backups and full read-back comparison. The initial upload is complete; see
[the upload record](../FIREBASE_UPLOAD.md). Quality flags and follow-up notes
were preserved. The initial importer refuses conflicting existing documents;
it does not implement automatic replacement of later APL versions.
Future refreshes must remove or deactivate products withdrawn from the APL;
blindly merging each new version leaves old approvals in place.

The current app reads exact barcode IDs and queries substitutes by category
description. Test actual scanner values, including leading-zero formats and
short produce codes, before activation. Category codes are more consistent than
the source's varying labels and should drive future benefit/category logic.
The workbook provides no nutrition enrichment, and the current demo benefit
allowances and healthier-alternative logic need separate implementation work.

Run converter unit tests from `Project3`:

```sh
scripts/.venv-apl/bin/python -m unittest discover -s scripts -p 'test_*apl*.py'
```
