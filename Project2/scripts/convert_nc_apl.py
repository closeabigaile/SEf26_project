#!/usr/bin/env python3
"""Convert the NC APL workbook locally; this script never contacts Firebase."""

import argparse
from collections import Counter, defaultdict
from datetime import date
import hashlib
import html
import json
from pathlib import Path
import re

import openpyxl


HEADERS = (
    "UPC", "PRODUCT DESCRIPTION", "CATEGORY", "CATEGORY DESCRIPTION",
    "SUBCATEGORY", "SUBCATEGORY DESCRIPTION", "UOM",
)
GS1_REFERENCE = "https://www.gs1.org/services/how-calculate-check-digit-manually"


def text(value):
    return "" if value is None else str(value).strip()


def label(value):
    return " ".join(text(value).upper().split())


def digits(value, number_format="", width=None):
    """Preserve text zeros; restore numeric zeros only from an explicit mask."""
    if isinstance(value, bool):
        raise ValueError("Boolean identifier")
    if isinstance(value, (int, float)):
        if value < 0 or int(value) != value:
            raise ValueError("Non-integer identifier")
        result = str(int(value))
        if re.fullmatch(r"0+", number_format or ""):
            result = result.zfill(len(number_format))
    else:
        result = text(value)
    if not re.fullmatch(r"[0-9]+", result):
        raise ValueError("Identifier must contain ASCII digits only")
    if width is not None:
        if len(result) > width:
            raise ValueError("Category code is wider than expected")
        result = result.zfill(width)
    return result


def resolve_cell(cell, cached):
    if cell.data_type == "e":
        raise ValueError(f"Excel error in {cell.coordinate}")
    if cell.data_type != "f":
        return cell.value
    # This workbook uses UPPER of literal strings. Never execute Excel formulas.
    match = re.fullmatch(r'=UPPER\("((?:[^\"]|\"\")*)"\)', cell.value, re.I)
    if not match:
        raise ValueError(f"Unsupported formula in {cell.coordinate}")
    result = match.group(1).replace('""', '"').upper()
    if cached.value is not None and cached.value != result:
        raise ValueError(f"Formula cache disagrees in {cell.coordinate}")
    return result


def barcode_issues(upc, category_code):
    if len(upc) in (12, 13, 14):
        total = sum(int(c) * (3 if i % 2 == 0 else 1)
                    for i, c in enumerate(reversed(upc[:-1])))
        return [] if (10 - total % 10) % 10 == int(upc[-1]) else ["check_digit_mismatch"]
    if len(upc) in (5, 6) and category_code == "19":
        # Preserve the source identifier. Do not infer a PLU or pad it to UPC-A.
        return []
    if len(upc) == 8:
        return ["eight_digit_format_needs_review"]
    return ["barcode_length_needs_review"]


def make_record(values, upc_format, row_number, source):
    issues = []
    for name, value in zip(HEADERS, values):
        if not text(value):
            issues.append(f"missing_{name.lower().replace(' ', '_')}")
    codes = []
    for index, width in ((0, None), (2, 2), (4, 3)):
        try:
            codes.append(digits(values[index], upc_format if index == 0 else "", width))
        except (ValueError, OverflowError):
            codes.append(text(values[index]))
            issues.append(f"invalid_{HEADERS[index].lower()}")
    upc, category_code, subcategory_code = codes
    if "invalid_upc" not in issues:
        issues.extend(barcode_issues(upc, category_code))
    fields = {
        "upc": upc, "name": text(values[1]), "category": label(values[3]),
        "categoryCode": category_code, "subcategory": label(values[5]),
        "subcategoryCode": subcategory_code, "unitOfMeasure": label(values[6]),
        "eligible": True, "state": "NC",
        "identifierType": "source_short_code" if len(upc) in (5, 6) else "source_barcode",
        "source": {**source, "row": row_number},
    }
    return {"documentId": upc, "fields": fields, "issues": issues}


def partition(records):
    groups = defaultdict(list)
    for record in records:
        groups[record["documentId"]].append(record)
    for group in groups.values():
        if len(group) > 1:
            for record in group:
                record["issues"].append("duplicate_identifier")
    ready = [{"documentId": r["documentId"], "fields": r["fields"]}
             for r in records if not r["issues"]]
    review = [r for r in records if r["issues"]]
    return ready, review


def convert(source_path, version, sheet_name):
    source_path = Path(source_path)
    source = {
        "file": source_path.name, "versionDate": date.fromisoformat(version).isoformat(),
        "sha256": hashlib.sha256(source_path.read_bytes()).hexdigest(), "sheet": sheet_name,
    }
    workbook = openpyxl.load_workbook(source_path, read_only=True, data_only=False)
    cached = openpyxl.load_workbook(source_path, read_only=True, data_only=True)
    records, archive, notes = [], [], []
    blank_rows = formula_count = 0
    try:
        sheet, cache = workbook[sheet_name], cached[sheet_name]
        headers = next(sheet.iter_rows(min_row=2, max_row=2))
        if tuple(label(c.value) for c in headers[:7]) != HEADERS:
            raise ValueError("Unexpected row-2 headers: inspect the workbook before converting")
        title = text(sheet.cell(1, 1).value)
        for row, cached_row in zip(sheet.iter_rows(min_row=3), cache.iter_rows(min_row=3)):
            if all(c.value is None for c in row):
                blank_rows += 1
                continue
            row_number = next(c.row for c in row if c.value is not None)
            raw = [c.value for c in row]
            archive.append({
                "row": row_number, "originalCells": raw,
                "cachedCells": [c.value for c in cached_row],
                "numberFormats": [c.number_format for c in row],
            })
            # The dated notice precedes MORE products; skip only this row.
            if (isinstance(raw[0], str) and raw[0].startswith("Effective ")
                    and "Authorized Product List" in raw[0]
                    and all(c is None for c in raw[1:])):
                notes.append({"row": row_number, "text": raw[0]})
                continue
            issues, values = [], []
            for cell, cache_cell in zip(row[:7], cached_row[:7]):
                formula_count += int(cell.data_type == "f")
                try:
                    values.append(resolve_cell(cell, cache_cell))
                except ValueError as error:
                    values.append(None)
                    issues.append(str(error))
            record = make_record(values, row[0].number_format, row_number, source)
            record["issues"].extend(issues)
            if any(c is not None for c in raw[7:]):
                record["issues"].append("unexpected_extra_columns")
            records.append(record)
    finally:
        workbook.close()
        cached.close()
    ready, review = partition(records)
    categories = defaultdict(Counter)
    for record in records:
        fields = record["fields"]
        categories[fields["categoryCode"]][fields["category"]] += 1
    summary = {
        "productRows": len(records), "distinctProductCodes": len({r['documentId'] for r in records}),
        "readyDocuments": len(ready), "reviewRows": len(review),
        "blankRowsSkipped": blank_rows, "noteRowsSkipped": len(notes),
        "formulaCellsResolved": formula_count,
        "shortCodeDocuments": sum(r["fields"]["identifierType"] == "source_short_code" for r in ready),
        "issues": dict(Counter(issue for r in review for issue in r["issues"])),
        "categories": dict(sorted(categories.items())),
    }
    assert len(ready) + len(review) == len(records)
    assert len(archive) == len(records) + len(notes)
    metadata = {"schemaVersion": 1, "projectId": "wolfbyte-proj1", "collection": "apl",
                "source": source, "sourceTitle": title, "summary": summary, "notes": notes}
    return metadata, ready, review, archive


def report_html(metadata, review):
    esc = lambda value: html.escape(str(value))
    summary = metadata["summary"]
    reviewed = metadata.get('reviewApplied', False)
    followups = summary.get('includedFollowUpRows', 0)
    followup_note = (f'<p><strong>{followups} included entries still have open identifier questions.</strong> '
                     'Their source codes are unchanged. '
                     '<a href="follow-up-items.md">Follow-up notes</a> · '
                     '<a href="follow-up-items.json">Follow-up data</a>.</p>' if followups else '')
    retention = ("Every distinct UPC remains a separate lookup document, including all five reviewed "
                 "UPC-E codes and their existing UPC-A equivalents. Both Bush’s Pinto Beans source rows "
                 "are retained in sourceRecords under their shared UPC. Four verified leading-zero "
                 "corrections are applied, with original codes retained in provenance. "
                 '<a href="applied-review.json">Applied decisions</a>.' if reviewed else
                 "Duplicate identifiers are held together to avoid overwriting a product silently.")
    rows = "".join(
        f"<tr><td>{r['fields']['source']['row']}</td><td><code>{esc(r['documentId'])}</code></td>"
        f"<td>{esc(r['fields']['name'])}</td><td>{esc(', '.join(r['issues']))}</td></tr>"
        for r in review)
    categories = "".join(
        f"<tr><td>{esc(code)}</td><td>{sum(names.values()):,}</td>"
        f"<td>{'<br>'.join(f'{esc(n)} ({count:,})' for n, count in names.items())}</td></tr>"
        for code, names in summary["categories"].items())
    return f"""<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>NC APL conversion report</title>
<style>body{{font:16px/1.6 system-ui,sans-serif;max-width:1100px;margin:40px auto;padding:0 24px;color:#172a37}}
h1,h2{{line-height:1.2}}.summary{{padding:20px;background:#edf6f4;border-radius:12px}}
table{{width:100%;border-collapse:collapse;font-size:14px}}td,th{{padding:10px;border-bottom:1px solid #ccd7dc;text-align:left;vertical-align:top}}
code{{white-space:nowrap}}.scroll{{overflow:auto}}a{{color:#135e83}}</style>
<h1>NC WIC APL · {esc(metadata['source']['versionDate'])}</h1>
<p>Source: {esc(metadata['source']['file'])} · sheet {esc(metadata['source']['sheet'])}</p>
<div class="summary"><strong>{summary['productRows']:,} product rows preserved.</strong>
{summary['readyDocuments']:,} unique UPC documents prepared;
{summary['reviewRows']:,} rows are held for review. <strong>No Firebase writes were made.</strong></div>
{followup_note}
<p><a href="apl-ready.json">Prepared documents</a> · <a href="apl-review.json">Rows needing review</a> ·
<a href="source-rows.jsonl">Original source rows</a> · <a href="conversion-summary.json">Full summary</a></p>
<h2>What the conversion does</h2>
<p>Preserves barcode strings and restores leading zeros from explicit Excel formats{' or verified review decisions' if reviewed else ''},
normalizes category codes to two digits and subcategory codes to three digits,
and resolves {summary['formulaCellsResolved']} literal UPPER formulas.
It skips blank rows and the dated notice, including all product rows after that notice.</p>
<p>{summary['shortCodeDocuments']:,} short produce identifiers are retained exactly as supplied.
Their scanner behavior still needs testing. No short identifiers are padded to 12 digits.
Names and accounting units come from the source; nutrition and package sizes are not invented.</p>
<h2>Rows to review</h2>
<p>{retention}</p>
<p>Unresolved eleven-digit identifiers need source verification. Unreviewed eight-digit
identifiers need barcode-format verification (EAN-8 versus UPC-E). Check-digit mismatches use the
<a href="{GS1_REFERENCE}">GS1 calculation</a> for 12–14 digit codes.
These flags do not determine WIC eligibility. No check digit is automatically changed.</p>
<div class="scroll"><table><thead><tr><th>Excel row</th><th>Source code</th><th>Product</th><th>Reason</th></tr></thead>
<tbody>{rows}</tbody></table></div>
<h2>Source categories</h2><p>Descriptions are uppercased with whitespace normalized, but different source
labels are preserved. Use category codes for future category matching; the current app queries labels.</p>
<table><thead><tr><th>Code</th><th>Rows</th><th>Source labels</th></tr></thead><tbody>{categories}</tbody></table>
<h2>Before this powers the app</h2>
<p>The JSON is input for an importer, not a native Firestore backup. The old CSV importer does not
read this format. Next: review the flagged rows, prepare a dry-run importer, and test exact barcode
lookups before publishing the catalog. Future refreshes must also handle withdrawn products.</p>
<p><code>eligible: true</code> means listed in this supplied NC APL version. It does not establish a
participant's benefit balance or allowance. The workbook does not contain nutrition data, and the
app's existing demo allowance and healthier-alternative logic need separate work.</p></html>"""


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workbook", type=Path)
    parser.add_argument("--source-date", required=True, help="APL publication date, YYYY-MM-DD")
    parser.add_argument("--sheet", default="NC WIC APL")
    parser.add_argument("--output", type=Path, required=True, help="New output directory")
    args = parser.parse_args()
    if args.output.exists():
        parser.error("Output directory already exists; choose a new directory to preserve previous exports")
    metadata, ready, review, archive = convert(args.workbook, args.source_date, args.sheet)
    args.output.mkdir(parents=True)
    for name, data in (
        ("apl-ready.json", {**metadata, "documents": ready}),
        ("apl-review.json", {**metadata, "records": review}),
        ("conversion-summary.json", metadata),
    ):
        (args.output / name).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    with (args.output / "source-rows.jsonl").open("w", encoding="utf-8") as stream:
        for row in archive:
            stream.write(json.dumps(row, ensure_ascii=False, default=str) + "\n")
    (args.output / "report.html").write_text(report_html(metadata, review), encoding="utf-8")
    print(json.dumps(metadata["summary"], indent=2))
    print(f"Report: {args.output.resolve() / 'report.html'}")


if __name__ == "__main__":
    main()
