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
HMI, native binaries, system configuration, and `lsd.jxe`. An offline NAR
install/rollback simulation remains required before producing a tester package.

## Current maturity

`DIRECT DONOR STATIC QUALIFICATION PASS / EXACT TARGET GATE PASS / NOT INSTALLER-SIMULATED / NOT VEHICLE TESTED`

No vendor firmware is redistributed. The exact target identity and all file
hashes used for qualification are in
[`profiles/audi-au37x-us-p5107-mu1363.json`](../profiles/audi-au37x-us-p5107-mu1363.json).
