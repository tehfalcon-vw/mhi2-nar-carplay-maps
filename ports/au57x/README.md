# AU57x MU1426 hybrid installer source

This directory contains the fail-closed installer for
`MHI2_US_AU57x_K3341_1`, MU1426. It is source for continued port development,
not a public beta release yet.

The package deliberately combines two independently qualified paths:

- the K3346/AUG22 native AltScreen and iAP2 path, whose critical NAR binaries
  are byte-identical on this AU57x target; and
- the K3663 G11 route-guidance Java bundle, compiled against the target NAR
  `lsd.jxe` API.

## Expected payload

Place these files in a `payload` directory beside `installer.sh`:

```text
libmhi2-nar-au57x-altscreen.so
libmhi2-nar-au57x-rgi-ipod.so
mhi2-nar-au57x-rgi.jar
mm-ipod-au57x-rgi.sh (provided in `payload-src`)
vc_render
mib2high-lvds-control.sh
mib2high-lvds-profile.conf
mib2high-lvds-viewareas.conf
```

The repository does not redistribute proprietary firmware or third-party
binaries. Build inputs and provenance are pinned in `upstream.lock.json`.

## Safety properties

The installer refuses unknown HMI and stock-file layouts, inventories every
touched path, preserves original modes, writes via temporary files and atomic
renames, and automatically restores the immutable backup after a failed
transaction. `rollback` requires that complete backup and never fabricates a
factory file.

All root paths can be redirected with `AU57_APP`, `AU57_SYS`, and `AU57_IFS`.
That is used by the offline simulator; it is not an instruction to bypass the
firmware gates on a vehicle.
