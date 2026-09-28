const fs = require('fs');
const path = require('path');
const { isDeepStrictEqual } = require('util');
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const args = process.argv.slice(2);
const option = (name) => {
  const index = args.indexOf(name);
  return index < 0 ? null : args[index + 1];
};
const projectId = option('--project');
const inputPath = option('--input') || path.join(__dirname, 'm2_smoke.json');
const write = args.includes('--write');

async function main() {
  if (!projectId) throw new Error('Pass --project <Firebase project ID>.');

  const products = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
  if (!Array.isArray(products) || products.length === 0) {
    throw new Error('Input must be a non-empty JSON array.');
  }

  const ids = new Set();
  for (const product of products) {
    if (!product || typeof product.upc !== 'string' || !/^[A-Za-z0-9_-]+$/.test(product.upc) ||
        typeof product.name !== 'string' || !product.name.trim() ||
        typeof product.category !== 'string' || !product.category.trim() ||
        typeof product.eligible !== 'boolean' ||
        !Array.isArray(product.foodNutrients)) {
      throw new Error('Each product needs upc, name, category, eligible, and foodNutrients.');
    }
    if (ids.has(product.upc)) throw new Error(`Duplicate UPC: ${product.upc}`);
    ids.add(product.upc);
    for (const nutrient of product.foodNutrients) {
      if (typeof nutrient.name !== 'string' ||
          typeof nutrient.amount !== 'number' || !Number.isFinite(nutrient.amount)) {
        throw new Error(`Invalid foodNutrients entry for ${product.upc}.`);
      }
    }
  }

  console.log(`${write ? 'Writing' : 'Dry run:'} ${products.length} product(s) to ${projectId}/apl`);
  if (!write) return;

  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (!keyPath) throw new Error('Set GOOGLE_APPLICATION_CREDENTIALS to the service-account JSON path.');
  const keyProject = JSON.parse(fs.readFileSync(keyPath, 'utf8')).project_id;
  if (keyProject !== projectId) throw new Error('Service-account project does not match --project.');

  initializeApp({ credential: applicationDefault(), projectId });
  const db = getFirestore();
  for (const product of products) {
    const ref = db.collection('apl').doc(product.upc);
    const existing = await ref.get();
    if (existing.exists) {
      if (!isDeepStrictEqual(existing.data(), product)) {
        throw new Error(`apl/${product.upc} already exists with different data; refusing to overwrite.`);
      }
      console.log(`Already matches: apl/${product.upc}`);
      continue;
    }

    await ref.create(product);
    const saved = await ref.get();
    if (!saved.exists || !isDeepStrictEqual(saved.data(), product)) {
      throw new Error(`Read-back verification failed for apl/${product.upc}.`);
    }
    console.log(`Created and verified: apl/${product.upc}`);
  }
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
