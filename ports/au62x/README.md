# AU62x / Audi R8 MU1463 target lock

This directory contains a fail-closed preflight for exactly
`MHI2_US_AU62x_P5181`, MU1463. The qualified path uses the pinned AU37x
implementation with RGI and AltScreen enabled and PDC disabled.

Apply `allow-p5181.patch` only to the exact donor commit pinned in
`upstream.lock.json`, then invoke the patched installer through
`nar-target-gate.sh`. Do not broaden the allow-list to other AU62x trains.

```sh
git -C mhi2-au37x-carplay checkout a46136f705f61442e9074d2e43f2533c567307f2
git -C mhi2-au37x-carplay apply ../mhi2-nar-carplay-maps/ports/au62x/allow-p5181.patch
sh ports/au62x/nar-target-gate.sh ../mhi2-au37x-carplay/install.sh
```

The gate checks HMI identity, core native files, NAR launch/config files, and
`lsd.jxe`. It rejects `PDC=1`; two PDC base classes differ on this target.
For offline validation, redirect roots with `AU62_APP`, `AU62_SYS`, and
`AU62_IFS`, then set `AU62_CHECK_ONLY=1`. There is no bypass option.
