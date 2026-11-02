# AU43x / Audi TT MU1389 target lock

This directory contains a fail-closed preflight for exactly
`MHI2_US_AU43x_P5124`, MU1389. It rejects the optional PDC overlay because one
of its overridden stock classes differs between the NAR and EU TT images.

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

For offline validation, redirect roots with `AU43_APP`, `AU43_SYS`, and
`AU43_IFS`, then set `AU43_CHECK_ONLY=1`. There is no bypass option.
