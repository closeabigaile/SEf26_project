const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const publish = require('./publish_ci_evidence.cjs');

function fixture(t, options = {}) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'wolfbite-publisher-'));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const report = {commit: 'current', branch: 'docs/ReadMe_Update', run_id: 10, attempt: 1};
  fs.writeFileSync(path.join(directory, 'summary.json'), JSON.stringify(report));
  const calls = [];
  const missing = () => { throw Object.assign(new Error('Not found'), {status: 404}); };
  const git = {
    getRef: async ({ref}) => ref === 'heads/ci-evidence'
      ? (options.existing ? {data: {object: {sha: 'previous'}}} : missing())
      : {data: {object: {sha: options.newerSource ? 'newer' : 'current'}}},
    getCommit: async () => ({data: {tree: {sha: 'old-tree'}}}),
    createBlob: async () => ({data: {sha: 'blob'}}),
    createTree: async args => { calls.push(['tree', args]); return {data: {sha: 'tree'}}; },
    createCommit: async args => { calls.push(['commit', args]); return {data: {sha: 'new-commit'}}; },
    createRef: async args => calls.push(['create-ref', args]),
    updateRef: async args => calls.push(['update-ref', args]),
  };
  const github = {rest: {git, repos: {getContent: async () => ({data: {content:
    Buffer.from(JSON.stringify({...report, run_id: options.newerReport ? 11 : 9})).toString('base64')}})}}};
  return {args: {directory, github, context: {repo: {owner: 'owner', repo: 'repo'},
    ref: 'refs/heads/docs/ReadMe_Update', sha: 'current'}, core: {notice() {}}}, calls};
}

test('first publication creates a separate evidence branch', async t => {
  const {args, calls} = fixture(t);
  await publish(args);
  assert.equal(calls.find(([kind]) => kind === 'create-ref')[1].ref, 'refs/heads/ci-evidence');
  assert.deepEqual(calls.find(([kind]) => kind === 'commit')[1].parents, []);
  assert.equal(calls.filter(([kind]) => kind === 'tree')[1][1].tree[0].path, 'docs/ReadMe_Update');
});

test('updates preserve the existing tree and never force-push', async t => {
  const {args, calls} = fixture(t, {existing: true});
  await publish(args);
  assert.equal(calls.filter(([kind]) => kind === 'tree')[1][1].base_tree, 'old-tree');
  assert.equal(calls.find(([kind]) => kind === 'update-ref')[1].force, false);
  assert.deepEqual(calls.find(([kind]) => kind === 'commit')[1].parents, ['previous']);
});

test('obsolete source commits do not publish', async t => {
  const {args, calls} = fixture(t, {newerSource: true});
  await publish(args);
  assert.deepEqual(calls, []);
});

test('older runs cannot replace newer reports', async t => {
  const {args, calls} = fixture(t, {existing: true, newerReport: true});
  await publish(args);
  assert.deepEqual(calls, []);
});

test('report identity must match the source branch and commit', async t => {
  const {args, calls} = fixture(t);
  args.context.sha = 'wrong';
  await assert.rejects(publish(args), /identity/);
  assert.deepEqual(calls, []);
});
