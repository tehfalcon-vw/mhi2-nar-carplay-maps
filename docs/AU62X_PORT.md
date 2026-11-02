# Audi AU62x / R8 NAR port

## Target and comparison firmware

The exact target is `MHI2_US_AU62x_P5181`, MU1463, app variant 70, HMI
`HMI_AU_MIB2_H_NAR_G24_C10_200600`. The regional comparator is
`MHI2_ER_AU62x_P5099`, MU1340. The implementation donor is the pinned,
vehicle-tested AU37x P5089 project.

## Offline result

- The NAR and EU R8 images have byte-identical iAP2 driver, NvSS library,
  iAP2 client, `mm-ipod`, video-over-MOST launcher, and LSD startup script.
- 30,395 HMI entries are common; 29,733 are byte-identical, 662 differ, NAR
  adds 13, and EU adds one.
- Fourteen of the 15 non-PDC stock classes overridden by the AU37x jars are
  byte-identical. The remaining key-panel dispatcher is an intentional donor
  hook: its stock public API is fully preserved on MU1463, and every donor JAR
  class dependency resolves against the NAR HMI.
- Two PDC base classes differ, so PDC is prohibited.
- All 379 strong imports from the donor's two native hooks and two renderers
  resolve across 1,035 ELF objects in the supplied NAR runtime.
- The pinned donor completed first install, idempotent reinstall, and uninstall
  against a relocated fixture made from the supplied NAR files. Ten installed
  artifacts were checked and all 15 original live files were restored
  byte-for-byte; the donor's documented recovery backups remain intentionally.

## Limits

The host tests validate identity, linkage, file operations, idempotence, and
rollback. They cannot exercise the QNX graphics stack, MOST controller,
CarPlay secondary-screen negotiation, steering-wheel input, or an R8 cockpit.

## Current maturity

`CROSS-FAMILY DIRECT-STACK STATIC QUALIFICATION PASS / INSTALLER TRANSACTION PASS / EXACT TARGET GATE ADDED / PDC PROHIBITED / NOT VEHICLE TESTED`

The exact identity is in
[`profiles/audi-au62x-us-p5181-mu1463.json`](../profiles/audi-au62x-us-p5181-mu1463.json).
