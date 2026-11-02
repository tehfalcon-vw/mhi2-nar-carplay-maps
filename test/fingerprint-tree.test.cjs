'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const { inventory } = require('../tools/fingerprint-tree.cjs');

test('inventory is stable, relative, and content-addressed', (context) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'mhi2-fingerprint-'));
  context.after(() => fs.rmSync(root, { recursive: true, force: true }));
  fs.mkdirSync(path.join(root, 'z'));
  fs.writeFileSync(path.join(root, 'z', 'second.bin'), Buffer.from([0, 1, 2]));
  fs.writeFileSync(path.join(root, 'first.txt'), 'MHI2\n');

  const result = inventory(root);
  assert.equal(result.schemaVersion, 1);
  assert.deepEqual(result.files.map((entry) => entry.path), ['first.txt', 'z/second.bin']);
  assert.equal(result.files[0].bytes, 5);
  assert.equal(result.files[0].sha256, crypto.createHash('sha256').update('MHI2\n').digest('hex'));
  assert.doesNotMatch(JSON.stringify(result), new RegExp(root.replaceAll('\\', '\\\\')));
});

test('inventory rejects symbolic links when the host permits them', (context) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'mhi2-symlink-'));
  context.after(() => fs.rmSync(root, { recursive: true, force: true }));
  fs.writeFileSync(path.join(root, 'target'), 'x');
  try { fs.symlinkSync(path.join(root, 'target'), path.join(root, 'link')); }
  catch { context.skip('host does not permit symbolic links'); return; }
  assert.throws(() => inventory(root), /symbolic links are not accepted/);
});
