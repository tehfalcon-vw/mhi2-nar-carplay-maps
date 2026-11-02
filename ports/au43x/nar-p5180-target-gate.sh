#!/bin/sh
# Exact preflight for Audi TT MHI2_US_AU43x_P5180 / MU1462.
set -u
APP=${AU43_P5180_APP:-/mnt/app}
SYS=${AU43_P5180_SYS:-/mnt/system}
IFSROOT=${AU43_P5180_IFS:-/ifs}
say(){ echo "[mhi2-nar-au43x-p5180] $*"; }
fail(){ say "ERROR $*"; exit 1; }
fsize(){ [ -f "$1" ] || return 1; wc -c < "$1" 2>/dev/null | awk '{print $1;ok=1}END{exit !ok}'; }
need(){ got=`fsize "$1"` || fail "missing $1"; [ "$got" = "$2" ] || fail "size mismatch $1: got $got expected $2"; }

[ "${PDC:-0}" = 0 ] || fail 'PDC is not qualified on AU43x P5180; unset PDC or set PDC=0'
vp=$APP/eso/hmi/version.properties
[ -f "$vp" ] || fail "missing $vp"
hv=`awk -F: '/^HMI_Version/{gsub(/[ \t\r]/,"",$2);print $2;exit}' "$vp"`
[ "$hv" = HMI_AU_MIB2_H_NAR_G24_C10_200600 ] || fail "HMI mismatch: $hv"

need "$APP/armle/lib/dll/ipod-drvr-iap2.so" 740261
need "$APP/armle/lib/libnvss_video.so" 73302
need "$APP/armle/usr/lib/libiap2client.so.1" 18613
need "$APP/armle/usr/sbin/mm-ipod" 40297
need "$APP/eso/bin/apps/dio_manager" 694717
need "$APP/eso/hmi/lsd/lsd.sh" 15056
need "$SYS/etc/usblauncher_otg.lua" 21614
need "$SYS/etc/eso/production/smartphone_integrator.json" 7397
need "$SYS/etc/mm/iap2.cfg" 6018
grep -q 'storage,splash=' "$SYS/etc/usblauncher_otg.lua" || fail 'NAR storage launcher feature missing'
grep -q 'model=CLU10_MMX2_AU_NAR_G24_004PROD' "$SYS/etc/mm/iap2.cfg" || fail 'NAR iAP2 model mismatch'

lsdjxe=$IFSROOT/lsd.jxe
[ -f "$lsdjxe" ] || lsdjxe=${AU43_P5180_LSD_JXE:-/net/mmx/ifs/lsd.jxe}
if [ -f "$lsdjxe" ]; then need "$lsdjxe" 60679081; else fail 'lsd.jxe is not readable'; fi
say 'TARGET_GATE=PASS MHI2_US_AU43x_P5180 MU1462 PDC=OFF'

[ "${AU43_P5180_CHECK_ONLY:-0}" = 1 ] && exit 0
[ $# -ge 1 ] || fail 'patched pinned donor install.sh path required'
donor=$1; shift
[ -f "$donor" ] || fail "donor installer missing: $donor"
exec sh "$donor" "$@"
