#!/usr/bin/env node
// Live client-read smoke test. Creates and deletes a temporary password account.
// Never prints/persists passwords or ID/refresh tokens, and sends no email.
const fs = require('node:fs');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const { parseArgs } = require('node:util');
async function main() {
  const { values } = parseArgs({ options: { catalog: { type: 'string' }, output: { type: 'string' } } });
  if (!values.catalog || !values.output) throw new Error('Specify --catalog and --output');
  const config = JSON.parse(fs.readFileSync('google-services.json', 'utf8'));
  if (config.project_info.project_id !== 'wolfbyte-proj1') throw new Error('Wrong Firebase project');
  const key = config.client[0].api_key[0].current_key;
  const catalog = JSON.parse(fs.readFileSync(values.catalog, 'utf8'));
  if (catalog.projectId !== 'wolfbyte-proj1') throw new Error('Wrong catalog');
  const desired = new Map(catalog.documents.map(r => [r.documentId, r.fields]));
  const origin = 'https://firestore.googleapis.com/v1/projects/wolfbyte-proj1/databases/(default)/documents';
  const authUrl = method => `https://identitytoolkit.googleapis.com/v1/accounts:${method}?key=${key}`;
  const result = { project: 'wolfbyte-proj1', startedAt: new Date().toISOString(), checks: [], temporaryAccountDeleted: false };
  let idToken, temporaryUid;
  const authCall = async (method, data) => {
    const response = await fetch(authUrl(method), { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) });
    const body = await response.json();
    if (!response.ok) throw new Error(`Firebase Auth ${method}: ${body.error?.message || response.status}`);
    return body;
  };
  try {
    const unsigned = await fetch(`${origin}/apl/039400011606`);
    assert.equal(unsigned.status, 403, 'Unauthenticated catalog reads should be denied');
    result.checks.push('Unauthenticated read denied');
    const signup = await authCall('signUp', { email: `apl-verification-${crypto.randomUUID()}@example.invalid`, password: crypto.randomBytes(32).toString('base64url'), returnSecureToken: true });
    idToken = signup.idToken; temporaryUid = signup.localId;
    const headers = { Authorization: `Bearer ${idToken}`, 'Content-Type': 'application/json' };
    for (const code of ['039400011606', '01568707', '015000006877', '037842037680', '72036686541', '003800000120']) {
      const response = await fetch(`${origin}/apl/${code}`, { headers });
      if (!response.ok) throw new Error(`Signed-in lookup ${code} failed: HTTP ${response.status}`);
      const doc = await response.json();
      assert.equal(doc.fields.upc.stringValue, code);
      assert.equal(doc.fields.name.stringValue, desired.get(code).name);
      result.checks.push(`Signed-in exact lookup passed: ${code}`);
    }
    const response = await fetch(`${origin}:runQuery`, { method: 'POST', headers, body: JSON.stringify({ structuredQuery: {
      from: [{ collectionId: 'apl' }], where: { compositeFilter: { op: 'AND', filters: [
        { fieldFilter: { field: { fieldPath: 'category' }, op: 'EQUAL', value: { stringValue: 'CHEESE' } } },
        { fieldFilter: { field: { fieldPath: 'eligible' }, op: 'EQUAL', value: { booleanValue: true } } },
      ] } }, limit: 3,
    } }) });
    if (!response.ok) throw new Error(`Signed-in substitute query failed: HTTP ${response.status}`);
    const found = (await response.json()).filter(r => r.document).map(r => r.document);
    assert.equal(found.length, 3);
    assert.ok(found.every(d => d.fields.eligible.booleanValue && !['001','002'].includes(d.name.split('/').pop())));
    result.checks.push('Signed-in app substitute query passed; returned real eligible products');
    result.passed = true;
  } finally {
    if (idToken) {
      let deleted = false;
      for (let attempt = 0; attempt < 3 && !deleted; attempt++) {
        try { await authCall('delete', { idToken }); deleted = true; }
        catch (error) { if (attempt === 2) result.cleanupError = error.message; }
      }
      result.temporaryAccountDeleted = deleted;
      if (!deleted) { result.temporaryAccountUidNeedingCleanup = temporaryUid; result.passed = false; }
    }
    result.finishedAt = new Date().toISOString();
    fs.writeFileSync(values.output, JSON.stringify(result, null, 2) + '\n', { mode: 0o600 });
    console.log(JSON.stringify(result, null, 2));
    if (idToken && !result.temporaryAccountDeleted) throw new Error('Temporary account cleanup requires attention');
  }
}
main().catch(e => { console.error(e.message); process.exitCode = 1; });
