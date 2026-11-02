# Compatibility

| Target | Static analysis | Build | Simulation | Vehicle |
| --- | --- | --- | --- | --- |
| Audi AUG22 `MHI2_US_AUG22_K3345` MU1439 | Pass | Source patch passes; payload not built | Not run | Not tested |
| Audi AU57x `MHI2_US_AU57x_K3341_1` MU1426 | Static profile passes; hybrid donor identified | Java, two hooks, and renderer pass | Synthetic failure suite + real-firmware package install/rollback pass | Not tested |
| Audi AU37x `MHI2_US_AU37x_P5107` MU1363 | Direct EU P5089 donor qualification passes | Donor artifacts resolve against NAR runtime | Not run | Not tested |
| Audi AU43x `MHI2_US_AU43x_P5124` MU1389 | Direct-stack static qualification passes; PDC prohibited | Pinned donor selected | Not run | Not tested |
| Audi AU43x `MHI2_US_AU43x_P5180` MU1462 | Direct-stack static qualification passes; PDC prohibited | Pinned donor selected | Real-firmware install/reinstall/rollback transaction passes | Not tested |
| Audi AU62x `MHI2_US_AU62x_P5181` MU1463 | Direct-stack static qualification passes; PDC prohibited | Pinned donor selected | Real-firmware install/reinstall/rollback transaction passes | Not tested |
| VW VWG13 MU1126 | Firmware received | Not started | Not run | Not tested |

Only an exact profile match is eligible for a future tester build. Similar MU
numbers or platform names are not accepted as substitutes.
