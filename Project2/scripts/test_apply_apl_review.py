import unittest

from apply_apl_review import apply_review
from convert_nc_apl import make_record


class ApplyReviewTests(unittest.TestCase):
    def setUp(self):
        source = {'sha256': 'test-source', 'versionDate': '2026-09-02',
                  'file': 'fixture.xlsx', 'sheet': 'NC WIC APL'}

        def record(code, row, name='Product', category=12):
            return make_record([code, name, category, 'CATEGORY', 3, 'SUBCATEGORY', 'OZ'], '@', row, source)

        existing = record('015000006877', 2698)
        short = record('01568707', 2723)
        zero = record('37842037680', 8819, 'Rambutan', 19)
        duplicate1 = record('039400011606', 1505, 'Pinto beans', 6)
        duplicate2 = record('039400011606', 16860, 'Pinto beans 15.5 OZ', 6)
        duplicate1['issues'] = duplicate2['issues'] = ['duplicate_identifier']
        pending = record('72036686541', 9995, 'Mushrooms', 19)
        records = [short, zero, duplicate1, duplicate2, pending]
        self.prepared = {'source': source, 'summary': {'productRows': 6},
                         'documents': [{'documentId': existing['documentId'], 'fields': existing['fields']}]}
        self.held = {'source': source, 'records': records}
        statuses = ['Explained: alternate barcode', 'Supported: leading zero',
                    'Explained: duplicate', 'Explained: duplicate', 'Pending: leading zero']
        self.decisions = {'source': source, 'decisions': [
            {'sourceRow': r['fields']['source']['row'], 'sourceCode': r['documentId'],
             'product': r['fields']['name'], 'originalIssues': r['issues'], 'status': status,
             'evidence': [{'title': 'Reviewed evidence'}]}
            for r, status in zip(records, statuses)]}
        self.decisions['decisions'][0].update(candidateCode='015000006877', matchingSourceRows=[2698])
        self.decisions['decisions'][1]['candidateCode'] = '037842037680'

    def run_review(self):
        return apply_review(self.prepared, self.held, self.decisions)

    def test_keep_both_upcs_and_all_duplicate_source_rows(self):
        metadata, docs, pending, decisions = self.run_review()
        by_id = {r['documentId']: r['fields'] for r in docs}
        self.assertEqual(set(by_id), {'015000006877', '01568707', '037842037680', '039400011606'})
        self.assertEqual(by_id['01568707']['alternateUpcs'], ['015000006877'])
        self.assertEqual(by_id['015000006877']['alternateUpcs'], ['01568707'])
        self.assertEqual([r['source']['row'] for r in by_id['039400011606']['sourceRecords']], [1505, 16860])
        self.assertEqual(by_id['037842037680']['source']['originalUpc'], '37842037680')
        self.assertEqual([r['documentId'] for r in pending], ['72036686541'])
        self.assertEqual(metadata['summary']['readySourceRows'], 5)
        self.assertEqual(metadata['summary']['appliedReviewRows'], 4)
        self.assertNotIn('alternateUpcs', self.prepared['documents'][0]['fields'])

    def test_stale_source_rejected(self):
        self.decisions['source'] = {'sha256': 'different'}
        with self.assertRaises(ValueError):
            self.run_review()

    def test_include_unverified_eleven_digit_code_without_padding(self):
        meta, docs, held, decisions = apply_review(self.prepared, self.held, self.decisions, True)
        by_id = {r['documentId']: r['fields'] for r in docs}
        self.assertIn('72036686541', by_id)
        self.assertNotIn('072036686541', by_id)
        self.assertEqual(by_id['72036686541']['upc'], '72036686541')
        self.assertEqual(by_id['72036686541']['dataQuality']['issues'], ['barcode_length_needs_review'])
        self.assertEqual(held, [])
        self.assertEqual(meta['summary']['includedFollowUpRows'], 1)
        self.assertTrue(decisions['decisions'][-1]['verificationOutstanding'])
        self.assertIn('037842037680', by_id)

    def test_include_checksum_mismatch_without_repairing_check_digit(self):
        record = self.held['records'][-1]
        record['documentId'] = record['fields']['upc'] = '003800000120'
        record['issues'] = ['check_digit_mismatch']
        decision = self.decisions['decisions'][-1]
        decision.update(sourceCode='003800000120', originalIssues=record['issues'],
                        status='Pending: identifier mismatch', finding='Needs package verification')
        meta, docs, held, decisions = apply_review(self.prepared, self.held, self.decisions, True)
        fields = next(r['fields'] for r in docs if r['documentId'] == '003800000120')
        self.assertEqual(fields['upc'], '003800000120')
        self.assertEqual(fields['dataQuality']['issues'], ['check_digit_mismatch'])
        self.assertEqual(meta['summary']['includedFollowUpIssues'], {'check_digit_mismatch': 1})
        self.assertEqual(held, [])
        from apply_apl_review import followup_markdown
        note = followup_markdown(decisions)
        self.assertIn('003800000120', note)
        self.assertIn('Needs package verification', note)

    def test_unreviewed_candidate_rejected(self):
        self.decisions['decisions'][1]['candidateCode'] = '037842037681'
        with self.assertRaises(ValueError):
            self.run_review()

    def test_conflicting_duplicate_not_silently_selected(self):
        self.held['records'][3]['fields']['unitOfMeasure'] = 'CTR'
        with self.assertRaises(ValueError):
            self.run_review()

    def test_same_names_with_distinct_upcs_are_preserved(self):
        self.held['records'][1]['fields']['name'] = 'Product'
        self.decisions['decisions'][1]['product'] = 'Product'
        _, docs, _, _ = self.run_review()
        self.assertEqual(len([d for d in docs if d['fields']['name'] == 'Product']), 3)

    def test_correction_collision_rejected(self):
        from copy import deepcopy
        collision = deepcopy(self.held['records'][1])
        collision['documentId'] = collision['fields']['upc'] = '037842037680'
        collision['fields']['source']['row'] = 999
        self.prepared['documents'].append(collision)
        with self.assertRaises(ValueError):
            self.run_review()


if __name__ == '__main__':
    unittest.main()
