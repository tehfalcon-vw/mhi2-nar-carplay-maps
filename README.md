# MHI2 NAR CarPlay Maps

Beta port of CarPlay navigation maps and route guidance to North American Audi
Virtual Cockpit systems running Harman MHI2 firmware.

This repository contains target checks, source patches, and packaging tools. It
does not contain Audi firmware or third-party compiled payloads. MHI2Q, MHS2,
MH2P, MST2, and Technisat/Preh units are not supported here.

> **Beta software:** the packages below pass offline install, reinstall, and
> rollback tests, but have not been verified in a vehicle. A wrong or
> interrupted installation can leave the MMI screen unusable. Test only with
> stable power, a full backup, and known recovery access.

## Supported beta targets

The full train must match. Similar names and newer/older releases are rejected.

| Vehicle | Exact NAR firmware | MU | Package target |
| --- | --- | ---: | --- |
| Audi A3 | `MHI2_US_AU37x_P5107` | 1363 | `au37x-p5107` |
| Audi TT | `MHI2_US_AU43x_P5124` | 1389 | `au43x-p5124` |
| Audi TT | `MHI2_US_AU43x_P5180` | 1462 | `au43x-p5180` |
| Audi R8 | `MHI2_US_AU62x_P5181` | 1463 | `au62x-p5181` |

AU57x K3341, AUG22 K3345, and VWG13 P3659_2 are source/developer ports only;
they are not ready for public vehicle testing. See the concise
[compatibility table](docs/COMPATIBILITY.md).

## What testers need

- A unit on one of the exact firmware trains above.
- M.I.B. with **Run Custom Script** / **Run individual script**, or SSH access.
- A full M.I.B. backup and a recovery method already tested on the vehicle.
- A stable external vehicle power supply. Do not install from battery alone.
- A FAT32 SD card, Git, and Git Bash (Windows), macOS, or Linux.
- A wired iPhone and an existing working CarPlay connection.

This beta currently claims CarPlay map and route-guidance support only. Do not
assume Android Auto map video is supported.

## 1. Confirm the firmware

Open the MMI version information and compare the complete train and MU number
with the table above. Do not continue on a partial match.

The package also performs a read-only check of the train and exact stock files
on the unit. There is no force or bypass option.

## 2. Build the SD-card package

The package is assembled locally from the pinned GPL donor so its license and
history remain intact. In Git Bash or a Unix shell:

```sh
git clone https://github.com/tehfalcon-vw/mhi2-nar-carplay-maps.git
git clone https://github.com/chefranov/mhi2-au37x-carplay.git
git -C mhi2-au37x-carplay checkout a46136f705f61442e9074d2e43f2533c567307f2

sh mhi2-nar-carplay-maps/tools/build-audi-test-package.sh \
  au37x-p5107 \
  mhi2-au37x-carplay \
  mhi2-nar-beta
```

Replace `au37x-p5107` with the package target from the table for a TT or R8.
The builder refuses a different donor revision or an existing output folder.

Copy the generated `mhi2-nar-beta/mod` folder to the root of a FAT32 SD card.
The resulting card must contain:

```text
mod/
  custom.sh
  command.sh
  carplay/
    check-nar.sh
    install-nar.sh
    target-gate.sh
    install.sh
    uninstall.sh
```

## 3. Run the safe check

Leave the package unchanged for the first run—do **not** create the `INSTALL`
file yet.

1. Connect stable external power and switch the ignition on.
2. Insert the SD card.
3. In M.I.B., open **Advanced Settings**.
4. Select **Run Custom Script** or **Run individual script**.
5. Read the output. Continue only if it ends with `TARGET_GATE=PASS`.

The first run is read-only. A missing file, changed file size, or wrong firmware
stops the check. Photograph or save any failure rather than trying to bypass it.

With SSH, the equivalent command is:

```sh
sh /path/to/mod/carplay/check-nar.sh
```

## 4. Install

1. Remove the SD card and create an empty file named `INSTALL` inside
   `mod/carplay`.
2. Reinsert the card and run the same M.I.B. custom-script command.
3. Confirm the target gate passes and the installer finishes without errors.
4. Reboot the MMI only after the script tells you it has completed.
5. Connect the iPhone by USB, open CarPlay Maps, start a route, and select the
   navigation view in the Virtual Cockpit.

Do not add `PDC` or `IGNORE_CONFLICTS` marker files. The NAR wrapper rejects
both. Other donor options should be left at their defaults for the first test.

## 5. Report a test

Open a [GitHub issue](https://github.com/tehfalcon-vw/mhi2-nar-carplay-maps/issues)
and include:

- Vehicle model/year, full firmware train, MU, and package target.
- Whether the read-only gate printed `TARGET_GATE=PASS`.
- Wired or wireless CarPlay.
- Main-screen behavior, cockpit map, maneuver arrows, audio, and steering-wheel
  controls.
- Clear photos or a short video and the complete installer output.

Remove VINs, device names, account details, and other personal information.

## Uninstall and recovery

For a normal uninstall, remove the `INSTALL` file, create an empty file named
`UNINSTALL` beside it in `mod/carplay`, and run the M.I.B. custom script again.
Reboot after it completes.

With SSH:

```sh
SRC_DIR=/path/to/mod/carplay sh /path/to/mod/carplay/uninstall.sh
```

If the main screen is black, do not repeatedly cycle power. Use the recovery
access prepared before testing, run the same uninstaller, and preserve the log
and backup files for the issue report.

## Developers

Run the host-side checks with Node.js 22 or newer:

```sh
npm test
```

`profiles/` contains exact firmware identities, `ports/` contains target gates
and source patches, and `test/` exercises the fail-closed behavior. Firmware,
keys, certificates, extracted vendor files, and personal vehicle data must not
be committed.

## License

Original code in this repository is provided under the [MIT License](LICENSE).
The generated tester package contains the pinned GPL-3.0 donor and retains its
license files. Vendor firmware is not included. Audi, Volkswagen, Apple, and
CarPlay are trademarks of their respective owners; this is an independent
community project.
