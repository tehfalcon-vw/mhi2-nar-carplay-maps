# MHI2 NAR CarPlay Maps

MHI2-only project for displaying CarPlay navigation guidance and map video in
North American VW and Audi Virtual Cockpits.

## Scope

- Harman MHI2 units only.
- North American Region firmware is the deployment target.
- VW and Audi variants are supported as separate, fingerprinted targets.
- MHI2Q, MHS2, MH2P, MST2, and other platforms stay in their own repositories.

## Status

Active port development. No public installable build exists yet.

The first target is Audi AUG22 `MHI2_US_AUG22_K3345`, MU1439. Host-side
analysis found that its core iAP2, RGI, video-over-MOST, and HMI classes match
the working EU K3346 implementation closely enough for a target-locked NAR
source build. The fixed iAP2 hook verifier passes completely.

See [the AUG22 port report](docs/AUG22_PORT.md) and the
[compatibility matrix](docs/COMPATIBILITY.md). These results are static
firmware evidence, not vehicle-test evidence.

AU57x MU1426 is the second analyzed target. Its native CarPlay/MOST layer
matches the qualified NAR AUG22 baseline, while its older G11 HMI requires the
working K3663 cluster/HUD implementation as a Java/API donor. See the
[AU57x port report](docs/AU57X_PORT.md). Its hybrid payload now builds, and its
fail-closed installer has completed install and rollback against copied files
from the supplied NAR image; it has not been tested in a vehicle.

AU37x MU1363 is the third analyzed target. Its NAR iAP2/video stack and every
donor-overridden HMI base class match the car-tested EU P5089 implementation.
The full pinned donor installer, idempotent reinstall, and uninstaller have
also passed against a relocated fixture made from the supplied NAR files, with
all live stock files restored byte-for-byte. See the
[AU37x port report](docs/AU37X_PORT.md).

AU43x / Audi TT MU1389 and MU1462 are analyzed targets. Their NAR and EU TT
core CarPlay stacks match the selected architecture, and the AU37x
implementation's non-PDC HMI overrides are compatible. MU1462 also completed
a relocated install/reinstall/uninstall transaction. PDC is explicitly
prohibited. See the [AU43x port report](docs/AU43X_PORT.md).

AU62x / Audi R8 MU1463 is the fifth analyzed target. Its exact target gate,
native and HMI linkage audits, and a complete relocated install/reinstall/
uninstall transaction pass. The AU37x donor's key-panel hook preserves the
MU1463 public API; PDC is prohibited because two PDC base classes differ. See
the [AU62x port report](docs/AU62X_PORT.md).

VWG13 MU1126 is the first Volkswagen target. Its map-only package builds from
pinned donors plus the exact NAR HMI, the NAR-derived NavActiveIgnore patch
passes J9 bytecode and reference verification, and its staged installer passes
install/reinstall/byte-exact rollback on copied firmware files. Native route
guidance and generic MU1102 menu/control jars are intentionally excluded. See
the [VWG13 port report](docs/VWG13_PORT.md).

## Firmware coverage

NAR and EU/RoW firmware donors have been received for AUG22, AU57x, AU37x,
AU43x, AU62x, and VWG13. Firmware remains private analysis input and is never
committed.

Do not commit firmware, extracted vendor binaries, keys, certificates, or
personal vehicle data. Keep them outside the repository and use the local
fingerprint tool instead.

## Fingerprint an extracted firmware tree

Node.js 22 or newer is required.

```sh
npm test
npm run fingerprint -- path/to/extracted-firmware firmware-manifest.json
npm run verify-target -- profiles/audi-aug22-us-k3345-mu1439.json path/to/app-tree --lsd path/to/lsd.jxe
```

The tool records relative paths, byte sizes, and SHA-256 values without copying
firmware into the repository. Review the manifest for sensitive filenames
before sharing it.

## Repository layout

```text
docs/       firmware intake and development notes
patches/    target-specific changes to pinned upstream source
profiles/   exact, fail-closed NAR target identities
ports/      target-specific installer and payload source
targets/    reviewed target manifests with no firmware content
tools/      read-only analysis and build tools
test/       host-side tests
```

`profiles/` contains fail-closed target identities. A profile match means only
that the supplied files match the analyzed firmware; it does not mean a build
has been tested in a vehicle.

The `AUG22 source audit` workflow checks the NAR patch against an exact pinned
upstream revision and runs the pinned QNX-target shell auditor. It uses no
firmware or vendor binaries and does not produce an install package.

## Safety

Future builds must fail closed on unknown firmware, create verified backups,
and provide a tested rollback path. Vehicle testing starts only after host-side
validation and requires stable power plus recovery access.

## License

Original project source is available under the [MIT License](LICENSE). Vendor
firmware and third-party assets are not included. Volkswagen, Audi, Apple,
CarPlay, and other trademarks belong to their respective owners.
