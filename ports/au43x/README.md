# AU43x / Audi TT target locks

This directory contains a fail-closed preflight for exactly
`MHI2_US_AU43x_P5124`, MU1389. It rejects the optional PDC overlay because one
of its overridden stock classes differs between the NAR and EU TT images.

It also contains a separate preflight and donor patch for exactly
`MHI2_US_AU43x_P5180`, MU1462. That image is byte-identical at the app-image
level to the qualified AU62x P5181 image. Use `nar-p5180-target-gate.sh` with
`allow-p5180.patch`; PDC is prohibited because two PDC classes differ.

The qualified default path is the pinned AU37x implementation with RGI and
AltScreen enabled and PDC disabled. The donor's train allow-list must be
patched with `allow-p5124.patch` to admit only `MHI2_US_AU43x_P5124`; do not
weaken it to all AU43x firmware. The gate then checks the exact HMI, native
stack, NAR launch/config files, and `lsd.jxe` before handing off.

Apply the patch only to the exact donor commit pinned in `upstream.lock.json`:

```sh
git -C mhi2-au37x-carplay checkout a46136f705f61442e9074d2e43f2533c567307f2
git -C mhi2-au37x-carplay apply ../mhi2-nar-carplay-maps/ports/au43x/allow-p5124.patch
```

For P5180, substitute `allow-p5180.patch` and run
`nar-p5180-target-gate.sh`. Never apply both train patches to one donor tree.

For offline validation, redirect roots with `AU43_APP`, `AU43_SYS`, and
`AU43_IFS`, then set `AU43_CHECK_ONLY=1`. There is no bypass option.
P5180 uses the equivalent `AU43_P5180_*` variables.
