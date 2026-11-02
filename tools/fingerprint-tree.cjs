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

function inventory(root) {
  const absoluteRoot = fs.realpathSync(root);
  const files = [];

  function walk(directory) {
    const entries = fs.readdirSync(directory, { withFileTypes: true })
      .sort((left, right) => left.name.localeCompare(right.name, 'en'));
    for (const entry of entries) {
      const absolute = path.join(directory, entry.name);
      const relative = path.relative(absoluteRoot, absolute).split(path.sep).join('/');
      if (entry.isSymbolicLink()) throw new Error(`symbolic links are not accepted: ${relative}`);
      if (entry.isDirectory()) walk(absolute);
      else if (entry.isFile()) {
        const stat = fs.statSync(absolute);
        files.push({ path: relative, bytes: stat.size, sha256: sha256(absolute) });
      } else throw new Error(`unsupported filesystem entry: ${relative}`);
    }
  }

  walk(absoluteRoot);
  return { schemaVersion: 1, files };
}

function main(args) {
  if (args.length !== 2) {
    throw new Error('usage: node tools/fingerprint-tree.cjs <extracted-firmware-dir> <output.json>');
  }
  const root = path.resolve(args[0]);
  const output = path.resolve(args[1]);
  if (!fs.statSync(root).isDirectory()) throw new Error('firmware input is not a directory');
  if (fs.existsSync(output)) throw new Error(`refusing to overwrite ${output}`);
  const manifest = inventory(root);
  fs.writeFileSync(output, `${JSON.stringify(manifest, null, 2)}\n`, { flag: 'wx' });
  process.stdout.write(`fingerprinted ${manifest.files.length} files\n`);
}

if (require.main === module) {
  try { main(process.argv.slice(2)); }
  catch (error) { process.stderr.write(`${error.message}\n`); process.exitCode = 1; }
}

module.exports = { inventory };
