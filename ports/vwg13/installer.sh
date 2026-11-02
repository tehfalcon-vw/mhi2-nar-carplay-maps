#!/bin/sh
# Target-locked map-only installer for MHI2_US_VWG13_P3659_2 / MU1126 / AID 791.
set -u
PAYLOAD=${1:-${VWG13_PAYLOAD:-}}
APP=${VWG13_APP:-/mnt/app}
IFSROOT=${VWG13_IFS:-/ifs}
PERSIST=${VWG13_PERSIST:-/net/rcc/mnt/efs-persist}
ROOT=$APP/carplaymaps
DIO=$APP/eso/bin/apps/dio_manager
LSD=$APP/eso/hmi/lsd/lsd.sh
JARS=$APP/eso/hmi/lsd/jars
JAR=$JARS/NavActiveIgnore-NAR-MU1126.jar
JAR_NAME=NavActiveIgnore-NAR-MU1126.jar
STAGE=$APP/.vwg13-map-stage-$$
OLD=$APP/.vwg13-map-old-$$
say(){ echo "[mhi2-nar-vwg13] $*"; }
fail(){ say "INSTALL_FAIL $*"; exit 1; }
fsize(){ [ -f "$1" ] || return 1; wc -c < "$1" 2>/dev/null | awk '{print $1;ok=1}END{exit !ok}'; }
need(){ got=`fsize "$1"` || fail "missing $1"; [ "$got" = "$2" ] || fail "size mismatch $1: got $got expected $2"; }

[ -n "$PAYLOAD" ] && [ -d "$PAYLOAD" ] || fail 'payload directory argument required'
[ -d "$APP/eso" ] || fail 'not an MHI2 app filesystem'
train=''
for f in "$PERSIST/SWDL/CachedTrain.txt" "$APP/../efs-persist/SWDL/CachedTrain.txt"; do
  if [ -f "$f" ]; then read -r train < "$f"; break; fi
done
[ "$train" = MHI2_US_VWG13_P3659_2 ] || fail "train mismatch: ${train:-unknown}"
need "$IFSROOT/lsd.jxe" 54248171
need "$APP/armle/lib/dll/ipod-drvr-iap2.so" 739925
need "$APP/armle/lib/libnvss_video.so" 73304

UPDATING=0
if [ -d "$ROOT" ]; then
  [ -f "$ROOT/PROFILE" ] && [ "`cat "$ROOT/PROFILE"`" = MU1126/791 ] || fail 'foreign carplaymaps installation present'
  [ -f "$ROOT/stock_first/dio_manager.real" ] || fail 'installed stock dio backup missing'
  [ -f "$ROOT/rollback/lsd.sh" ] || fail 'installed stock lsd backup missing'
  STOCK_DIO=$ROOT/stock_first/dio_manager.real
  STOCK_LSD=$ROOT/rollback/lsd.sh
  UPDATING=1
else
  need "$DIO" 655359
  need "$LSD" 15909
  [ ! -e "$JAR" ] || fail "$JAR already exists"
  STOCK_DIO=$DIO
  STOCK_LSD=$LSD
fi

for f in core.so dio_manager.wrapper.sh altscreen-most-bridge carplay-cluster-supervisor cpvc-mirror-canvas libcarplay-security-bridge.so libcpvc-dmdt-query.so libcpvc-mirror-tap.so NavActiveIgnore-NAR-MU1126.jar security_bridge/carplay-pairing-helper security_bridge/libCarPlayPairingCore.so; do
  [ -s "$PAYLOAD/$f" ] || fail "payload missing $f"
done
rm -rf "$STAGE" "$OLD" 2>/dev/null
mkdir -p "$STAGE/stock_first" "$STAGE/rollback" "$STAGE/security_bridge" || fail 'stage create'
cp "$STOCK_DIO" "$STAGE/stock_first/dio_manager.real" || fail 'stock dio backup'
cp "$STOCK_LSD" "$STAGE/rollback/lsd.sh" || fail 'stock lsd backup'
for f in core.so dio_manager.wrapper.sh altscreen-most-bridge carplay-cluster-supervisor cpvc-mirror-canvas libcarplay-security-bridge.so libcpvc-dmdt-query.so libcpvc-mirror-tap.so; do cp "$PAYLOAD/$f" "$STAGE/$f" || fail "copy $f"; done
cp "$PAYLOAD/security_bridge/carplay-pairing-helper" "$STAGE/security_bridge/" || fail 'copy pairing helper'
cp "$PAYLOAD/security_bridge/libCarPlayPairingCore.so" "$STAGE/security_bridge/" || fail 'copy pairing core'
echo MU1126/791 > "$STAGE/PROFILE" || fail 'profile write'
touch "$STAGE/CLUSTER_AUTO_ENABLE" || fail 'auto-enable marker'
chmod 755 "$STAGE/dio_manager.wrapper.sh" "$STAGE/altscreen-most-bridge" "$STAGE/carplay-cluster-supervisor" "$STAGE/cpvc-mirror-canvas" "$STAGE/security_bridge/carplay-pairing-helper" "$STAGE/stock_first/dio_manager.real" || fail 'payload chmod'

awk -v jar="$JAR_NAME" '
  index($0,jar) { next }
  !done && $0 ~ /^[ \t]*\$J9[ \t]/ { print "BOOTCLASSPATH=\"$BOOTCLASSPATH -Xbootclasspath/p:$BASE_DIR/lsd/jars/" jar "\""; done=1 }
  { print }
  END { if (!done) exit 9 }
' "$STOCK_LSD" > "$STAGE/lsd.sh.patched" || fail 'unsupported lsd.sh structure'
chmod 755 "$STAGE/lsd.sh.patched"

cp "$PAYLOAD/NavActiveIgnore-NAR-MU1126.jar" "$JAR.new" || fail 'stage NAI jar'
cp "$STAGE/lsd.sh.patched" "$LSD.new" || { rm -f "$JAR.new"; fail 'stage lsd.sh'; }
cp "$STAGE/dio_manager.wrapper.sh" "$DIO.new" || { rm -f "$JAR.new" "$LSD.new"; fail 'stage dio wrapper'; }
chmod 644 "$JAR.new"; chmod 755 "$LSD.new" "$DIO.new"

rollback(){
  RBROOT=$ROOT
  [ -f "$RBROOT/stock_first/dio_manager.real" ] || RBROOT=$OLD
  cp "$RBROOT/stock_first/dio_manager.real" "$DIO" 2>/dev/null || true
  cp "$RBROOT/rollback/lsd.sh" "$LSD" 2>/dev/null || true
  [ "$UPDATING" = 1 ] || rm -f "$JAR" 2>/dev/null
  rm -f "$JAR.new" "$LSD.new" "$DIO.new" 2>/dev/null
  rm -rf "$ROOT" 2>/dev/null
  [ -d "$OLD" ] && mv "$OLD" "$ROOT" 2>/dev/null
}
trip(){ [ "${VWG13_FAIL_AT:-}" != "$1" ] || { rollback; fail "injected failure at $1"; }; }
[ "$UPDATING" = 0 ] || mv "$ROOT" "$OLD" || { rm -f "$JAR.new" "$LSD.new" "$DIO.new"; fail 'move old install'; }
trip old_moved
mv "$STAGE" "$ROOT" || { [ -d "$OLD" ] && mv "$OLD" "$ROOT"; fail 'activate root'; }
trip root_active
mv "$JAR.new" "$JAR" || { rollback; fail 'activate NAI jar'; }
trip jar_active
mv "$LSD.new" "$LSD" || { rollback; fail 'activate lsd.sh'; }
trip lsd_active
mv "$DIO.new" "$DIO" || { rollback; fail 'activate dio wrapper'; }
trip dio_active

[ -s "$ROOT/core.so" ] && [ -s "$ROOT/stock_first/dio_manager.real" ] || { rollback; fail 'post-install payload check'; }
grep -q "$JAR_NAME" "$LSD" || { rollback; fail 'post-install classpath check'; }
[ "`cat "$ROOT/PROFILE"`" = MU1126/791 ] || { rollback; fail 'post-install profile check'; }
rm -rf "$OLD" 2>/dev/null
sync 2>/dev/null || true
say 'INSTALL_OK reboot required; map video + NAR-derived NavActiveIgnore enabled'
