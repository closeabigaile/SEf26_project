#!/usr/bin/env node
// Builds nutrition/{upc} documents for APL products from Open Food Facts.
//
//   node scripts/enrich_nutrition_off.cjs --input apl.json --output nutrition.json
//
// --input is a JSON array of APL documents ({upc, name, category, categoryCode}).
// Only per-serving values are used so every product shares one measurement
// basis; a nutrient missing from Open Food Facts is left out (unknown), never 0.
// Makes read-only HTTP requests to Open Food Facts; never contacts Firebase.
// Data: Open Food Facts, ODbL (https://world.openfoodfacts.org/data).
const fs = require('node:fs');
const { parseArgs } = require('node:util');

const USER_AGENT = 'WolfBite-SEf26/0.1 (NCSU SE course project)';
const DELAY_MS = 2500; // Open Food Facts rate-limits bursts (HTTP 429)
const RETRY_WAIT_MS = 65000;

// Open Food Facts key -> [app foodNutrients name, multiplier to app unit].
const NUTRIENTS = [
  ['energy-kcal_serving', 'Energy', 1],
  ['fat_serving', 'Total lipid (fat)', 1],
  ['saturated-fat_serving', 'Fatty acids, total saturated', 1],
  ['trans-fat_serving', 'Fatty acids, total trans', 1],
  ['sodium_serving', 'Sodium, Na', 1000], // g -> mg
  ['sugars_serving', 'Total Sugars', 1],
  ['added-sugars_serving', 'Sugars, added', 1],
  ['proteins_serving', 'Protein', 1],
  ['fiber_serving', 'Fiber, total dietary', 1],
];

const round = (x) => Math.round(x * 100) / 100;

/** Serving amount in g or ml from text like "1 cup (39 g)" or "240 ml". */
function servingAmount(text) {
  const matches = [...String(text).matchAll(/(\d+(?:\.\d+)?)\s*(g|ml)\b/gi)];
  if (!matches.length) return null;
  const amount = Number(matches[matches.length - 1][1]);
  return amount > 0 ? amount : null;
}

/**
 * Why a crowdsourced record is unusable, or null if it passes. Open Food
 * Facts has records whose per-serving values disagree with their per-100 g
 * values, weigh more than the serving, or carry unit errors.
 */
function rejectReason(apl, product) {
  const n = product.nutriments;
  const amount = servingAmount(product.serving_size);
  if (!amount) return 'no serving weight';
  for (const base of ['energy-kcal', 'fat', 'sodium', 'sugars', 'proteins', 'fiber']) {
    const per100 = n[`${base}_100g`];
    const serving = n[`${base}_serving`];
    if (typeof per100 !== 'number' || typeof serving !== 'number') continue;
    const expected = (per100 * amount) / 100;
    const scale = Math.max(Math.abs(expected), Math.abs(serving));
    if (scale > 0.01 && Math.abs(expected - serving) / scale > 0.15) {
      return `${base} per serving disagrees with per 100 g`;
    }
  }
  const grams = ['fat_serving', 'sugars_serving', 'proteins_serving', 'fiber_serving']
    .map((k) => (typeof n[k] === 'number' ? n[k] : 0))
    .reduce((a, b) => a + b, 0);
  if (grams > amount * 1.05) return 'nutrients weigh more than the serving';
  // Cheese always carries real sodium; a few mg per 100 g is a unit error.
  if (apl.categoryCode === '02' && typeof n.sodium_100g === 'number' && n.sodium_100g < 0.05) {
    return 'implausibly low sodium for cheese';
  }
  return null;
}

/** Maps one Open Food Facts product to a nutrition document, or null. */
function toNutritionDoc(apl, product, retrievedAt) {
  const n = product?.nutriments;
  if (!n || !product.serving_size) return null;
  if (rejectReason(apl, product)) return null;
  const foodNutrients = [];
  for (const [key, name, factor] of NUTRIENTS) {
    const v = n[key];
    if (typeof v === 'number' && Number.isFinite(v) && v >= 0) {
      foodNutrients.push({ name, amount: round(v * factor) });
    }
  }
  // Without energy and sodium per serving the record is not useful for M2.
  const names = new Set(foodNutrients.map((f) => f.name));
  if (!names.has('Energy') || !names.has('Sodium, Na')) return null;
  return {
    upc: apl.upc,
    name: apl.name,
    category: apl.category,
    categoryCode: apl.categoryCode ?? null,
    servingBasis: `per serving (${String(product.serving_size).trim()})`,
    foodNutrients,
    source: {
      provider: 'Open Food Facts',
      productName: product.product_name ?? null,
      url: `https://world.openfoodfacts.org/product/${product.code}`,
      license: 'ODbL-1.0',
      retrievedAt,
      dataQuality: 'crowdsourced; passed consistency checks',
    },
  };
}

async function fetchProduct(upc) {
  const url =
    `https://world.openfoodfacts.org/api/v2/product/${encodeURIComponent(upc)}.json` +
    '?fields=code,product_name,serving_size,nutriments';
  let response;
  for (let attempt = 0; ; attempt++) {
    response = await fetch(url, { headers: { 'User-Agent': USER_AGENT } });
    if (response.status !== 429 || attempt >= 3) break;
    await new Promise((r) => setTimeout(r, RETRY_WAIT_MS));
  }
  if (response.status === 404) return null;
  if (!response.ok) throw new Error(`HTTP ${response.status} for ${upc}`);
  const body = await response.json();
  return body.status === 1 ? body.product : null;
}

async function main() {
  const { values } = parseArgs({
    options: {
      input: { type: 'string' },
      output: { type: 'string' },
      cache: { type: 'string' },
      limit: { type: 'string' },
    },
  });
  if (!values.input || !values.output) {
    throw new Error('Usage: --input apl.json --output nutrition.json [--cache raw.json] [--limit N]');
  }
  const apl = JSON.parse(fs.readFileSync(values.input, 'utf8'));
  const cachePath = values.cache ?? `${values.output}.cache.json`;
  const cache = fs.existsSync(cachePath) ? JSON.parse(fs.readFileSync(cachePath, 'utf8')) : {};
  const items = values.limit ? apl.slice(0, Number(values.limit)) : apl;
  const retrievedAt = new Date().toISOString().slice(0, 10);

  const docs = [];
  let fetched = 0;
  for (const [i, item] of items.entries()) {
    if (!(item.upc in cache)) {
      try {
        cache[item.upc] = await fetchProduct(item.upc);
      } catch (error) {
        console.error(`skip ${item.upc}: ${error.message}`);
        continue;
      }
      fetched++;
      if (fetched % 25 === 0) fs.writeFileSync(cachePath, JSON.stringify(cache));
      await new Promise((r) => setTimeout(r, DELAY_MS));
    }
    const doc = toNutritionDoc(item, cache[item.upc], retrievedAt);
    if (doc) docs.push(doc);
    if ((i + 1) % 50 === 0) console.log(`${i + 1}/${items.length} checked, ${docs.length} usable`);
  }
  fs.writeFileSync(cachePath, JSON.stringify(cache));
  fs.writeFileSync(values.output, JSON.stringify(docs, null, 1));
  console.log(`${docs.length} nutrition documents from ${items.length} APL products -> ${values.output}`);
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
  });
}

module.exports = { toNutritionDoc, rejectReason, servingAmount };
