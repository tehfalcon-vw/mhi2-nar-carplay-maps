#!/bin/sh
set -u
APP=${VWG13_APP:-/mnt/app}
ROOT=$APP/carplaymaps
DIO=$APP/eso/bin/apps/dio_manager
LSD=$APP/eso/hmi/lsd/lsd.sh
JAR=$APP/eso/hmi/lsd/jars/NavActiveIgnore-NAR-MU1126.jar
say(){ echo "[mhi2-nar-vwg13] $*"; }
fail(){ say "UNINSTALL_FAIL $*"; exit 1; }
[ -f "$ROOT/PROFILE" ] && [ "`cat "$ROOT/PROFILE"`" = MU1126/791 ] || fail 'qualified installation not found'
[ -s "$ROOT/stock_first/dio_manager.real" ] || fail 'stock dio backup missing'
[ -s "$ROOT/rollback/lsd.sh" ] || fail 'stock lsd backup missing'
cp "$ROOT/stock_first/dio_manager.real" "$DIO.restore" || fail 'stage dio restore'
cp "$ROOT/rollback/lsd.sh" "$LSD.restore" || { rm -f "$DIO.restore"; fail 'stage lsd restore'; }
chmod 755 "$DIO.restore" "$LSD.restore"
mv "$DIO.restore" "$DIO" || fail 'restore dio'
mv "$LSD.restore" "$LSD" || fail 'restore lsd'
rm -f "$JAR"
rm -rf "$ROOT"
sync 2>/dev/null || true
say 'UNINSTALL_OK reboot required'
