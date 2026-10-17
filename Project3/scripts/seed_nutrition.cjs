#!/usr/bin/env node
// Seeds nutrition/{upc} from scripts/enrich_nutrition_off.cjs output.
//
//   npx firebase-tools login                                  (once)
//   node scripts/seed_nutrition.cjs --input nutrition.json             (dry run)
//   node scripts/seed_nutrition.cjs --input nutrition.json --write --confirm wolfbyte-proj1
//
// Never touches apl/ or users/. Only creates documents (precondition
// exists:false); an existing nutrition doc with different data stops the run.
// Each UPC must exist in apl/ and be eligible. Writes are read back and compared.
// Uses the firebase-tools login (like import.js), so no service-account key.
const fs = require('node:fs');
const path = require('node:path');
const { parseArgs, isDeepStrictEqual } = require('node:util');

const PROJECT = 'wolfbyte-proj1';
const DB = `projects/${PROJECT}/databases/(default)`;
const DOCS = `${DB}/documents`;

function encode(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    return Number.isInteger(value) ? { integerValue: String(value) } : { doubleValue: value };
  }
  if (Array.isArray(value)) return { arrayValue: { values: value.map(encode) } };
  return { mapValue: { fields: encodeFields(value) } };
}
const encodeFields = (o) => Object.fromEntries(Object.entries(o).map(([k, v]) => [k, encode(v)]));
function decode(v) {
  if ('stringValue' in v) return v.stringValue;
  if ('booleanValue' in v) return v.booleanValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('nullValue' in v) return null;
  if ('arrayValue' in v) return (v.arrayValue.values || []).map(decode);
  if ('mapValue' in v) return decodeFields(v.mapValue.fields || {});
  throw new Error(`Unsupported Firestore value ${Object.keys(v)}`);
}
const decodeFields = (f) => Object.fromEntries(Object.entries(f).map(([k, v]) => [k, decode(v)]));

/** Throws unless [docs] is a well-formed nutrition document list. */
function validate(docs) {
  if (!Array.isArray(docs) || docs.length === 0) throw new Error('Input must be a non-empty array');
  const ids = new Set();
  for (const d of docs) {
    if (typeof d.upc !== 'string' || !/^\d{5,14}$/.test(d.upc) || ids.has(d.upc)) {
      throw new Error(`Invalid or repeated UPC: ${d.upc}`);
    }
    ids.add(d.upc);
    if (!d.name || !d.category || typeof d.servingBasis !== 'string') throw new Error(`Incomplete ${d.upc}`);
    if (!Array.isArray(d.foodNutrients) || d.foodNutrients.length === 0) throw new Error(`No nutrients ${d.upc}`);
    for (const n of d.foodNutrients) {
      if (typeof n.name !== 'string' || typeof n.amount !== 'number' || !Number.isFinite(n.amount) || n.amount < 0) {
        throw new Error(`Bad nutrient in ${d.upc}`);
      }
    }
    if (!d.source?.provider || !d.source?.url) throw new Error(`No source for ${d.upc}`);
  }
}

async function connect(cliRoot) {
  const root = cliRoot ? path.resolve(cliRoot) : path.dirname(require.resolve('firebase-tools/package.json'));
  const auth = require(path.join(root, 'lib/auth'));
  const { requireAuth } = require(path.join(root, 'lib/requireAuth'));
  const { Client } = require(path.join(root, 'lib/apiv2'));
  const options = { project: PROJECT, nonInteractive: true };
  const account = auth.getGlobalDefaultAccount();
  if (!account) throw new Error('Run `npx firebase-tools login` first');
  auth.setActiveAccount(options, account);
  await requireAuth(options);
  return new Client({ urlPrefix: 'https://firestore.googleapis.com', apiVersion: 'v1', auth: true });
}

async function batchGet(client, names) {
  const out = new Map();
  for (let i = 0; i < names.length; i += 100) {
    const r = await client.post(`${DB}/documents:batchGet`, { documents: names.slice(i, i + 100) });
    for (const x of r.body) {
      if (x.found) out.set(x.found.name, decodeFields(x.found.fields || {}));
    }
  }
  return out;
}

async function main() {
  const { values } = parseArgs({
    options: {
      input: { type: 'string' },
      write: { type: 'boolean', default: false },
      confirm: { type: 'string' },
      'cli-root': { type: 'string' },
    },
  });
  if (!values.input) throw new Error('Specify --input nutrition.json');
  if (values.write && values.confirm !== PROJECT) throw new Error(`--write requires --confirm ${PROJECT}`);
  const docs = JSON.parse(fs.readFileSync(values.input, 'utf8'));
  validate(docs);

  const client = await connect(values['cli-root']);
  const apl = await batchGet(client, docs.map((d) => `${DOCS}/apl/${d.upc}`));
  const existing = await batchGet(client, docs.map((d) => `${DOCS}/nutrition/${d.upc}`));

  const creates = [], unchanged = [], notEligible = [], conflicts = [];
  for (const d of docs) {
    const a = apl.get(`${DOCS}/apl/${d.upc}`);
    if (!a || a.eligible !== true) { notEligible.push(d.upc); continue; }
    const old = existing.get(`${DOCS}/nutrition/${d.upc}`);
    if (!old) creates.push(d);
    else if (isDeepStrictEqual(old, d)) unchanged.push(d.upc);
    else conflicts.push(d.upc);
  }
  console.log(JSON.stringify({
    project: PROJECT, input: docs.length, create: creates.length, unchanged: unchanged.length,
    skippedNotEligible: notEligible, conflicts,
  }, null, 1));
  if (conflicts.length) throw new Error('Existing nutrition docs differ; refusing to overwrite');
  if (!values.write) { console.log('Dry run: nothing written.'); return; }

  for (let i = 0; i < creates.length; i += 200) {
    const writes = creates.slice(i, i + 200).map((d) => ({
      update: { name: `${DOCS}/nutrition/${d.upc}`, fields: encodeFields(d) },
      currentDocument: { exists: false },
    }));
    const r = await client.post(`${DOCS}:commit`, { writes });
    if (r.body.writeResults?.length !== writes.length) throw new Error('Commit acknowledgement mismatch');
  }
  const after = await batchGet(client, creates.map((d) => `${DOCS}/nutrition/${d.upc}`));
  const bad = creates.filter((d) => !isDeepStrictEqual(after.get(`${DOCS}/nutrition/${d.upc}`), d));
  if (bad.length) throw new Error(`Read-back mismatch: ${bad.map((d) => d.upc).join(', ')}`);
  console.log(`Created and verified ${creates.length} nutrition documents.`);
}

if (require.main === module) {
  main().then(() => process.exit(0)).catch((e) => { console.error(e.message); process.exit(1); });
}

module.exports = { validate, encode, decode };
