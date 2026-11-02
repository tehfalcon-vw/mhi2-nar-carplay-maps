# Audi AUG22 NAR port

## Target

The first implementation target is the internally identified firmware
`MHI2_US_AUG22_K3345`, MU 1439, app variant 70. The supplied distribution
archive is labelled K3347, but its signed package metadata identifies K3345.

The working donor is `MHI2_ER_AUG22_K3346`, MU 1438, at upstream commit
`17b4a2c5ff4ad113c7ad1df9a89fd5fd940738b2`.

## Static compatibility result

Read-only extraction and host-side comparison established the following:

- the stock iAP2 driver is byte-identical to K3346 and passed every upstream
  fixed-offset verifier check;
- `mm-ipod`, `videoovermost`, `libdsicarplayproxy`, `libiap2client`,
  `libnvss_video`, DMDT, and the IRC adapter are byte-identical;
- the NAR and EU HMI images contain the same 29,088 JAR entries;
- 29,072 entries are byte-identical and only 16 region-specific entries differ;
- all seven stock classes replaced by the K3346 Stage 5 implementation are
  byte-identical between EU and NAR;
- `usblauncher_otg.lua` and `smartphone_integrator.json` are byte-identical;
- `iap2.cfg` differs in its EU/NAR firmware-version string and is one byte
  longer on NAR.

This is strong evidence that the K3346 native and Java implementation can be
rebuilt for the NAR HMI without reusing EU HMI binaries. It is not vehicle-test
evidence.

## Source preparation

1. Check out the pinned upstream commit in `upstream.lock.json`.
2. Apply `patches/audi-aug22-us-k3345-mu1439.patch`.
3. Extract the NAR `lsd.jxe` and convert it with the pinned `jxe2jar` revision.
4. Set `K2161_BASE_JAR` to the resulting NAR `lsd.jar` when building the Java
   map bundle and override classes.
5. Run upstream `verify_port_offsets.py` against the NAR
   `ipod-drvr-iap2.so`; every check must pass.
6. Run the upstream installer simulations using the NAR stock files.

Do not build Stage 5 against the EU `lsd.jar`. Although every replaced stock
class is identical, building against the NAR JAR keeps the artifact provenance
and API verification tied to the deployment target.

## Installer gates

The NAR patch preserves the fail-closed checks and changes only measured target
values:

| Gate | NAR value |
| --- | --- |
| HMI version | `HMI_AU_MIB2_H_NAR_G22_C6_190300` |
| `ipod-drvr-iap2.so` | 739,925 bytes |
| `/ifs/lsd.jxe` | 58,130,366 bytes |
| stock `usblauncher_otg.lua` | 19,907 bytes |
| stock `iap2.cfg` | 5,853 bytes |
| patched USB-only `iap2.cfg` | 5,992 bytes |
| patched Bluetooth `iap2.cfg` | 6,142 bytes |
| stock `mm-ipod` | 40,297 bytes |

The emergency `MIB_FORCE` bypass remains an upstream developer facility and
must not be used for a tester package.

## Current maturity

`HOST-STATIC MATCH / NOT VEHICLE TESTED`

No public installer is released yet. The remaining offline gates are a NAR
source build, real-installer simulation against NAR fixtures, release-package
audit, and payload verification. The patched deployment shell already passes
the pinned QNX target-shell static checker.
