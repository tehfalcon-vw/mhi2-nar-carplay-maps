const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const cp = require('node:child_process');

const install = path.resolve(__dirname, '..', 'ports', 'vwg13', 'installer.sh');
const uninstall = path.resolve(__dirname, '..', 'ports', 'vwg13', 'uninstall.sh');
function sparse(file, size, text = '') {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const fd = fs.openSync(file, 'w');
  if (text) fs.writeSync(fd, text);
  fs.ftruncateSync(fd, size);
  fs.closeSync(fd);
}
function fixture() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'vwg13-'));
  const app = path.join(root, 'app'), ifs = path.join(root, 'ifs');
  const persist = path.join(root, 'persist'), payload = path.join(root, 'payload');
  sparse(path.join(app, 'eso/bin/apps/dio_manager'), 655359, 'stock-dio');
  sparse(path.join(app, 'eso/hmi/lsd/lsd.sh'), 15909, 'BASE_DIR=/mnt/app/eso/hmi\nJ9=/ifs/j9\n$J9 $BOOTCLASSPATH -jxe /ifs/lsd.jxe &\n');
  fs.mkdirSync(path.join(app, 'eso/hmi/lsd/jars'), { recursive: true });
  sparse(path.join(app, 'armle/lib/dll/ipod-drvr-iap2.so'), 739925);
  sparse(path.join(app, 'armle/lib/libnvss_video.so'), 73304);
  sparse(path.join(ifs, 'lsd.jxe'), 54248171);
  fs.mkdirSync(path.join(persist, 'SWDL'), { recursive: true });
  fs.writeFileSync(path.join(persist, 'SWDL/CachedTrain.txt'), 'MHI2_US_VWG13_P3659_2');
  for (const f of ['core.so', 'dio_manager.wrapper.sh', 'altscreen-most-bridge', 'carplay-cluster-supervisor',
    'cpvc-mirror-canvas', 'libcarplay-security-bridge.so', 'libcpvc-dmdt-query.so',
    'libcpvc-mirror-tap.so', 'NavActiveIgnore-NAR-MU1126.jar',
    'security_bridge/carplay-pairing-helper', 'security_bridge/libCarPlayPairingCore.so']) {
    sparse(path.join(payload, f), 32, `payload-${f}`);
  }
  return { root, app, ifs, persist, payload };
}
function run(script, f, args = [], extra = {}) {
  return cp.spawnSync('sh', [script, ...args], { encoding: 'utf8', env: {
    ...process.env, VWG13_APP: f.app, VWG13_IFS: f.ifs, VWG13_PERSIST: f.persist, ...extra
  }});
}
function hash(file) { return fs.readFileSync(file); }

test('VWG13 installer is target-locked, idempotent, and restores stock', {
  skip: process.platform === 'win32' && process.env.VWG13_FORCE_SHELL_TEST !== '1'
    ? 'full shell simulation runs in Linux CI' : false
}, () => {
  const f = fixture();
  const dio = path.join(f.app, 'eso/bin/apps/dio_manager');
  const lsd = path.join(f.app, 'eso/hmi/lsd/lsd.sh');
  const beforeDio = hash(dio), beforeLsd = hash(lsd);
  let r = run(install, f, [f.payload]);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /INSTALL_OK/);
  assert.ok(fs.existsSync(path.join(f.app, 'carplaymaps/core.so')));
  assert.match(fs.readFileSync(lsd, 'utf8'), /NavActiveIgnore-NAR-MU1126\.jar/);
  r = run(install, f, [f.payload]);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  r = run(uninstall, f);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.deepEqual(hash(dio), beforeDio);
  assert.deepEqual(hash(lsd), beforeLsd);
  assert.ok(!fs.existsSync(path.join(f.app, 'carplaymaps')));
  fs.writeFileSync(path.join(f.persist, 'SWDL/CachedTrain.txt'), 'MHI2_ER_VWG13_K4525');
  r = run(install, f, [f.payload]);
  assert.notEqual(r.status, 0);
  assert.match(r.stdout, /train mismatch/);
});

test('VWG13 installer rolls back every activation boundary', {
  skip: process.platform === 'win32' && process.env.VWG13_FORCE_SHELL_TEST !== '1'
    ? 'full shell simulation runs in Linux CI' : false
}, () => {
  for (const point of ['old_moved', 'root_active', 'jar_active', 'lsd_active', 'dio_active']) {
    const f = fixture();
    const dio = path.join(f.app, 'eso/bin/apps/dio_manager');
    const lsd = path.join(f.app, 'eso/hmi/lsd/lsd.sh');
    const beforeDio = hash(dio), beforeLsd = hash(lsd);
    const r = run(install, f, [f.payload], { VWG13_FAIL_AT: point });
    assert.notEqual(r.status, 0, `failure point ${point} unexpectedly passed`);
    assert.deepEqual(hash(dio), beforeDio, `dio rollback at ${point}`);
    assert.deepEqual(hash(lsd), beforeLsd, `lsd rollback at ${point}`);
    assert.ok(!fs.existsSync(path.join(f.app, 'carplaymaps')), `root residual at ${point}`);
  }
});
