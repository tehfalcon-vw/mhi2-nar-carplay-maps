const test = require('node:test');
const assert = require('node:assert/strict');
const { mkdtempSync, mkdirSync, openSync, writeSync, ftruncateSync, closeSync, writeFileSync } = require('node:fs');
const { tmpdir } = require('node:os');
const { join, resolve, dirname } = require('node:path');
const { spawnSync } = require('node:child_process');

const gate = resolve(__dirname, '..', 'ports', 'au62x', 'nar-target-gate.sh');
function sparse(path, size, seed = '') {
  mkdirSync(dirname(path), { recursive: true });
  const fd = openSync(path, 'w');
  if (seed) writeSync(fd, seed);
  ftruncateSync(fd, size);
  closeSync(fd);
}
function makeFixture() {
  const root = mkdtempSync(join(tmpdir(), 'mhi2-au62x-'));
  const app = join(root, 'app'), sys = join(root, 'system'), ifs = join(root, 'ifs');
  sparse(join(app, 'eso/hmi/version.properties'), 128, 'HMI_Version:HMI_AU_MIB2_H_NAR_G24_C10_200600\n');
  for (const [path, size] of [
    ['armle/lib/dll/ipod-drvr-iap2.so', 740261], ['armle/lib/libnvss_video.so', 73302],
    ['armle/usr/lib/libiap2client.so.1', 18613], ['armle/usr/sbin/mm-ipod', 40297],
    ['eso/bin/apps/dio_manager', 694717], ['eso/hmi/lsd/lsd.sh', 15056]
  ]) sparse(join(app, path), size);
  sparse(join(sys, 'etc/usblauncher_otg.lua'), 21614, 'return "storage,splash="\n');
  sparse(join(sys, 'etc/eso/production/smartphone_integrator.json'), 7397, '{}\n');
  sparse(join(sys, 'etc/mm/iap2.cfg'), 6018, 'model=CLU10_MMX2_AU_NAR_G24_004PROD\n');
  sparse(join(ifs, 'lsd.jxe'), 60679081);
  return { app, sys, ifs };
}
function run(f, extra = {}) {
  return spawnSync('sh', [gate], { encoding: 'utf8', env: {
    ...process.env, AU62_APP: f.app, AU62_SYS: f.sys, AU62_IFS: f.ifs,
    AU62_CHECK_ONLY: '1', ...extra
  }});
}

test('AU62x exact target gate accepts P5181, rejects drift and prohibits PDC', {
  skip: process.platform === 'win32' && process.env.AU62_FORCE_SHELL_TEST !== '1'
    ? 'full shell gate runs in Linux CI' : false
}, () => {
  const f = makeFixture();
  let r = run(f);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /TARGET_GATE=PASS/);
  r = run(f, { PDC: '1' });
  assert.notEqual(r.status, 0);
  assert.match(r.stdout, /PDC is not qualified/);
  writeFileSync(join(f.app, 'eso/hmi/version.properties'), 'HMI_Version:WRONG\n');
  r = run(f);
  assert.notEqual(r.status, 0);
  assert.match(r.stdout, /HMI mismatch/);
});
