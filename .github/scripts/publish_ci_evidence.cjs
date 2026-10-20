// Called only by the branch-push reporting job; never uses a user token.
module.exports = async ({github, context, core, directory = 'ci-evidence'}) => {
  const fs = require('node:fs');
  const path = require('node:path');
  const {owner, repo} = context.repo;
  const source = context.ref.replace(/^refs\/heads\//, '');
  const report = JSON.parse(fs.readFileSync(path.join(directory, 'summary.json'), 'utf8'));
  if (report.commit !== context.sha || report.branch !== source) {
    throw new Error('Report identity does not match this workflow run');
  }
  const current = await github.rest.git.getRef({owner, repo, ref: `heads/${source}`});
  if (current.data.object.sha !== context.sha) {
    core.notice('A newer source commit exists; leaving the current badge report unchanged.');
    return;
  }
  let previous;
  try {
    previous = (await github.rest.git.getRef({owner, repo, ref: 'heads/ci-evidence'})).data.object.sha;
  } catch (error) {
    if (error.status !== 404) throw error;
  }
  if (previous) {
    try {
      const old = await github.rest.repos.getContent({owner, repo, ref: previous, path: `${source}/summary.json`});
      const prior = JSON.parse(Buffer.from(old.data.content, 'base64').toString('utf8'));
      if (prior.run_id > report.run_id || (prior.run_id === report.run_id && prior.attempt > report.attempt)) {
        core.notice('A newer run is already published.');
        return;
      }
    } catch (error) {
      if (error.status !== 404) throw error;
    }
  }
  // Replace this source branch's report directory as a whole so missing reports
  // cannot accidentally keep an old LCOV or test log. Preserve other branches.
  const files = fs.readdirSync(directory).sort();
  const blobs = [];
  for (const name of files) {
    const blob = await github.rest.git.createBlob({owner, repo, encoding: 'base64',
      content: fs.readFileSync(path.join(directory, name)).toString('base64')});
    blobs.push({path: name, mode: '100644', type: 'blob', sha: blob.data.sha});
  }
  const reportTree = await github.rest.git.createTree({owner, repo, tree: blobs});
  let baseTree;
  if (previous) baseTree = (await github.rest.git.getCommit({owner, repo, commit_sha: previous})).data.tree.sha;
  const tree = await github.rest.git.createTree({owner, repo, ...(baseTree ? {base_tree: baseTree} : {}),
    tree: [{path: source, mode: '040000', type: 'tree', sha: reportTree.data.sha}]});
  const commit = await github.rest.git.createCommit({owner, repo, tree: tree.data.sha,
    parents: previous ? [previous] : [], message: `CI evidence for ${source} at ${context.sha}`});
  if (previous) {
    await github.rest.git.updateRef({owner, repo, ref: 'heads/ci-evidence', sha: commit.data.sha, force: false});
  } else {
    await github.rest.git.createRef({owner, repo, ref: 'refs/heads/ci-evidence', sha: commit.data.sha});
  }
  core.notice(`Published evidence for ${source}: ${commit.data.sha}`);
};
