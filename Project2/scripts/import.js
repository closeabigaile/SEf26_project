#!/usr/bin/env node
'use strict';
// Import the reviewed catalog using the existing Firebase CLI login. No key files.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { isDeepStrictEqual } = require('node:util');
const { parseArgs } = require('node:util');
const PROJECT = 'wolfbyte-proj1';
const BASE = `projects/${PROJECT}/databases/(default)/documents`;
const DEMO_IDS = new Set(['001', '002']);

function encode(value) {
  if (value === null) return { nullValue: null };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Number.isSafeInteger(value) ? { integerValue: String(value) } : { doubleValue: value };
  }
  if (Array.isArray(value)) return { arrayValue: { values: value.map(encode) } };
  if (value && typeof value === 'object') return { mapValue: { fields: encodeFields(value) } };
  throw new Error('Unsupported document value');
}
function encodeFields(fields) { return Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, encode(v)])); }
function decode(value) {
  if ('nullValue' in value) return null;
  if ('stringValue' in value) return value.stringValue;
  if ('booleanValue' in value) return value.booleanValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return value.doubleValue;
  if ('arrayValue' in value) return (value.arrayValue.values || []).map(decode);
  if ('mapValue' in value) return decodeFields(value.mapValue.fields || {});
  throw new Error('Unexpected value type in an overlapping document');
}
function decodeFields(fields) { return Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, decode(v)])); }
function validateCatalog(catalog) {
  if (catalog.projectId !== PROJECT || catalog.collection !== 'apl' || catalog.schemaVersion !== 2) throw new Error('Wrong project, collection or schema');
  if (!/^[a-f0-9]{64}$/.test(catalog.source?.sha256 || '') || !catalog.source.versionDate) throw new Error('Missing source provenance');
  if (!Array.isArray(catalog.documents) || catalog.documents.length === 0 || catalog.summary.readyDocuments !== catalog.documents.length) throw new Error('Document count mismatch');
  if (catalog.summary.reviewRows !== 0) throw new Error('Use the completed reviewed export with zero held rows');
  const ids = new Set(), rows = new Set();
  let followups = 0;
  for (const { documentId, fields } of catalog.documents) {
    if (typeof documentId !== 'string' || !/^\d{5,14}$/.test(documentId) || fields.upc !== documentId || ids.has(documentId)) throw new Error('Invalid, mismatched or repeated UPC');
    ids.add(documentId);
    if (!fields.name?.trim() || !fields.category?.trim() || fields.eligible !== true || fields.state !== 'NC') throw new Error(`Incomplete product ${documentId}`);
    if (fields.source.sha256 !== catalog.source.sha256) throw new Error('Mixed source versions');
    for (const sourceRecord of fields.sourceRecords || [fields]) {
      const row = sourceRecord.source.row;
      if (!Number.isInteger(row) || rows.has(row) || sourceRecord.source.sha256 !== catalog.source.sha256) throw new Error('Invalid/repeated source row');
      rows.add(row);
    }
    if (fields.dataQuality?.status === 'included_as_supplied_pending_verification') followups++;
    encodeFields(fields); // Validate values before any network writes.
  }
  if (rows.size !== catalog.summary.productRows || rows.size !== catalog.summary.readySourceRows || followups !== catalog.summary.includedFollowUpRows) throw new Error('Source-row or follow-up reconciliation failed');
  return { documents: ids.size, sourceRows: rows.size, followups };
}
function makePlan(catalog, existing, retireDemo) {
  const remote = new Map(existing.map(d => [d.name.slice(`${BASE}/apl/`.length), d]));
  const creates = [], retirements = [], conflicts = [], unchanged = [];
  for (const record of catalog.documents) {
    const old = remote.get(record.documentId);
    if (!old) creates.push(record);
    else if (isDeepStrictEqual(decodeFields(old.fields || {}), record.fields)) unchanged.push(record.documentId);
    else conflicts.push(record.documentId);
  }
  if (conflicts.length) throw new Error(`Refusing to overwrite ${conflicts.length} different existing APL documents: ${conflicts.slice(0, 10).join(', ')}`);
  if (retireDemo) {
    for (const id of DEMO_IDS) {
      const old = remote.get(id);
      if (old && old.fields?.eligible?.booleanValue === true) retirements.push(old);
    }
  }
  return { creates, retirements, unchanged };
}
async function connect(cliRoot, account) {
  const root = cliRoot ? path.resolve(cliRoot) : path.dirname(require.resolve('firebase-tools/package.json'));
  const auth = require(path.join(root, 'lib/auth'));
  const { requireAuth } = require(path.join(root, 'lib/requireAuth'));
  const { Client } = require(path.join(root, 'lib/apiv2'));
  const options = { project: PROJECT, nonInteractive: true };
  const selected = auth.selectAccount(account, process.cwd());
  if (!selected) throw new Error('Run firebase login first');
  auth.setActiveAccount(options, selected);
  await requireAuth(options);
  return new Client({ urlPrefix: 'https://firestore.googleapis.com', apiVersion: 'v1', auth: true });
}
async function listApl(client) {
  const documents = []; let pageToken;
  do {
    const response = await client.get(`${BASE}/apl`, {
      queryParams: { pageSize: 1000, ...(pageToken ? { pageToken } : {}) }, skipLog: { resBody: true },
    });
    documents.push(...(response.body.documents || []));
    pageToken = response.body.nextPageToken;
  } while (pageToken);
  return documents;
}
function writesFor(plan) {
  return [
    ...plan.creates.map(r => ({ update: { name: `${BASE}/apl/${r.documentId}`, fields: encodeFields(r.fields) }, currentDocument: { exists: false } })),
    ...plan.retirements.map(old => ({
      update: { name: old.name, fields: encodeFields({ eligible: false, catalogStatus: 'retired_demo' }) },
      updateMask: { fieldPaths: ['eligible', 'catalogStatus'] }, currentDocument: { updateTime: old.updateTime },
    })),
  ];
}
async function commitWrites(client, writes, onProgress) {
  // Deliberately stop on an error, including an ambiguous timeout. Re-running
  // rebuilds the plan from Firestore and skips already matching documents.
  for (let offset = 0; offset < writes.length; offset += 200) {
    const batch = writes.slice(offset, offset + 200);
    const response = await client.post(`${BASE}:commit`, { writes: batch }, { skipLog: { body: true, resBody: true } });
    if (response.body.writeResults?.length !== batch.length) throw new Error('Commit acknowledgement count mismatch');
    onProgress(offset + batch.length);
  }
}
async function main() {
  const { values } = parseArgs({ options: {
    file: { type: 'string' }, output: { type: 'string' }, project: { type: 'string' },
    'firebase-tools': { type: 'string' }, account: { type: 'string' },
    write: { type: 'boolean', default: false }, 'retire-demo': { type: 'boolean', default: false },
    'validate-only': { type: 'boolean', default: false },
  } });
  if (values.project !== PROJECT || !values.file) throw new Error('Specify --project wolfbyte-proj1 --file PATH');
  const raw = fs.readFileSync(values.file);
  const catalog = JSON.parse(raw);
  const validation = validateCatalog(catalog);
  const inputSha256 = crypto.createHash('sha256').update(raw).digest('hex');
  console.log(JSON.stringify({ project: PROJECT, collection: 'apl', ...validation, inputSha256 }));
  if (values['validate-only']) { if (values.write) throw new Error('Cannot combine --write with --validate-only'); return; }
  if (!values.output || fs.existsSync(values.output)) throw new Error('Supply a new --output directory for backup and results');
  const client = await connect(values['firebase-tools'], values.account);
  const existing = await listApl(client);
  if (existing.some(d => !d.name.startsWith(`${BASE}/apl/`))) throw new Error('Unexpected snapshot path');
  const plan = makePlan(catalog, existing, values['retire-demo']);
  const report = { project: PROJECT, collection: 'apl', source: catalog.source, inputSha256,
    capturedAt: new Date().toISOString(), mode: values.write ? 'write' : 'preview', existingDocuments: existing.length,
    create: plan.creates.length, unchanged: plan.unchanged.length,
    retireDemo: plan.retirements.map(d => d.name.split('/').pop()),
    validation, complete: false,
  };
  fs.mkdirSync(values.output, { recursive: true, mode: 0o700 });
  const save = (name, data) => fs.writeFileSync(path.join(values.output, name), JSON.stringify(data, null, 2) + '\n', { mode: 0o600 });
  save('before.json', { project: PROJECT, collection: 'apl', capturedAt: report.capturedAt, documents: existing });
  save('plan.json', report);
  console.log(JSON.stringify(report, null, 2));
  if (!values.write) return;
  const writes = writesFor(plan);
  save('write-targets.json', { inputSha256, createdDocumentIds: plan.creates.map(r => r.documentId), retiredDemoIds: report.retireDemo });
  await commitWrites(client, writes, count => {
    report.acknowledgedWrites = count;
    save('progress.json', report);
    if (count % 2000 === 0 || count === writes.length) console.log(`Committed ${count}/${writes.length} writes`);
  });
  const after = await listApl(client);
  const verification = makePlan(catalog, after, values['retire-demo']);
  if (verification.creates.length || verification.retirements.length || verification.unchanged.length !== validation.documents) throw new Error('Post-import verification failed');
  report.complete = true;
  report.verifiedCatalogDocuments = verification.unchanged.length;
  report.totalAplDocuments = after.length;
  report.finishedAt = new Date().toISOString();
  save('result.json', report);
  console.log(JSON.stringify(report, null, 2));
}
if (require.main === module) main().catch(error => { console.error(error.message); process.exitCode = 1; });
module.exports = { PROJECT, BASE, encode, encodeFields, decode, decodeFields, validateCatalog, makePlan, writesFor, commitWrites };
