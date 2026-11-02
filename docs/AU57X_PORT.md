# Audi AU57x NAR port

## Target

The target is `MHI2_US_AU57x_K3341_1`, MU1426, app variant 70, with HMI
`HMI_AU_MIB2_H_NAR_G11_C6_184700`.

The supplied same-family donor is `MHI2_ER_AU57x_K3663`, MU1425, HMI
`HMI_AU_MIB2_H_ER_G11_C7_184700`. The working K3663 implementation is pinned
in `upstream.lock.json`.

## Static compatibility result

AU57x requires a hybrid port rather than a direct EU-to-NAR transplant:

- the NAR iAP2 driver, `mm-ipod`, video-over-MOST stack, DMDT, CarPlay proxy,
  and IRC adapter match the qualified NAR AUG22 baseline;
- `usblauncher_otg.lua` and `smartphone_integrator.json` are also identical;
  `iap2.cfg` has the same layout and size but retains its G11 firmware string;
- the K3346/AUG22 fixed-offset verifier passes every check against the AU57x
  NAR iAP2 driver;
- the supplied EU K3663 native binaries and system configuration do not match
  the NAR target and their offsets must not be reused;
- the NAR HMI has 16,222 JAR entries and the EU K3663 HMI has 16,596;
- 16,111 paths are common, of which 12,562 are byte-identical and 3,549
  differ; NAR has 111 unique entries and EU has 485;
- the newer AUG22/K3346 override set cannot be copied wholesale because three
  required classes do not exist in the older G11 HMI namespace;
- the working K3663 project uses the correct older `ClusterService`/DDP2 path
  and is therefore the appropriate Java and cluster-API donor.

## Port architecture

1. Use the verified K3346 native iAP2 hook path and measured NAR offsets.
2. Build the K3663 route-guidance bundle against the NAR AU57x `lsd.jar`.
3. Retain the K3663 `ClusterService`/DDP2 bridge and model-1141 compass
   ownership behavior.
4. Use the adapted launcher and fail-closed installer gated to the exact NAR
   system-file sizes and HMI version in the target profile.
5. Treat full map video as a separate MOST/display-path gate from turn-arrow
   guidance; the K3663 donor proves arrows and HUD guidance, not NAR video.

## Current maturity

`HOST PAYLOAD BUILD PASS / INSTALLER SIMULATION PASS / NOT VEHICLE TESTED`

Private host builds against the supplied NAR firmware produced:

| Artifact | Bytes | SHA-256 | Host checks |
| --- | ---: | --- | --- |
| G11 route-guidance Java bundle | 48,068 | `b6c4004805c1d2b613275fd898ef54e944662e40a177c2ee674052f090a93c79` | 20 classes; Java 1.4 class version; compiled against NAR `lsd.jar` |
| alternate-screen native hook | 306,300 | `c5ccb47b530fc2ebeb92cc09f5ac8636d284710c5b6d20577ab7c133be6dac0c` | ARM ELF32/EABI5; zero unresolved; NAR libc/socket only; upstream ELF verifier pass |
| mm-ipod route-guidance hook | 265,248 | `29cf80b87b1d31d4aad6b242b4f6bd8b537e683c586d3f61de8803b132b17abf` | ARM ELF32/EABI5; zero unresolved; NAR libc/socket only |
| virtual-cockpit video renderer | 15,648 | `b65e7874c7415ccd141574e1e59fc1816df3173bb1ff830961fbb6fc21715b9c` | ARM ELF32/EABI5; zero unresolved; NEEDED only NAR `libc.so.3` and `libsocket.so.3` |

The native builds use the K3346 offsets that passed against the NAR driver,
not the incompatible EU K3663 offsets.

The hybrid installer source now lives in [`ports/au57x`](../ports/au57x). It has
exact target gates, immutable backup, atomic writes, rollback, and an injected
failure path for offline transaction testing. Linux CI exercises install,
rollback, version rejection, and post-write automatic restoration.

The complete assembled payload also passed install and rollback against copied
stock files from the supplied NAR image, including its real `lsd.jxe`. All four
modified stock files returned to their original SHA-256 values after rollback.

Vehicle validation is the remaining gate. Until that is complete, this is not
a public tester release.
