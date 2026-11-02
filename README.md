# MHI2 NAR CarPlay Maps

MHI2-only project for displaying CarPlay navigation guidance and map video in
North American VW and Audi Virtual Cockpits.

## Scope

- Harman MHI2 units only.
- North American Region firmware is the deployment target.
- VW and Audi variants are supported as separate, fingerprinted targets.
- MHI2Q, MHS2, MH2P, MST2, and other platforms stay in their own repositories.

## Status

Initial firmware-intake repository. No installable build exists yet and nothing
in this repository should be installed on a vehicle.

The first milestone is to identify one exact NAR target and its closest working
EU donor, then map:

1. CarPlay route-guidance negotiation and messages;
2. the MHI2 cluster/BAP guidance interface;
3. the CarPlay secondary-screen video path;
4. the MOST video transport to the Virtual Cockpit; and
5. a reversible, target-locked installation method.

## Firmware needed

For the first target, provide:

- the complete NAR firmware archive;
- the exact train and MU version shown by the unit;
- brand and hardware part number when known; and
- a working EU firmware or project that supports the same feature.

Do not commit firmware, extracted vendor binaries, keys, certificates, or
personal vehicle data. Keep them outside the repository and use the local
fingerprint tool instead.

## Fingerprint an extracted firmware tree

Node.js 22 or newer is required.

```sh
npm test
npm run fingerprint -- path/to/extracted-firmware firmware-manifest.json
```

The tool records relative paths, byte sizes, and SHA-256 values without copying
firmware into the repository. Review the manifest for sensitive filenames
before sharing it.

## Repository layout

```text
docs/       firmware intake and development notes
targets/    reviewed target manifests with no firmware content
tools/      read-only analysis and build tools
test/       host-side tests
```

Implementation directories will be added only after the first NAR firmware is
fingerprinted and the platform boundaries are known.

## Safety

Future builds must fail closed on unknown firmware, create verified backups,
and provide a tested rollback path. Vehicle testing starts only after host-side
validation and requires stable power plus recovery access.

## License

Original project source is available under the [MIT License](LICENSE). Vendor
firmware and third-party assets are not included. Volkswagen, Audi, Apple,
CarPlay, and other trademarks belong to their respective owners.
