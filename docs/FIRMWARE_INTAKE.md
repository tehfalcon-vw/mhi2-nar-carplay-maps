# Firmware intake

Create one manifest for the NAR target and one for the working EU donor. Record
the source archive name, train, MU version, brand, hardware part number, and the
SHA-256 of the original archive outside this repository.

Extract each archive into a private working directory, then run:

```sh
npm run fingerprint -- path/to/extracted-firmware path/to/manifest.json
```

Before committing a manifest:

- confirm it contains only relative paths, sizes, and hashes;
- remove entries that reveal personal or private filenames;
- identify the exact variant represented by the tree; and
- place the reviewed result under `targets/<train>.json`.

Never rename a target to make two different firmware trees appear compatible.
Each accepted build must be tied to its own immutable fingerprints.
