#!/usr/bin/env python3
"""Apply reviewed NC APL decisions locally, retaining every distinct UPC."""

import argparse
from collections import Counter, defaultdict
from copy import deepcopy
import json
from pathlib import Path
import shutil

from convert_nc_apl import barcode_issues, report_html


def apply_review(prepared, held, decisions, include_pending_as_is=False):
    prepared, held, decisions = deepcopy((prepared, held, decisions))
    if not prepared['source'] == held['source'] == decisions['source']:
        raise ValueError('Review source does not match the converted source')
    documents = {r['documentId']: r for r in prepared['documents']}
    if len(documents) != len(prepared['documents']):
        raise ValueError('Input contains duplicate document IDs')
    by_row = {r['fields']['source']['row']: r for r in held['records']}
    if (len(by_row) != len(held['records']) or
            len(decisions['decisions']) != len(by_row) or
            {d['sourceRow'] for d in decisions['decisions']} != set(by_row)):
        raise ValueError('Review decisions must cover each held row exactly once')
    duplicates = defaultdict(list)
    pending = []
    followups = []
    for decision in decisions['decisions']:
        record = by_row[decision['sourceRow']]
        fields, code = record['fields'], record['documentId']
        if (decision['sourceCode'] != code or decision['product'] != fields['name'] or
                decision['originalIssues'] != record['issues']):
            raise ValueError('Review row differs from the converted row')
        status = decision['status']
        decision['applied'] = False
        if status.startswith('Pending:'):
            if not include_pending_as_is:
                pending.append(record)
                continue
            expected_issue = {
                'Pending: leading zero': ['barcode_length_needs_review'],
                'Pending: identifier mismatch': ['check_digit_mismatch'],
            }.get(status)
            if (expected_issue != record['issues'] or not code.isascii() or
                    not code.isdigit() or code in documents or fields['upc'] != code):
                raise ValueError('Cannot retain this pending row as supplied')
            fields['dataQuality'] = {
                'status': 'included_as_supplied_pending_verification',
                'issues': list(record['issues']),
                'note': 'Included by user decision with the source identifier unchanged. Barcode verification remains open.',
            }
            documents[code] = {'documentId': code, 'fields': fields}
            decision['applied'] = True
            decision['verificationOutstanding'] = True
            decision['appliedAction'] = 'Included the exact source code unchanged; retained the identifier question for follow-up'
            if 'finding' in decision:
                decision['originalFinding'] = decision['finding']
            decision['finding'] = decision['appliedAction']
            followups.append(decision)
            continue
        if status == 'Explained: duplicate':
            if record['issues'] != ['duplicate_identifier']:
                raise ValueError('Duplicate has additional unresolved issues')
            duplicates[code].append(record)
            decision['appliedAction'] = 'Preserved both source records under the same UPC document'
        elif status == 'Supported: leading zero':
            candidate = decision['candidateCode']
            if (record['issues'] != ['barcode_length_needs_review'] or
                    len(code) != 11 or candidate != '0' + code or
                    barcode_issues(candidate, fields['categoryCode']) or
                    not decision['evidence']):
                raise ValueError('Leading-zero correction is not supported')
            fields['source']['originalUpc'] = code
            fields['upc'] = candidate
            fields['identifierType'] = 'upca'
            fields['identifierCorrection'] = {
                'kind': 'verified_leading_zero', 'original': code,
                'corrected': candidate, 'evidence': decision['evidence'],
            }
            if candidate in documents:
                raise ValueError('Leading-zero correction collides with an existing document')
            documents[candidate] = {'documentId': candidate, 'fields': fields}
            decision['appliedAction'] = 'Restored verified leading zero; preserved original code in provenance'
        elif status == 'Explained: alternate barcode':
            candidate = decision['candidateCode']
            # All five reviewed codes use the UPC-E suppression rule ending in 0.
            if len(code) != 8 or not code.isascii() or not code.isdigit() or code[0] != '0' or code[6] != '0':
                raise ValueError('Unreviewed UPC-E format')
            expanded = code[0:3] + code[6] + '0000' + code[3:6] + code[7]
            target = documents.get(candidate)
            if (record['issues'] != ['eight_digit_format_needs_review'] or expanded != candidate or
                    barcode_issues(candidate, fields['categoryCode']) or target is None or
                    target['fields']['source']['row'] not in decision['matchingSourceRows'] or
                    any(fields[k] != target['fields'][k] for k in
                        ('categoryCode', 'subcategoryCode', 'unitOfMeasure'))):
                raise ValueError('UPC-E does not match the reviewed source product')
            if code in documents:
                raise ValueError('Alternate UPC collides with an existing document')
            fields['identifierType'] = 'upce'
            fields['alternateUpcs'] = [candidate]
            target['fields']['alternateUpcs'] = sorted(set(target['fields'].get('alternateUpcs', []) + [code]))
            documents[code] = {'documentId': code, 'fields': fields}
            decision['appliedAction'] = 'Kept both UPCs as separate lookup documents with reciprocal alternateUpcs'
        else:
            raise ValueError(f'Unknown review status: {status}')
        decision['applied'] = True
        if 'finding' in decision:
            decision['originalFinding'] = decision['finding']
        decision['finding'] = decision['appliedAction']

    for code, group in duplicates.items():
        if len(group) < 2 or code in documents:
            raise ValueError('Duplicate group incomplete or conflicts with prepared data')
        fields = deepcopy(max(group, key=lambda r: r['fields']['source']['row'])['fields'])
        if any(r['fields'][k] != fields[k] for r in group
               for k in ('categoryCode', 'subcategoryCode', 'unitOfMeasure', 'eligible', 'state')):
            raise ValueError('Duplicate rows disagree on eligibility/category/unit')
        fields['sourceRecords'] = [r['fields'] for r in sorted(group, key=lambda r: r['fields']['source']['row'])]
        documents[code] = {'documentId': code, 'fields': fields}

    represented_rows = []
    for doc in documents.values():
        fields = doc['fields']
        represented_rows.extend(r['source']['row'] for r in fields.get('sourceRecords', [fields]))
    represented_rows.extend(r['fields']['source']['row'] for r in pending)
    original_rows = [r['fields']['source']['row'] for r in prepared['documents']] + list(by_row)
    if Counter(represented_rows) != Counter(original_rows):
        raise ValueError('Source-row reconciliation failed')
    summary = prepared['summary']
    summary['readyDocuments'] = len(documents)
    summary['reviewRows'] = len(pending)
    summary['readySourceRows'] = len(represented_rows) - len(pending)
    summary['duplicateRowsRetainedWithinDocuments'] = summary['readySourceRows'] - len(documents)
    summary['appliedReviewRows'] = sum(d['applied'] for d in decisions['decisions'])
    summary['issues'] = dict(Counter(i for r in pending for i in r['issues']))
    summary['includedFollowUpRows'] = len(followups)
    summary['includedFollowUpIssues'] = dict(Counter(i for d in followups for i in d['originalIssues']))
    metadata = {k: v for k, v in prepared.items() if k != 'documents'}
    metadata.update(schemaVersion=2, reviewApplied=True,
                    retentionPolicy='Keep distinct UPCs as separate documents; retain identical-UPC rows in sourceRecords')
    decisions['scope'] = 'User-directed local update: retain distinct UPCs and duplicate source records; apply four supported leading-zero corrections. No Firebase writes.'
    if include_pending_as_is:
        decisions['scope'] += ' Include remaining identifiers exactly as supplied, with open verification notes.'
    return metadata, list(documents.values()), pending, decisions


def followup_markdown(decisions):
    rows = [d for d in decisions['decisions'] if d.get('verificationOutstanding')]
    source = decisions['source']
    lines = [
        '# NC WIC APL identifier follow-up', '',
        f"Source: {source['file']} (sheet {source['sheet']}).", '',
        f"Source SHA-256: `{source['sha256']}`.", '',
        f'All {len(rows)} entries below are included in the prepared catalog with their source codes unchanged.',
        'The user requested keeping the four unverified 11-digit codes without a leading zero and including the ten check-digit mismatches.',
        'Inclusion does not mark these barcode questions as resolved. Nothing has been uploaded to Firebase.', '',
        'Previously verified leading-zero corrections remain applied. Distinct UPCs and identical-UPC source records remain preserved.', '',
    ]
    for status, title in [('Pending: leading zero', 'Four 11-digit codes retained unchanged'),
                          ('Pending: identifier mismatch', 'Ten check-digit mismatches retained unchanged')]:
        lines.extend([f'## {title}', '', '| Excel row | Product | Included code | Follow-up |',
                      '| --- | --- | --- | --- |'])
        for d in rows:
            if d['status'] != status:
                continue
            note = d.get('originalFinding', 'Compare the identifier with the package barcode or NC APL clarification.')
            if status == 'Pending: leading zero':
                note = 'Keep this 11-digit source code. Verify against the package or NC APL if lookup fails. No leading zero was added.'
            clean = lambda s: str(s).replace('|', '\\|').replace('\n', ' ')
            lines.append(f"| {d['sourceRow']} | {clean(d['product'])} | `{d['sourceCode']}` | {clean(note)} |")
        lines.append('')
    lines += ['## Recording a future resolution', '',
              'Record the Excel row, original code, observed package barcode, package size, evidence, and resolution date before changing an identifier. Keep the original code and provenance. Do not replace a check digit just to make validation pass.', '',
              'Product identity evidence from another state’s WIC list does not independently establish current NC eligibility.', '']
    return '\n'.join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path, required=True)
    parser.add_argument('--decisions', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--include-pending-as-is', action='store_true',
                        help='Include remaining reviewed identifiers unchanged and retain follow-up notes')
    args = parser.parse_args()
    if args.output.exists():
        parser.error('Choose a new output directory to preserve previous exports')
    read = lambda p: json.loads(p.read_text(encoding='utf-8'))
    metadata, documents, pending, decisions = apply_review(
        read(args.input / 'apl-ready.json'), read(args.input / 'apl-review.json'), read(args.decisions),
        include_pending_as_is=args.include_pending_as_is)
    args.output.mkdir(parents=True)
    for name, data in (
        ('apl-ready.json', {**metadata, 'documents': documents}),
        ('apl-review.json', {**metadata, 'records': pending}),
        ('conversion-summary.json', metadata), ('applied-review.json', decisions),
    ):
        (args.output / name).write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    shutil.copyfile(args.input / 'source-rows.jsonl', args.output / 'source-rows.jsonl')
    followups = [d for d in decisions['decisions'] if d.get('verificationOutstanding')]
    if followups:
        (args.output / 'follow-up-items.json').write_text(json.dumps(
            {'source': metadata['source'], 'records': followups}, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
        (args.output / 'follow-up-items.md').write_text(followup_markdown(decisions), encoding='utf-8')
    (args.output / 'report.html').write_text(report_html(metadata, pending), encoding='utf-8')
    print(json.dumps(metadata['summary'], indent=2))


if __name__ == '__main__':
    main()
