'use strict';

const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const { parseArgs, verifyProfile } = require('../tools/verify-target.cjs');

function digest(value) {
  return crypto.createHash('sha256').update(value).digest('hex');
}

test('profile verification passes exact bytes and rejects drift', (context) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'mhi2-target-'));
  context.after(() => fs.rmSync(root, { recursive: true, force: true }));
  fs.mkdirSync(path.join(root, 'armle', 'lib'), { recursive: true });
  fs.writeFileSync(path.join(root, 'armle', 'lib', 'component.so'), 'known');
  const profile = {
    schemaVersion: 1,
    id: 'fixture',
    train: 'MHI2_US_FIXTURE',
    appFiles: [{ path: 'armle/lib/component.so', bytes: 5, sha256: digest('known') }],
  };
  const pass = verifyProfile(profile, root, null);
  assert.equal(pass.evidence, 'HOST_STATIC_MATCH');
  assert.equal(pass.vehicleTested, false);

  fs.writeFileSync(path.join(root, 'armle', 'lib', 'component.so'), 'other');
  const fail = verifyProfile(profile, root, null);
  assert.equal(fail.evidence, 'REJECTED');
  assert.equal(fail.checks[0].status, 'HASH_MISMATCH');
});

test('profile paths cannot escape the extracted root', () => {
  assert.throws(() => verifyProfile({
    schemaVersion: 1,
    id: 'bad',
    train: 'bad',
    appFiles: [{ path: '../outside', bytes: 1, sha256: digest('x') }],
  }, process.cwd(), null), /unsafe profile path/);
});

test('CLI parser requires a paired LSD option', () => {
  assert.deepEqual(parseArgs(['profile.json', 'tree']), {
    profile: 'profile.json', appRoot: 'tree', lsd: null,
  });
  assert.throws(() => parseArgs(['profile.json', 'tree', '--bad', 'x']), /unknown option/);
});
