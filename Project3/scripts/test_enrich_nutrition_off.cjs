// node --test scripts/test_enrich_nutrition_off.cjs
const test = require('node:test');
const assert = require('node:assert/strict');
const { toNutritionDoc, rejectReason, servingAmount } = require('./enrich_nutrition_off.cjs');

const apl = { upc: '016000224698', name: 'CHEERIOS', category: 'BREAKFAST CEREAL', categoryCode: '05' };

// Shapes taken from real Open Food Facts records (2026-10-17).
const cheerios = {
  code: '0016000224698',
  product_name: 'Cheerios',
  serving_size: '1 cup (39 g)',
  nutriments: {
    'energy-kcal_100g': 359, 'energy-kcal_serving': 140,
    sodium_100g: 0.487179, sodium_serving: 0.19,
    sugars_100g: 5.128, sugars_serving: 2,
    'added-sugars_serving': 1,
    fiber_100g: 10.256, fiber_serving: 4,
    proteins_serving: 5, fat_serving: 2.5,
  },
};

test('servingAmount reads the gram/ml amount', () => {
  assert.equal(servingAmount('1 cup (39 g)'), 39);
  assert.equal(servingAmount('8 OZA (240 ml)'), 240);
  assert.equal(servingAmount('28.999999999999996g'), 28.999999999999996);
  assert.equal(servingAmount('1 cup'), null);
});

test('a consistent record becomes a nutrition document', () => {
  const doc = toNutritionDoc(apl, cheerios, '2026-10-17');
  assert.equal(doc.upc, apl.upc);
  assert.equal(doc.categoryCode, '05');
  assert.equal(doc.servingBasis, 'per serving (1 cup (39 g))');
  const n = Object.fromEntries(doc.foodNutrients.map((f) => [f.name, f.amount]));
  assert.equal(n['Sodium, Na'], 190); // g -> mg
  assert.equal(n['Sugars, added'], 1);
  assert.equal(n['Fiber, total dietary'], 4);
  assert.equal(doc.source.provider, 'Open Food Facts');
  assert.equal(doc.source.license, 'ODbL-1.0');
});

test('missing nutrients are omitted, never zero', () => {
  const p = structuredClone(cheerios);
  delete p.nutriments['added-sugars_serving'];
  const doc = toNutritionDoc(apl, p, '2026-10-17');
  assert.ok(!doc.foodNutrients.some((f) => f.name === 'Sugars, added'));
});

test('per-serving values that disagree with per-100 g are rejected', () => {
  // Kroger Multi-Grain: 29 g serving listing 1010 mg sodium vs 420 mg/100 g.
  const p = {
    serving_size: '29 g (1 cup)',
    nutriments: { 'energy-kcal_100g': 375, 'energy-kcal_serving': 300, sodium_100g: 0.42, sodium_serving: 1.01 },
  };
  assert.match(rejectReason(apl, p), /disagrees/);
  assert.equal(toNutritionDoc(apl, { ...p, code: 'x' }, 'd'), null);
});

test('nutrients weighing more than the serving are rejected', () => {
  // Kroger Bran Flakes: 17.2 g sugar + 17.2 g fiber in a 29 g serving.
  const p = {
    serving_size: '28.999999999999996g',
    nutriments: { sugars_serving: 17.2, fiber_serving: 17.2, proteins_serving: 3, sodium_serving: 0.0006 },
  };
  assert.match(rejectReason(apl, p), /weigh more/);
});

test('implausibly low sodium for cheese is rejected', () => {
  const cheese = { ...apl, categoryCode: '02' };
  const p = { serving_size: '1 slice (19 g)', nutriments: { sodium_100g: 0.002, sodium_serving: 0.0004 } };
  assert.match(rejectReason(cheese, p), /cheese/);
});

test('records without energy or sodium per serving are not used', () => {
  const p = structuredClone(cheerios);
  delete p.nutriments.sodium_serving;
  delete p.nutriments.sodium_100g;
  assert.equal(toNutritionDoc(apl, p, 'd'), null);
});
