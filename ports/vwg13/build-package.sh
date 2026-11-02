#!/bin/sh
# Build a local VWG13 MU1126/AID 791 test package without redistributing firmware.
set -eu
[ $# -eq 4 ] || { echo 'usage: build-package.sh <omonob-repo> <mhi2-aid-repo> <nar-lsd.jar> <empty-output-dir>' >&2; exit 2; }
OMONOB=$1
AID=$2
STOCK_JAR=$3
OUT=$4
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

fail(){ echo "BUILD_FAIL: $*" >&2; exit 1; }
[ "$(git -C "$OMONOB" rev-parse HEAD)" = 90751cd7ce8db751083e403d1fa4b79b8c0241b4 ] || fail 'wrong omonob commit'
[ "$(git -C "$AID" rev-parse HEAD)" = b3831a2ab72ee031df7cc58460447dea1700bb8c ] || fail 'wrong mhi2-aid-carplay commit'
[ "$(sha256sum "$STOCK_JAR" | cut -d' ' -f1)" = f1e9035ece699b9e94b5bfa72609d5fc2b6853be21176cfbdcf8670725981812 ] || fail 'wrong converted NAR MU1126 lsd.jar'
[ ! -e "$OUT" ] || fail 'output path already exists'
: "${ASM_DIR:?set ASM_DIR to the ASM 9.7 directory used by mhi2-aid-carplay}"

TMP=$(mktemp -d "${TMPDIR:-/tmp}/mhi2-vwg13.XXXXXX")
trap 'rm -rf "$TMP"' EXIT HUP INT TERM
mkdir -p "$TMP/aid" "$OUT/payload/security_bridge" "$OUT/source-notices"
cp -R "$AID/navactiveignore" "$AID/buildtools" "$TMP/aid/"
(cd "$TMP/aid" && patch -p1 < "$HERE/patches/navactiveignore-mu1126.patch")
"$TMP/aid/navactiveignore/build.sh" NAR_MU1126 "$STOCK_JAR" "$TMP/nai"

BASE="$OMONOB/MU1102/791_AID12.3/payload"
cp "$BASE/profiles/MU1102/791/core.so" "$OUT/payload/core.so"
for f in altscreen-most-bridge carplay-cluster-supervisor cpvc-mirror-canvas-791 libcarplay-security-bridge.so libcpvc-dmdt-query.so libcpvc-mirror-tap.so; do
    cp "$BASE/common/$f" "$OUT/payload/$f"
done
mv "$OUT/payload/cpvc-mirror-canvas-791" "$OUT/payload/cpvc-mirror-canvas"
cp "$BASE/common/carplay-pairing-helper" "$OUT/payload/security_bridge/"
cp "$BASE/common/libCarPlayPairingCore.so" "$OUT/payload/security_bridge/"
cp "$BASE/common/dio_manager.wrapper.sh" "$OUT/payload/dio_manager.wrapper.sh"
(cd "$OUT/payload" && patch -p1 < "$HERE/patches/wrapper-mu1126.patch")
cp "$TMP/nai/NavActiveIgnore.jar" "$OUT/payload/NavActiveIgnore-NAR-MU1126.jar"
cp "$HERE/installer.sh" "$HERE/uninstall.sh" "$OUT/"
cp "$OMONOB/LICENSE" "$OUT/source-notices/omonob-GPL-3.0.txt"
cp "$AID/LICENSE" "$OUT/source-notices/mhi2-aid-carplay-GPL-3.0.txt"
(
  cd "$OUT"
  find payload -type f | sort | while read -r f; do sha256sum "$f"; done > SHA256SUMS.txt
)
echo 'PACKAGE_BUILD_OK'
