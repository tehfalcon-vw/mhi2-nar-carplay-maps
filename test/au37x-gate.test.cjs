const test = require('node:test');
const assert = require('node:assert/strict');
const { mkdtempSync, mkdirSync, openSync, writeSync, ftruncateSync, closeSync, writeFileSync } = require('node:fs');
const { tmpdir } = require('node:os');
const { join, resolve, dirname } = require('node:path');
const { spawnSync } = require('node:child_process');

const gate = resolve(__dirname, '..', 'ports', 'au37x', 'nar-target-gate.sh');
function sparse(path, size, seed = '') {
  mkdirSync(dirname(path), { recursive: true });
  const fd = openSync(path, 'w');
  if (seed) writeSync(fd, seed);
  ftruncateSync(fd, size);
  closeSync(fd);
}
function makeFixture() {
  const root = mkdtempSync(join(tmpdir(), 'mhi2-au37x-'));
  const app = join(root, 'app'), sys = join(root, 'system'), ifs = join(root, 'ifs');
  sparse(join(app, 'eso/hmi/version.properties'), 128, 'HMI_Version:HMI_AU_MIB2_H_NAR_G21_C10_181600\n');
  for (const [path, size] of [
    ['armle/lib/dll/ipod-drvr-iap2.so', 740261], ['armle/lib/libnvss_video.so', 73302],
    ['armle/usr/lib/libiap2client.so.1', 18613], ['armle/usr/sbin/mm-ipod', 40297],
    ['eso/bin/apps/dio_manager', 694554], ['eso/hmi/lsd/lsd.sh', 15056]
  ]) sparse(join(app, path), size);
  sparse(join(sys, 'etc/usblauncher_otg.lua'), 21614, 'return "storage,splash="\n');
  sparse(join(sys, 'etc/eso/production/smartphone_integrator.json'), 7397, '{}\n');
  sparse(join(sys, 'etc/mm/iap2.cfg'), 6016, 'model=DEV_MMX2_AU_NAR_G21_038PROD\n');
  sparse(join(ifs, 'lsd.jxe'), 60653999);
  return { root, app, sys, ifs };
}
function run(f) {
  return spawnSync('sh', [gate], { encoding: 'utf8', env: {
    ...process.env, AU37_APP: f.app, AU37_SYS: f.sys, AU37_IFS: f.ifs, AU37_CHECK_ONLY: '1'
  }});
}

test('AU37x exact target gate accepts the profile and rejects drift', {
  skip: process.platform === 'win32' && process.env.AU37_FORCE_SHELL_TEST !== '1'
    ? 'full shell gate runs in Linux CI' : false
}, () => {
  const f = makeFixture();
  let r = run(f);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /TARGET_GATE=PASS/);
  writeFileSync(join(f.app, 'eso/hmi/version.properties'), 'HMI_Version:WRONG\n');
  r = run(f);
  assert.notEqual(r.status, 0);
  assert.match(r.stdout, /HMI mismatch/);
});
