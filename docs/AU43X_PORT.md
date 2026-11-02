# Audi AU43x / TT NAR port

## Target and comparison firmware

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

## Current maturity

`CROSS-FAMILY DIRECT-STACK STATIC QUALIFICATION PASS / EXACT TARGET GATE ADDED / PDC PROHIBITED / NOT INSTALLER-SIMULATED / NOT VEHICLE TESTED`

The exact identity is in
[`profiles/audi-au43x-us-p5124-mu1389.json`](../profiles/audi-au43x-us-p5124-mu1389.json).
