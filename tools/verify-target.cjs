#!/usr/bin/env node
'use strict';

const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');

function sha256(file) {
  const hash = crypto.createHash('sha256');
  const descriptor = fs.openSync(file, 'r');
  const buffer = Buffer.allocUnsafe(1024 * 1024);
  try {
    for (;;) {
      const bytes = fs.readSync(descriptor, buffer, 0, buffer.length, null);
      if (!bytes) break;
      hash.update(buffer.subarray(0, bytes));
    }
  } finally {
    fs.closeSync(descriptor);
  }
  return hash.digest('hex');
}

function verifyFile(root, expected) {
  const segments = expected.path.split('/');
  if (segments.some((segment) => segment === '..' || segment === '')) {
    throw new Error(`unsafe profile path: ${expected.path}`);
  }
  const file = path.join(root, ...segments);
  if (!fs.existsSync(file)) return { path: expected.path, status: 'MISSING' };
  const stat = fs.statSync(file);
  if (!stat.isFile()) return { path: expected.path, status: 'NOT_FILE' };
  if (stat.size !== expected.bytes) {
    return { path: expected.path, status: 'SIZE_MISMATCH', expected: expected.bytes, actual: stat.size };
  }
  const actualHash = sha256(file);
  if (actualHash !== expected.sha256) {
    return { path: expected.path, status: 'HASH_MISMATCH', expected: expected.sha256, actual: actualHash };
  }
  return { path: expected.path, status: 'PASS', bytes: stat.size, sha256: actualHash };
}

function verifyProfile(profile, appRoot, lsdFile) {
  if (profile.schemaVersion !== 1 || !Array.isArray(profile.appFiles)) {
    throw new Error('unsupported or malformed target profile');
  }
  const checks = profile.appFiles.map((entry) => verifyFile(appRoot, entry));
  if (profile.lsd) {
    if (!lsdFile) checks.push({ path: 'lsd.jxe', status: 'NOT_CHECKED' });
    else checks.push(verifyFile(path.dirname(lsdFile), { ...profile.lsd, path: path.basename(lsdFile) }));
  }
  const failures = checks.filter((check) => !['PASS', 'NOT_CHECKED'].includes(check.status));
  return {
    schemaVersion: 1,
    profile: profile.id,
    train: profile.train,
    evidence: failures.length ? 'REJECTED' : 'HOST_STATIC_MATCH',
    vehicleTested: false,
    checks,
  };
}

function parseArgs(args) {
  if (args.length < 2 || args.length > 4) {
    throw new Error('usage: node tools/verify-target.cjs <profile.json> <extracted-app-root> [--lsd <lsd.jxe>]');
  }
  const parsed = { profile: args[0], appRoot: args[1], lsd: null };
  if (args.length === 4) {
    if (args[2] !== '--lsd') throw new Error(`unknown option: ${args[2]}`);
    parsed.lsd = args[3];
  }
  return parsed;
}

function main(args) {
  const parsed = parseArgs(args);
  const profile = JSON.parse(fs.readFileSync(parsed.profile, 'utf8'));
  const result = verifyProfile(profile, parsed.appRoot, parsed.lsd);
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  if (result.evidence !== 'HOST_STATIC_MATCH') process.exitCode = 2;
}

if (require.main === module) {
  try { main(process.argv.slice(2)); }
  catch (error) { process.stderr.write(`${error.message}\n`); process.exitCode = 1; }
}

module.exports = { parseArgs, sha256, verifyFile, verifyProfile };
