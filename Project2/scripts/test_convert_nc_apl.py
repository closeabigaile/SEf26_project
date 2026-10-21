import unittest
from types import SimpleNamespace

from convert_nc_apl import barcode_issues, digits, make_record, partition, resolve_cell


class AplConversionTests(unittest.TestCase):
    def test_leading_zeros_follow_source_not_guesses(self):
        self.assertEqual(digits("0077890608524"), "0077890608524")
        self.assertEqual(digits(39400011606, "000000000000"), "039400011606")
        self.assertEqual(digits(37842037680, "@"), "37842037680")
        self.assertEqual(digits(30014, "General"), "30014")
        self.assertEqual(digits("02", width=2), "02")
        self.assertEqual(digits(1, width=3), "001")

    def test_malformed_identifiers_are_rejected(self):
        for value in (True, -12, 123.5, "1e12", "12/34", "１２３"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                digits(value)

    def test_barcode_flags_do_not_rewrite_source(self):
        self.assertEqual(barcode_issues("039400011606", "06"), [])
        self.assertEqual(barcode_issues("039400011607", "06"), ["check_digit_mismatch"])
        self.assertEqual(barcode_issues("30014", "19"), [])
        self.assertTrue(barcode_issues("30014", "06"))
        self.assertTrue(barcode_issues("37842037680", "19"))
        self.assertEqual(barcode_issues("01529902", "12"), ["eight_digit_format_needs_review"])

    def test_literal_formulas_resolved_without_execution(self):
        cell = SimpleNamespace(data_type="f", value='=UPPER("Fresh Apples")', coordinate="B3")
        self.assertEqual(resolve_cell(cell, SimpleNamespace(value="FRESH APPLES")), "FRESH APPLES")
        self.assertEqual(resolve_cell(cell, SimpleNamespace(value=None)), "FRESH APPLES")
        with self.assertRaises(ValueError):
            resolve_cell(cell, SimpleNamespace(value="OTHER"))
        cell.value = '=HYPERLINK("https://example.com", "text")'
        with self.assertRaises(ValueError):
            resolve_cell(cell, SimpleNamespace(value="text"))

    def test_duplicate_rows_are_all_preserved_for_review(self):
        values = ["039400011606", "BUSH'S PINTO BEANS", 6, "LEGUMES", "003", "CANNED BEANS", "CTR"]
        one = make_record(values, "@", 1505, {})
        two = make_record([values[0], "BUSHS PINTO BEANS 15.5 OZ", *values[2:]], "@", 16860, {})
        ready, review = partition([one, two])
        self.assertEqual(ready, [])
        self.assertEqual(len(review), 2)
        self.assertEqual([r["fields"]["source"]["row"] for r in review], [1505, 16860])
        self.assertTrue(all("duplicate_identifier" in r["issues"] for r in review))


if __name__ == "__main__":
    unittest.main()
