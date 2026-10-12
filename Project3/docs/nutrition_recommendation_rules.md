# Nutrition recommendation rules

Status: design specification and CSV-backed engine, 2026-09-27. The remaining
data and clinical-review gates below must be completed before this is shown as
personalized health guidance in the Flutter app.

## Scope and data boundaries

- A product is not a meal, a shopping basket is not a diet, and a purchase is
  not proof of consumption. Label each of these separately in the UI.
- A nutrition comparison requires the same measurement basis. Store the amount
  per serving, serving weight/volume, servings per package, and source. Convert
  to a common per-100-g or per-100-ml basis only when both products have a
  compatible measured quantity. Never treat an absent nutrient as zero.
- A price comparison requires a current price, package amount, and comparable
  units. Otherwise the money-saving mode abstains from price claims.
- WIC eligibility is jurisdiction- and benefit-specific. A catalog flag is
  insufficient to promise checkout acceptance. Preserve the existing benefit
  checks, and label mock catalog records as examples.
- Recommendations are optional suggestions. They must not diagnose disease,
  infer a person's blood cholesterol from purchases, or claim that a product
  treats a condition.

## Profiles and targets

The end-state profile records age/life stage, pregnancy or lactation status,
activity, household member, dietary restrictions, preferred mode, and whether
history use is enabled. Weight, height, and goals are collected only when a
target calculation needs them. The user can edit and delete profile/history.

Targets have a value, unit, population, method, source URL, creation date, and
review date. The target resolver uses this order:

1. A clinician-provided or user-entered target with its origin clearly shown.
2. A life-stage DRI target from the USDA/National Academies reference. The
   source supports age, pregnancy, and breastfeeding differences; an estimate
   is not an individualized prescription.
3. For nonpregnant, nonbreastfeeding adults only, an optional weight-goal plan
   from the NIH Body Weight Planner. Its own exclusions apply.
4. No numeric target when required inputs or an applicable reference are
   missing. Show general food comparisons in privacy mode instead.

Do not apply an adult calorie-deficit rule to children, pregnant people, or
breastfeeding people. The bodybuilding mode may use an adult resistance-training
protein target only when the person reports relevant training; otherwise use
their life-stage target. Any target that falls outside the applicable source
range needs review rather than silent acceptance.

Privacy mode stores no body measurements, goals, or purchase history. It makes
general, source-backed comparisons from the current basket and catalog only.

## Product and meal representation

Each catalog record needs UPC, name, food group, WIC category, eligibility
provenance, nutrient values with units and serving basis, package quantity,
price with date/store when available, and data source/version. A combination
requires explicit one-meal portions. A meal idea is assembled from complementary
groups (for example vegetable/fruit, protein, grain/starch); this is a food
group diversity heuristic, not a claim that three arbitrary products form a
complete diet. The UI must show portions and total nutrients for the proposed
meal, including any unavailable values.

Generate at most three choices from a bounded catalog. Prefer one addition or
one swap involving an item already in the basket. Do not silently change the
basket. Respect allergies, dietary restrictions, household member, WIC
eligibility, quantity, and budget before ranking. A candidate that fails a hard
constraint is excluded, not given a low score.

## Mode-specific ranking

All modes retain the baseline checks for missing data, serving comparability,
and excessive sodium, saturated fat, and added sugar. These are shopping
priorities, not disease treatment recommendations.

| Mode | Primary target and ranking | Required data | Abstain when |
| --- | --- | --- | --- |
| Balanced meals | Improve food-group variety and fit the relevant nutrient targets over the proposed meal portions. | Food groups, portions, nutrients, applicable targets. | Meal portions or key nutrient data are missing. |
| Bodybuilding | Fit the person's energy and training-related protein targets while maintaining meal variety. | Adult/training status or clinician target, energy, protein, portions. | The protein target is not applicable or available. |
| Fat loss | Fit a valid personal energy target while preserving protein, fibre, and food-group variety. | Applicable energy target, portions, energy, protein, fibre. | No applicable target exists, especially for children or pregnancy/lactation. |
| Money saving | Prefer lower cost per comparable serving while retaining nutritional adequacy and benefit constraints. | Current price, package/serving amount, nutrient data. | Price or comparable quantity is missing. |
| Privacy | General food-group and per-serving comparisons without profile or history. | Current basket and catalog. | The comparison basis is missing. |

Ranking must show the exact numeric comparison (for example, sodium per
serving, meal protein, or cost per serving), the target used, and the data
source. A user can reject a suggestion; it should not reappear unchanged in
the same session. Tie-break deterministically by UPC.

## History

On completed checkout, store a dated, user-scoped snapshot of the purchased
items, quantities, and nutrient-data provenance. Do not save an abandoned
basket as a purchase. Keep history separate from the current basket and make
deletion possible. Use history only with opt-in consent.

History may identify repeated *purchases* of products high in a measured
nutrient per comparable serving. It cannot estimate actual dietary intake,
cholesterol levels, or nutrient deficiency. A pattern message must state the
number of observed checkouts, time window, missing-data coverage, and a
concrete optional comparison. Avoid a pattern claim from one checkout or when
most relevant items have missing data. For cardiovascular messaging, prioritize
documented sodium and saturated-fat comparisons over a categorical claim that
all dietary cholesterol is harmful.

## Citation and provenance contract

Each health rationale has a stable claim ID, exact approved wording, population,
source title, URL, and review date in a versioned evidence registry. The engine
emits claim IDs, not free-form medical prose. The UI renders the wording and a
clickable source link next to every health rationale. A missing, inapplicable,
or expired source suppresses the rationale. Numeric product comparisons also
show the catalog/label data source separately. Budget comparisons cite price
data rather than health papers.

Initial evidence registry:

| Claim ID | Approved scope | Primary source |
| --- | --- | --- |
| `balanced_pattern` | Variety, adequacy, balance, moderation, and diversity in general diets. | [WHO healthy diet, 2026](https://www.who.int/news-room/fact-sheets/detail/healthy-diet) |
| `sodium` | Lower sodium intake supports healthier blood pressure; do not diagnose hypertension. | [WHO sodium guidance](https://www.who.int/tools/elena/interventions/sodium-cvd-adults) |
| `protein_training` | Adequate protein supports training adaptation in adults doing resistance exercise. | [NIH ODS exercise and athletic performance](https://ods.od.nih.gov/factsheets/ExerciseAndAthleticPerformance-HealthProfessional/) |
| `serving_basis` | Nutrition-label amounts are generally per serving, and packages may have multiple servings. | [FDA serving-size guidance](https://www.fda.gov/food/nutrition-facts-label/serving-size-nutrition-facts-label) |
| `cholesterol_context` | Dietary cholesterol advice is better framed in overall food patterns than a single universal product limit. | [AHA science advisory](https://pubmed.ncbi.nlm.nih.gov/31838890/) |
| `adult_weight_plan` | Personalized calorie/weight planning for adults only, excluding pregnancy and breastfeeding. | [NIH Body Weight Planner](https://www.niddk.nih.gov/health-information/weight-management/body-weight-planner) |
| `label_high` and `sodium_daily_value` | FDA 20% Daily Value threshold and 2,300 mg sodium Daily Value for people age four and older. | [FDA Daily Value guidance](https://www.fda.gov/food/nutrition-facts-label/lows-and-highs-percent-daily-value-nutrition-facts-label), [FDA sodium guidance](https://www.fda.gov/food/nutrition-education-resources-materials/sodium-your-diet) |
| `life_stage_targets` | Age and pregnancy/lactation-specific DRI estimates. | [USDA DRI Calculator](https://www.nal.usda.gov/human-nutrition-and-food-safety/dri-calculator) |

The registry supports guidance; it does not prove that a particular product is
eligible, healthy for a particular person, or accurately labeled. Product data
and personal targets need their own provenance.

## Verification sequence

1. Write a small synthetic CSV catalog with complete units, meal groups,
   portions, prices, and deliberately missing fields. Test parsing and
   validation before any Firestore read.
2. Test target applicability for adults, children, pregnancy, breastfeeding,
   unknown life stage, and privacy mode. Reject unsupported target requests.
3. Test combinations, quantity arithmetic, hard constraints, modes, missing
   data, history opt-in, and one-swap previews against the CSV fixtures.
4. Test that each health claim has a matching source and that unsupported
   claims are suppressed.
5. Add Firestore adapters for catalog and completed-checkout history. Run the
   same engine tests against fake Firestore, then an isolated real test project.
6. Review the wording and target rules with a qualified dietitian before
   presenting personalized recommendations as health guidance.

## Current implementation and use

Run the local example from `Project3`:

```powershell
dart scripts/nutrition_cli.dart --catalog test/fixtures/nutrition_catalog.csv --request test/fixtures/nutrition_request.json
```

The catalog and request in `test/fixtures` are synthetic examples, including
placeholder URLs. They are never suitable as real nutrition or target sources.
The command makes no Firebase calls. It returns meal ideas, per-serving totals,
product-data origins, target origin, and linked evidence for each rationale.
For a different mode, edit a copy of the request JSON. Supported mode values
are `balanced`, `bodybuilding`, `fatLoss`, `moneySaving`, and `privacy`.
Privacy needs no target or history. Other modes require a target source and a
matching life stage. Price comparisons require a dated price no older than 30
days. `excludedUpcs` can exclude a product identified as unsuitable for the
person, but this is not a replacement for complete allergy data.

The scoring coefficients in `nutrition_recommender.dart` are explicit
prototype ranking weights, not clinically validated thresholds. The engine
currently assembles produce, protein, and grain portions; bodybuilding mode
can enlarge the tested portions to approach an illustrative meal target.
It does not calculate target values, check actual WIC benefits, account for
every allergy or household member, or persist checkout history. Firestore's
current `apl` data also lacks the complete portions, nutrient provenance, and
current prices required here. These are required before app integration.

The expanded 100-food USDA evaluation and five labeled test profiles are
documented in [nutrition_profile_review.md](nutrition_profile_review.md).
