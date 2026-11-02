# AU37x MU1363 target lock

`nar-target-gate.sh` is a fail-closed preflight for
`MHI2_US_AU37x_P5107`, MU1363. It checks the exact HMI build, native CarPlay
files, NAR system configuration, NAR-only USB storage behavior, and `lsd.jxe`
size before handing control to the installer pinned in `upstream.lock.json`.

This gate does not turn the upstream EU package into a vehicle-tested NAR
release. It prevents a future package from relying on the upstream installer's
intentionally broad `MHI2_*_AU37x_*` train check.

For offline validation, redirect the three roots with `AU37_APP`, `AU37_SYS`,
and `AU37_IFS`, then set `AU37_CHECK_ONLY=1`. There is no force/bypass option.
