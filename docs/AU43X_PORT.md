# Audi AU43x / TT NAR port

## MU1389 target and comparison firmware

The target is `MHI2_US_AU43x_P5124`, MU1389, app variant 70, HMI
`HMI_AU_MIB2_H_NAR_G24_C10_182700`. The regional comparator is
`MHI2_ER_AU43x_P5098`, MU1339. The implementation donor is the pinned,
vehicle-tested AU37x P5089 project because its iAP2/MOST/HMI hook architecture
matches this firmware family.

## Offline result

- The NAR and EU TT images have byte-identical iAP2 driver, NvSS library,
  iAP2 client, `mm-ipod`, video-over-MOST launcher, IRC adapter, CarPlay proxy,
  trace configuration, and LSD startup script.
- 30,395 HMI entries are common; 30,319 are byte-identical, 76 differ, NAR
  adds five, and EU adds one.
- Every stock base class overridden by the AU37x cover-art, D-pad, and RGI jars
  is byte-identical in the two TT images.
- Fifteen of 16 PDC base classes are identical. PDC is therefore prohibited,
  not merely defaulted off.
- All 379 strong imports from the donor's two native hooks and two renderers
  resolve across 1,035 ELF objects in the supplied NAR app/stage images.
- NAR display-manager/video binaries differ from EU, so symbol resolution is
  necessary but not proof of runtime behavior.
- The pinned donor completed first install, idempotent reinstall, and uninstall
  against a relocated P5124 fixture. Ten installed artifacts were checked and
  all 15 original live files were restored byte-for-byte.

## Current maturity

`CROSS-FAMILY DIRECT-STACK STATIC QUALIFICATION PASS / INSTALLER TRANSACTION PASS / EXACT TARGET GATE ADDED / PDC PROHIBITED / NOT VEHICLE TESTED`

The exact identity is in
[`profiles/audi-au43x-us-p5124-mu1389.json`](../profiles/audi-au43x-us-p5124-mu1389.json).

## MU1462 / P5180 result

The later TT target is `MHI2_US_AU43x_P5180`, MU1462, HMI
`HMI_AU_MIB2_H_NAR_G24_C10_200600`. Its entire app image and `lsd.jxe` are
byte-identical to the separately qualified AU62x P5181 target. Against EU TT
P5098, 29,733 of 30,395 common HMI entries are byte-identical; the donor's 14
ordinary non-PDC base classes match exactly and its intentional key-panel hook
preserves the target's public API. All 379 native strong imports resolve.

The pinned donor also passed first install, idempotent reinstall, and uninstall
against a relocated P5180 fixture. Ten installed artifacts were checked and 15
original live files were restored byte-for-byte. PDC remains prohibited.

`P5180: STATIC QUALIFICATION PASS / INSTALLER TRANSACTION PASS / EXACT TARGET GATE ADDED / PDC PROHIBITED / NOT VEHICLE TESTED`

Its identity is in
[`profiles/audi-au43x-us-p5180-mu1462.json`](../profiles/audi-au43x-us-p5180-mu1462.json).
