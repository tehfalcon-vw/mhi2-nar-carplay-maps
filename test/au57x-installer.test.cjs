const test = require('node:test');
const assert = require('node:assert/strict');
const { mkdtempSync, mkdirSync, writeFileSync, readFileSync, statSync } = require('node:fs');
const { tmpdir } = require('node:os');
const { join, resolve } = require('node:path');
const { spawnSync } = require('node:child_process');
const { createHash } = require('node:crypto');

const installer = resolve(__dirname, '..', 'ports', 'au57x', 'installer.sh');

function put(path, data, bytes) {
  mkdirSync(resolve(path, '..'), { recursive: true });
  const body = Buffer.isBuffer(data) ? data : Buffer.from(data);
  assert.ok(body.length <= bytes, `${path} fixture seed exceeds ${bytes}`);
  writeFileSync(path, Buffer.concat([body, Buffer.alloc(bytes - body.length, 0x20)]));
}
function hash(path) {
  return createHash('sha256').update(readFileSync(path)).digest('hex');
}
function fixture() {
  const root = mkdtempSync(join(tmpdir(), 'mhi2-au57x-'));
  const app = join(root, 'app');
  const sys = join(root, 'system');
  const ifs = join(root, 'ifs');
  const payload = join(root, 'payload');
  mkdirSync(ifs, { recursive: true });
  put(join(app, 'eso/hmi/version.properties'), 'HMI_Version:HMI_AU_MIB2_H_NAR_G11_C6_184700\n', 128);
  put(join(app, 'armle/lib/dll/ipod-drvr-iap2.so'), Buffer.alloc(0), 739925);
  put(join(app, 'armle/usr/sbin/mm-ipod'), Buffer.alloc(0), 40297);
  put(join(app, 'eso/hmi/lsd/lsd.sh'), '#!/bin/sh\non -p 12 /ifs/jre/bin/j9 "$@"\n', 4125);
  put(join(app, 'eso/hmi/lsd/bundles.properties'), 'Bundle.Startup.Autostart=Factory\nFactory=example.Factory\n', 256);
  put(join(sys, 'etc/usblauncher_otg.lua'), 'function launch()\n  return "mm-ipod -d iap2,config=/etc/mm/iap2.cfg,test=1"\nend\n', 19907);
  put(join(sys, 'etc/mm/iap2.cfg'), '[iap2]\nname=test\n', 5853);
  put(join(sys, 'etc/eso/production/smartphone_integrator.json'), '{\n  "carplay": {\n    "envs": [\n      "BASE=1"\n    ]\n  }\n}\n', 6788);
  for (const name of [
    'libmhi2-nar-au57x-altscreen.so', 'libmhi2-nar-au57x-rgi-ipod.so',
    'mhi2-nar-au57x-rgi.jar', 'vc_render', 'mib2high-lvds-control.sh',
    'mib2high-lvds-profile.conf', 'mib2high-lvds-viewareas.conf'
  ]) put(join(payload, name), `fixture:${name}\n`, 64);
  put(join(payload, 'mm-ipod-au57x-rgi.sh'), '#!/bin/sh\nexec /mnt/app/armle/usr/sbin/mm-ipod "$@"\n', 96);
  return { root, app, sys, ifs, payload };
}
function run(f, command, extra = {}) {
  return spawnSync('sh', [installer, command, f.payload], {
    encoding: 'utf8',
    env: { ...process.env, AU57_APP: f.app, AU57_SYS: f.sys, AU57_IFS: f.ifs, AU57_TMP: f.root, ...extra }
  });
}

test('AU57x installer installs, rolls back, rejects drift and auto-restores', {
  skip: process.platform === 'win32' && process.env.AU57_FORCE_SHELL_TEST !== '1'
    ? 'full shell simulation runs in Linux CI'
    : false
}, () => {
  const f = fixture();
  const originals = [
    join(f.app, 'eso/hmi/lsd/lsd.sh'),
    join(f.sys, 'etc/usblauncher_otg.lua'),
    join(f.sys, 'etc/mm/iap2.cfg'),
    join(f.sys, 'etc/eso/production/smartphone_integrator.json')
  ];
  const before = new Map(originals.map(p => [p, hash(p)]));

  let r = run(f, 'install');
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /VERSION_GATE=PASS/);
  assert.match(r.stdout, /INSTALL=PASS/);
  assert.match(readFileSync(originals[0], 'utf8'), /mhi2-nar-au57x begin/);
  assert.match(readFileSync(originals[1], 'utf8'), /mm-ipod-au57x-rgi/);
  assert.match(readFileSync(originals[2], 'utf8'), /recvmsgs=0x5201/);
  assert.match(readFileSync(originals[3], 'utf8'), /libmhi2-nar-au57x-altscreen/);
  if (process.platform !== 'win32') {
    assert.equal(statSync(join(f.app, 'root/hooks/libmhi2-nar-au57x-altscreen.so')).mode & 0o777, 0o755);
  }

  r = run(f, 'rollback');
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /ROLLBACK=PASS/);
  for (const [p, expected] of before) assert.equal(hash(p), expected, `rollback drift: ${p}`);

  put(join(f.app, 'eso/hmi/version.properties'), 'HMI_Version:WRONG\n', 128);
  r = run(f, 'install');
  assert.notEqual(r.status, 0);
  assert.match(r.stdout, /VERSION_GATE HMI mismatch/);
  for (const [p, expected] of before) assert.equal(hash(p), expected, `gate mutated: ${p}`);

  put(join(f.app, 'eso/hmi/version.properties'), 'HMI_Version:HMI_AU_MIB2_H_NAR_G11_C6_184700\n', 128);
  r = run(f, 'install', { AU57_FAIL_AFTER: 'writes' });
  assert.notEqual(r.status, 0);
  assert.match(r.stdout, /AUTO_ROLLBACK=PASS/);
  for (const [p, expected] of before) assert.equal(hash(p), expected, `auto-rollback drift: ${p}`);
});
