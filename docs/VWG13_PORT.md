# Volkswagen VWG13 NAR port

## Exact target

`MHI2_US_VWG13_P3659_2`, MU1126, app variant 70, AID 791. The NAR HMI is
identified by `lsd.jxe` size 54,248,171 and SHA-256
`5c53b4af46eba389fb4865ae7f07a26a0eea5bcf55ff02791be11fa88e663c62`.
The supplied comparator is EU K4525 MU1367.

## What qualified offline

- All 548 strong imports in the nine-file MU1102/MU1367 native map and pairing
  stack resolve against the NAR runtime plus the stack's own provider library.
- MU1102 and MU1367 use an identical 791 `core.so`, supporting the native
  stack's firmware-independent design across those proven versions.
- The generic donor navigation/menu/control JARs are not safe on MU1126. They
  have missing public API and unresolved HMI references, so the installer
  excludes them.
- NavActiveIgnore was rebuilt from the five exact NAR stock classes. Its ASM
  patch matched every expected instruction pattern, produced six J9-v46
  classes including the helper, passed bytecode verification, passed the host
  behavior test, and reported zero target-HMI reference problems.
- A local package build is reproducible from two pinned GPL donor commits and
  the exact NAR converted JAR.
- First install, idempotent reinstall, and uninstall passed on a relocated
  fixture built from the supplied NAR files. All six original fixture files
  were restored byte-for-byte with no residual files. Injected failures at all
  five activation boundaries also restored stock state.

## Not included

Native route guidance, steering-wheel zoom, VW menu integration, and now-
playing metadata are not qualified. In particular, the NAR iAP2 driver has a
different hash from the proven MU1161 driver; reusing its patch offsets would
be unsafe.

## Maturity

`MAP-ONLY SOURCE BUILD PASS / NAR HMI PATCH VERIFY PASS / NATIVE LINK PASS / INSTALL-REINSTALL-ROLLBACK PASS / NOT VEHICLE TESTED`
