# VWG13 MU1126 / AID 791 map-only port

This port targets exactly `MHI2_US_VWG13_P3659_2`, MU1126, with the 12.3-inch
791 Active Info Display. It is deliberately map-only: CarPlay map video plus a
NavActiveIgnore JAR built from this NAR firmware's own HMI classes.

The generic MU1102/MU1367 menu, steering-control, and navigation JARs are not
installed because their replaced classes do not preserve the MU1126 public
API. Native turn guidance is also excluded: the NAR iAP2 driver differs from
the proven MU1161 driver, so its binary patch offsets must not be reused.

## Local package build

The repository does not redistribute firmware-derived Java classes or donor
binaries. Build locally with the exact pinned donor revisions in
`upstream.lock.json`, a converted JAR from the supplied NAR `lsd.jxe`, JDK 11+
and ASM 9.7:

```sh
ASM_DIR=/path/to/asm-9.7-libs \
ports/vwg13/build-package.sh \
  /path/to/omonob-MHI2-Carplay-Maps \
  /path/to/mhi2-aid-carplay \
  /path/to/nar-mu1126-lsd.jar \
  /path/to/new-package
```

The builder pins both Git revisions and the converted NAR JAR hash, compiles
and verifies the six J9-v46 HMI classes, patches the 791 wrapper profile, copies
the link-qualified native stack, and emits `SHA256SUMS.txt` plus license
notices. Run `installer.sh payload` on the unit; `uninstall.sh` restores stock.

The installer rejects every train except P3659_2, checks the exact HMI and
native file sizes, stages writes, preserves the original `dio_manager` and
`lsd.sh`, supports idempotent reinstall, and provides byte-exact rollback.
The host suite injects failures at each of the five activation boundaries.

## Limits

Host validation cannot exercise QNX graphics, CarPlay secondary-screen
negotiation, MOST transport, or the AID. No physical test has been performed.
Use only on an exact target with recovery access and stable power.
