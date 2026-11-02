# Compatibility

Only exact firmware matches are supported. No entry in this table implies
vehicle validation unless it explicitly says so.

| Platform | NAR target | Status | Notes |
| --- | --- | --- | --- |
| Audi AU37x | `MHI2_US_AU37x_P5107` / MU1363 | Public beta | Exact gate; offline install, reinstall, and byte-exact rollback pass |
| Audi AU43x TT | `MHI2_US_AU43x_P5124` / MU1389 | Public beta | Exact gate; offline transaction passes; PDC disabled |
| Audi AU43x TT | `MHI2_US_AU43x_P5180` / MU1462 | Public beta | Exact gate; offline transaction passes; PDC disabled |
| Audi AU62x R8 | `MHI2_US_AU62x_P5181` / MU1463 | Public beta | Exact gate; offline transaction passes; PDC disabled |
| Audi AU57x | `MHI2_US_AU57x_K3341_1` / MU1426 | Developer only | Hybrid source payload; no public tester package |
| Audi AUG22 | `MHI2_US_AUG22_K3345` / MU1439 | Developer only | Source/static-audit port; no public tester package |
| VW VWG13 | `MHI2_US_VWG13_P3659_2` / MU1126 | Developer only | Map-only source build; no public tester package |

Unsupported: MHI2Q, MHS2, MH2P, MST2, Technisat/Preh, unknown trains, and all
firmware not listed above. Android Auto map video is not currently claimed.
