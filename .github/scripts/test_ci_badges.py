"""Checks that missing, failed, or partial evidence cannot produce passing badges."""
import json
from pathlib import Path
import tempfile
import unittest
from xml.etree import ElementTree

from ci_badges import generate, line_coverage, svg, test_counts


class BadgeEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def events(self, entries):
        path = self.root / 'tests.jsonl'
        path.write_text('\n'.join(json.dumps(x) for x in entries))
        return path

    def test_hidden_skipped_and_late_errors(self):
        result = test_counts(self.events([
            {'type': 'testDone', 'testID': 1, 'hidden': True, 'result': 'success'},
            {'type': 'testDone', 'testID': 2, 'skipped': True, 'result': 'success'},
            {'type': 'testDone', 'testID': 3, 'result': 'success'},
            {'type': 'testDone', 'testID': 4, 'result': 'success'},
            {'type': 'error', 'testID': 4},
            {'type': 'done', 'success': False},
        ]))
        self.assertEqual(result, {'passed': 1, 'failed': 1, 'skipped': 1, 'complete': True, 'success': False})

    def test_incomplete_stream(self):
        result = test_counts(self.events([
            {'type': 'testStart', 'test': {'id': 9}},
            {'type': 'done', 'success': True},
        ]))
        self.assertFalse(result['complete'])
        self.assertFalse(test_counts(self.events([]))['complete'])

    def test_hidden_loading_error_is_a_failure(self):
        result = test_counts(self.events([
            {'type': 'testDone', 'testID': 1, 'hidden': True, 'result': 'success'},
            {'type': 'error', 'testID': 1},
            {'type': 'done', 'success': False},
        ]))
        self.assertEqual(result['failed'], 1)

    def test_lcov_deduplicates_lines_and_uses_hits(self):
        path = self.root / 'lcov.info'
        path.write_text('SF:lib/a.dart\nDA:1,0\nDA:2,1\nLF:999\nend_of_record\nSF:lib/a.dart\nDA:1,4\nDA:3,0\nend_of_record\n')
        self.assertEqual(line_coverage(path), (2, 3))

    def test_empty_or_invalid_coverage_rejected(self):
        path = self.root / 'lcov.info'
        for content in ['', 'DA:1,1\n', 'SF:a.dart\nDA:1,-1\n']:
            path.write_text(content)
            with self.assertRaises(ValueError):
                line_coverage(path)

    def environment(self):
        return {'REPORTS_AVAILABLE': 'true', 'GITHUB_SHA': 'abc123',
                'GITHUB_REF_NAME': 'test_all_milestones', 'GITHUB_SERVER_URL': 'https://github.com',
                'GITHUB_REPOSITORY': 'example/repo', 'GITHUB_RUN_ID': '10'}

    def fixture(self, outcome='success'):
        reports = self.root / 'input/build/test-results'
        reports.mkdir(parents=True)
        (reports / 'steps.json').write_text(json.dumps({'tests': {'outcome': outcome}}))
        (reports / 'flutter-tests.jsonl').write_text(self.events([
            {'type': 'testDone', 'testID': 1, 'result': 'success'},
            {'type': 'done', 'success': True},
        ]).read_text())
        coverage = self.root / 'input/coverage'
        coverage.mkdir()
        (coverage / 'lcov.info').write_text('SF:lib/a.dart\nDA:1,1\nDA:2,0\nend_of_record\n')
        return self.root / 'input', self.root / 'output'

    def test_complete_results_generate_measured_badges(self):
        source, output = self.fixture()
        result = generate(source, output, self.environment())
        self.assertEqual(result['badges']['tests'], '1/1 passing')
        self.assertEqual(result['coverage']['percent'], 50.0)
        self.assertEqual(result['badges']['build'], 'skipped')
        self.assertTrue((output / 'lcov.info').exists())
        for path in output.glob('*.svg'):
            ElementTree.parse(path)

    def test_command_failure_overrides_successful_events(self):
        source, output = self.fixture('failure')
        result = generate(source, output, self.environment())
        self.assertIn('(failed)', result['badges']['tests'])
        self.assertIsNone(result['coverage'])

    def test_empty_successful_suite_cannot_publish_coverage(self):
        source, output = self.fixture()
        (source / 'build/test-results/flutter-tests.jsonl').write_text(
            '{"type": "done", "success": true}\n')
        result = generate(source, output, self.environment())
        self.assertIsNone(result['coverage'])
        self.assertNotIn('fill="#4c1"', (output / 'tests.svg').read_text())

    def test_missing_artifact_cannot_use_leftover_files(self):
        source, output = self.fixture()
        env = self.environment()
        env['REPORTS_AVAILABLE'] = 'false'
        result = generate(source, output, env)
        self.assertEqual(result['badges']['tests'], 'skipped')
        self.assertIsNone(result['coverage'])
        self.assertFalse((output / 'lcov.info').exists())

    def test_malformed_json_is_unavailable(self):
        source, output = self.fixture()
        (source / 'build/test-results/flutter-tests.jsonl').write_text('not JSON')
        result = generate(source, output, self.environment())
        self.assertEqual(result['badges']['tests'], 'unavailable')
        self.assertIsNone(result['coverage'])

    def test_svg_escapes_xml(self):
        root = ElementTree.fromstring(svg('A & B', '<unknown>', '#555'))
        self.assertEqual(root.attrib['aria-label'], 'A & B: <unknown>')


if __name__ == '__main__':
    unittest.main()
