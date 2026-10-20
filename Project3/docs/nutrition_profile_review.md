# Offline nutrition profile review

Reviewed 2026-09-27. These are explicitly **TEST PROFILES**, not real people,
clinical plans, WIC-approved products, or a validation of the full app.

## Data and reproducibility

- `test/fixtures/nutrition_catalog_100.csv` has 100 distinct USDA survey foods:
  16 fruit, 24 vegetables, 35 protein foods, and 25 grains. Eighty-one are
  allowed into meal combinations after explicit test-catalog suitability
  review. The other 19 remain in the catalog as challenge cases.
- Calories, protein, fibre, sodium, and saturated fat come from the matching
  [USDA FNDDS 2017-2018 survey download](https://fdc.nal.usda.gov/download-datasets/).
  Added sugar comes from [USDA FPED 2017-2018](https://www.ars.usda.gov/northeast-area/beltsville-md-bhnrc/beltsville-human-nutrition-research-center/food-surveys-research-group/docs/fped-databases/),
  joined by food code. FPED teaspoon equivalents were multiplied by 4.2 g per
  teaspoon, as defined in the [USDA FPED methodology](https://www.ars.usda.gov/ARSUserFiles/80400530/pdf/fped/FPED_1718.pdf).
  Values are scaled from per-100-g values to explicit scenario portions.
- USDA source file SHA-256 values: FNDDS ZIP
  `DE6EA4730A71C57421C2D32B13D67B132EB5F5DBB7B6DDF651C5D2B7D47753EC`;
  FPED XLS
  `FC4B0F65FF538A43CDF79CB8336E1B675D28599E4D3487EDC83E4F1254AA9225`.
  The builder is `scripts/build_nutrition_test_catalog.py`; it requires the
  downloaded files and temporary `xlrd` tool. The raw USDA files are not
  checked in.
- Five foods have observed retailer prices in
  `test/fixtures/nutrition_price_observations.csv`. The source URL and the
  package-to-scenario-portion calculation accompany each price. Prices were
  observed on 2026-09-27 and can differ by store, availability, or date.
  Ninety-five foods have no price and cannot enter budget ranking.
- `eligible=true` in this simulation means *included in the test catalog*.
  FNDDS food codes are not UPCs, and this flag does not establish WIC
  eligibility. `FDC...` is a test identifier derived from the USDA FDC ID.

Run from `Project3`:

```powershell
python scripts/review_nutrition_profiles.py --dart path/to/dart
```

The script checks source coverage, meal portions and nutrients, price provenance,
profile-specific energy/protein/sodium gates, swaps, and appropriate abstention.
The numeric gates are test criteria, not medical recommendations. The individual
requests are in `test/fixtures/nutrition_profiles/` and identify all assumed
targets as illustrative; the target URLs are intentionally test placeholders.

## Five test profiles

| Test profile | Top outcome | Review |
| --- | --- | --- |
| 1. Privacy shopper, no personal targets, congee in basket | Avocado, black beans, congee; 476 kcal, 16 g protein, 679 mg sodium. | Plausible savory combination with no history or personal target. Sodium remains material for one meal, and the engine cannot assess a full-day diet. |
| 2. Adult resistance training, chicken in basket | Avocado, chicken breast, whole-wheat pita; 748 kcal, 51 g protein, 948 mg sodium. | Meets the test's minimum 80% per-meal energy/protein gates. It is 152 kcal below the illustrative 900 kcal allocation and uses about 41% of a 2,300 mg daily sodium reference. The top options remain similar; further review is needed. |
| 3. Adult fat-loss goal, high-added-sugar cereal in basket | Swaps the cereal; avocado, black beans, quinoa; 607 kcal, 21 g protein, 544 mg sodium, 0 g estimated added sugar. | Fits the illustrative 600 kcal allocation closely and preserves protein. The swap is optional; it does not edit the basket. A single meal cannot establish a safe weight-loss plan. |
| 4. Budget shopper, black beans in basket | Carrots, black beans, brown rice; estimated $0.65, 491 kcal, 18 g protein, 664 mg sodium. Pita alternative: estimated $1.01. | The cheaper comparable meal ranked first and stays under the $1.50 test budget. The prices map retailer packages to generic USDA foods, so actual checkout cost and WIC acceptance are unverified. |
| 5. Pregnant person requesting fat-loss mode | No recommendation. | Appropriate abstention: no applicable, clinician-provided weight plan was supplied. Pregnancy-specific adequacy and food safety are not yet implemented for positive recommendations. |

The FDA's [sodium label guidance](https://www.fda.gov/food/nutrition-education-resources-materials/sodium-your-diet)
uses a 2,300 mg adult Daily Value. The test's one-meal sodium allocations are
engineering review gates, not a prescribed way to distribute sodium across
the day. The [NIH Body Weight Planner](https://www.niddk.nih.gov/health-information/weight-management/body-weight-planner)
excludes pregnant and breastfeeding people. For pregnancy and young children,
the [FDA fish guidance](https://www.fda.gov/food/consumers/advice-about-eating-fish)
also makes a simple nutrient-only ranking insufficient.

## Judgment and remaining work

The first unreviewed run failed qualitative review: it chose 100 g tamarind as
the produce portion, put seeds in the protein-anchor slot, and kept a
high-added-sugar cereal in a fat-loss meal. The current run removes those
failures through portion changes, suitability notes, food-style compatibility,
and an explicit swap. The five review gates now pass, but this is **not a
clinical validation**. Some choices spend a large fraction of the sodium
reference in one meal, and protein/energy allocation assumes three equally
sized meals. Pairing quality, allergies, household members, micronutrient
adequacy, pregnancy and child safety, and repeated-meal variety need further
work and qualified dietitian review. The catalog's older survey foods and
generic nutrient estimates must be replaced or cross-checked against current,
product-specific labels before live Firestore integration.
