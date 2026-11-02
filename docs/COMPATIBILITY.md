# Compatibility

| Target | Static analysis | Build | Simulation | Vehicle |
| --- | --- | --- | --- | --- |
| Audi AUG22 `MHI2_US_AUG22_K3345` MU1439 | Pass | Source patch passes; payload not built | Not run | Not tested |
| Audi AU57x `MHI2_US_AU57x_K3341_1` MU1426 | Static profile passes; hybrid donor identified | Java, two hooks, and renderer pass | Synthetic failure suite + real-firmware package install/rollback pass | Not tested |
| Audi AU37x `MHI2_US_AU37x_P5107` MU1363 | Direct EU P5089 donor qualification passes | Donor artifacts resolve against NAR runtime | Not run | Not tested |
| Audi AU43x MU1389/MU1462 | Firmware received | Not started | Not run | Not tested |
| Audi AU62x MU1463 | Firmware received | Not started | Not run | Not tested |
| VW VWG13 MU1126 | Firmware received | Not started | Not run | Not tested |

Only an exact profile match is eligible for a future tester build. Similar MU
numbers or platform names are not accepted as substitutes.
