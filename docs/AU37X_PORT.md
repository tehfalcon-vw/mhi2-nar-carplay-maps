# Audi AU37x NAR port

## Target and donor

The target is `MHI2_US_AU37x_P5107`, MU1363, app variant 70, with HMI
`HMI_AU_MIB2_H_NAR_G21_C10_181600`.

The primary donor is the vehicle-tested `MHI2_ER_AU37x_P5089`, MU1326 build in
[`chefranov/mhi2-au37x-carplay`](https://github.com/chefranov/mhi2-au37x-carplay),
pinned in `upstream.lock.json`.

## Static compatibility result

This is the strongest direct donor match found so far:

- the iAP2 driver, NvSS video library, iAP2 client, `mm-ipod`, CarPlay proxy,
  IRC adapter, `lsd.sh`, and trace configuration are byte-identical;
- the donor's replacement HMI base classes are all byte-identical in the NAR
  and EU firmware images;
- of 30,574 HMI entries common to both images, 30,507 are byte-identical;
  NAR adds five entries and the EU image adds none;
- every undefined strong symbol in the donor's two preload hooks and two ARM
  renderers resolves against the supplied NAR executable/library set;
- the NAR and EU `smartphone_integrator.json` layouts differ only in generated
  timestamp metadata, while `iap2.cfg` differs in the expected region/model
  string;
- NAR adds `storage` to one legacy iPod launcher line. The port must patch the
  NAR file in place and must not replace it with the EU copy;
- NAR display-manager binaries differ from EU. The existing hooks resolve by
  symbol, but display behavior still requires vehicle validation.

The upstream installer already accepts both `MHI2_ER_AU37x_*` and
`MHI2_US_AU37x_*` train names. The exact P5107 preflight in
[`ports/au37x`](../ports/au37x) narrows that broad check to the supplied NAR
HMI, native binaries, system configuration, and `lsd.jxe`.

## Installer simulation

The pinned donor's own `install.sh` and `uninstall.sh` were run with only their
four absolute mount prefixes relocated into a disposable fixture populated
from the supplied NAR P5107 image. No installer decisions or patching logic
were rewritten. The audit exercised:

- the `MHI2_US_AU37x_P5107` train check and stock-file conflict checks;
- the default RGI and AltScreen installation path;
- all hooks, jars, renderers, supervisors, shaders, and marker files;
- the `smartphone_integrator.json` backup and in-place NAR patch;
- the `mm-ipod` backup and shim;
- a second complete install to verify idempotency; and
- the complete upstream uninstall path.

Ten installed artifacts were checked. After uninstall, all 15 original live
fixture files matched their pre-install SHA-256 values. The upstream
uninstaller deliberately retains three recovery copies:
`smartphone_integrator.json.orig`, `mm-ipod.orig`, and
`rgd_real/mm-ipod`. Those retained backups are expected, not rollback drift.

This validates the file-level install transaction. It cannot validate QNX
process injection, GPU rendering, MOST transport, steering-wheel input, or an
actual Virtual Cockpit display.

## Current maturity

`DIRECT DONOR STATIC QUALIFICATION PASS / EXACT TARGET GATE PASS / INSTALL-REINSTALL-UNINSTALL SIMULATION PASS / NOT VEHICLE TESTED`

No vendor firmware is redistributed. The exact target identity and all file
hashes used for qualification are in
[`profiles/audi-au37x-us-p5107-mu1363.json`](../profiles/audi-au37x-us-p5107-mu1363.json).
