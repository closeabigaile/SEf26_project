const test = require('node:test');
const assert = require('node:assert/strict');
const { BASE, encode, decode, encodeFields, validateCatalog, makePlan, writesFor, commitWrites } = require('./import');
const source = { sha256: 'a'.repeat(64), versionDate: '2026-09-02', row: 3 };
function catalog() {
  return { projectId: 'wolfbyte-proj1', collection: 'apl', schemaVersion: 2, source,
    summary: { readyDocuments: 1, reviewRows: 0, productRows: 1, readySourceRows: 1, includedFollowUpRows: 1 },
    documents: [{ documentId: '72036686541', fields: { upc: '72036686541', name: 'Mushrooms', category: 'FRUIT', state: 'NC', eligible: true, source,
      dataQuality: { status: 'included_as_supplied_pending_verification', issues: ['barcode_length_needs_review'] } } }],
  };
}
test('REST encoding preserves identifiers, arrays, quality flags and source rows', () => {
  const fields = { code: '001234', values: [null, false, 3, 1.5, { code: '01568707' }], empty: [], sourceRecords: [{ source }] };
  assert.deepEqual(decode(encode(fields)), fields);
});
test('validated exceptions retain their original identifiers', () => {
  assert.deepEqual(validateCatalog(catalog()), { documents: 1, sourceRows: 1, followups: 1 });
});
test('wrong project, repeated IDs and unaccounted source rows fail before writes', () => {
  const wrong = catalog(); wrong.projectId = 'other'; assert.throws(() => validateCatalog(wrong));
  const duplicate = catalog(); duplicate.documents.push(duplicate.documents[0]); duplicate.summary.readyDocuments++;
  assert.throws(() => validateCatalog(duplicate));
  const missing = catalog(); missing.summary.productRows++; assert.throws(() => validateCatalog(missing));
});
test('re-running skips matching documents and refuses to overwrite different data', () => {
  const c = catalog(); const fields = c.documents[0].fields;
  assert.equal(makePlan(c, [{ name: `${BASE}/apl/72036686541`, fields: encodeFields(fields) }], false).unchanged.length, 1);
  assert.throws(() => makePlan(c, [{ name: `${BASE}/apl/72036686541`, fields: encodeFields({ ...fields, name: 'Other' }) }], false));
});
test('writes protect new documents and only change demo eligibility/status', () => {
  const demo = { name: `${BASE}/apl/001`, updateTime: '2026-10-03T00:00:00Z', fields: encodeFields({ eligible: true, name: 'Demo' }) };
  const writes = writesFor(makePlan(catalog(), [demo], true));
  assert.deepEqual(writes[0].currentDocument, { exists: false });
  assert.deepEqual(writes[1].currentDocument, { updateTime: demo.updateTime });
  assert.deepEqual(writes[1].updateMask.fieldPaths, ['eligible', 'catalogStatus']);
  assert.equal(writes[1].update.fields.eligible.booleanValue, false);
  assert.equal(makePlan(catalog(), [demo], false).retirements.length, 0);
});
test('batches are awaited and a failure stops subsequent batches', async () => {
  let calls = 0, active = 0; const counts = [];
  const client = { post: async (_, body) => {
    assert.equal(active++, 0); calls++; await Promise.resolve(); active--;
    if (calls === 2) throw new Error('Simulated failure');
    return { body: { writeResults: body.writes.map(() => ({})) } };
  } };
  await assert.rejects(commitWrites(client, Array.from({ length: 401 }, () => ({})), n => counts.push(n)), /Simulated failure/);
  assert.equal(calls, 2); assert.deepEqual(counts, [200]);
});
