#!/bin/sh
# Build a ready-to-copy M.I.B. SD-card tree from the pinned GPL donor.
set -eu

usage() {
    cat <<'EOF'
Usage: sh tools/build-audi-test-package.sh TARGET DONOR_DIR OUTPUT_DIR

Targets:
  au37x-p5107   Audi A3 MHI2_US_AU37x_P5107 / MU1363
  au43x-p5124   Audi TT MHI2_US_AU43x_P5124 / MU1389
  au43x-p5180   Audi TT MHI2_US_AU43x_P5180 / MU1462
  au62x-p5181   Audi R8 MHI2_US_AU62x_P5181 / MU1463
EOF
}

[ $# -eq 3 ] || { usage; exit 2; }
TARGET=$1
DONOR=$2
OUT=$3
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PIN=a46136f705f61442e9074d2e43f2533c567307f2

[ -d "$DONOR/.git" ] || { echo "ERROR: donor is not a Git checkout: $DONOR" >&2; exit 1; }
[ ! -e "$OUT" ] || { echo "ERROR: output already exists: $OUT" >&2; exit 1; }

HEAD=$(git -C "$DONOR" rev-parse HEAD 2>/dev/null) || {
    echo "ERROR: cannot read donor revision" >&2
    exit 1
}
[ "$HEAD" = "$PIN" ] || {
    echo "ERROR: donor revision is $HEAD" >&2
    echo "Expected: $PIN" >&2
    exit 1
}

case "$TARGET" in
    au37x-p5107)
        GATE="$ROOT/ports/au37x/nar-target-gate.sh"
        CHECK_VAR=AU37_CHECK_ONLY
        PATCH=
        ;;
    au43x-p5124)
        GATE="$ROOT/ports/au43x/nar-target-gate.sh"
        CHECK_VAR=AU43_CHECK_ONLY
        PATCH="$ROOT/ports/au43x/allow-p5124.patch"
        ;;
    au43x-p5180)
        GATE="$ROOT/ports/au43x/nar-p5180-target-gate.sh"
        CHECK_VAR=AU43_P5180_CHECK_ONLY
        PATCH="$ROOT/ports/au43x/allow-p5180.patch"
        ;;
    au62x-p5181)
        GATE="$ROOT/ports/au62x/nar-target-gate.sh"
        CHECK_VAR=AU62_CHECK_ONLY
        PATCH="$ROOT/ports/au62x/allow-p5181.patch"
        ;;
    *)
        echo "ERROR: unknown target: $TARGET" >&2
        usage
        exit 2
        ;;
esac

mkdir -p "$OUT/mod/carplay"
git -C "$DONOR" archive "$PIN" | tar -x -C "$OUT/mod/carplay"
PAYLOAD=$OUT/mod/carplay

if [ -n "$PATCH" ]; then
    (cd "$PAYLOAD" && patch -p1 < "$PATCH")
fi

cp "$GATE" "$PAYLOAD/target-gate.sh"
cp "$ROOT/tools/audi-test-install.sh" "$PAYLOAD/install-nar.sh"
cp "$ROOT/tools/audi-test-check.sh" "$PAYLOAD/check-nar.sh"
cp "$ROOT/tools/audi-mib-custom.sh" "$OUT/mod/custom.sh"
cp "$ROOT/tools/audi-mib-command.sh" "$OUT/mod/command.sh"
printf '%s\n' "$TARGET" > "$PAYLOAD/TARGET"
printf '%s\n' "$CHECK_VAR" > "$PAYLOAD/CHECK_VARIABLE"
printf '%s\n' "$PIN" > "$PAYLOAD/DONOR_COMMIT"
chmod +x "$OUT/mod/custom.sh" "$OUT/mod/command.sh" \
    "$PAYLOAD/target-gate.sh" "$PAYLOAD/install-nar.sh" "$PAYLOAD/check-nar.sh"

cat > "$OUT/README-FIRST.txt" <<EOF
MHI2 NAR CarPlay Maps beta package: $TARGET

Copy the mod folder to the root of a FAT32 SD card.

SAFE CHECK (no changes):
  Leave the package as-is and run M.I.B. Advanced Settings -> Run Custom Script.
  Continue only if the output contains TARGET_GATE=PASS.

INSTALL:
  Create an empty file named INSTALL in mod/carplay, then run the custom script
  again. Never add PDC or IGNORE_CONFLICTS markers to a NAR beta package.

UNINSTALL:
  Remove INSTALL, create an empty file named UNINSTALL in mod/carplay, and run
  the custom script again.

Full instructions: https://github.com/tehfalcon-vw/mhi2-nar-carplay-maps
EOF

echo "Built $TARGET package at: $OUT"
echo "First M.I.B. run is check-only. Add mod/carplay/INSTALL only after TARGET_GATE=PASS."
