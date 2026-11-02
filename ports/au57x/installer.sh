#!/bin/sh
# Offline-qualified hybrid installer for Audi AU57x NAR K3341_1 / MU1426.
# Usage: sh installer.sh install|rollback|status [payload-directory]
set -u

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/mnt/app/armle/bin:/mnt/app/armle/usr/bin:$PATH
APP=${AU57_APP:-/mnt/app}
SYS=${AU57_SYS:-/mnt/system}
IFSROOT=${AU57_IFS:-/ifs}
PAY=${2:-${0%/*}/payload}
BK=$APP/root/mhi2-nar-au57x-backup
TX=0

say(){ echo "[mhi2-nar-au57x] $*"; }
fail(){ say "ERROR $*"; exit 1; }
fsize(){ [ -f "$1" ] || return 1; wc -c < "$1" 2>/dev/null | awk '{print $1; ok=1} END{exit !ok}'; }

# Files are deliberately enumerated so backup/rollback cannot silently omit one.
NAMES='altscreen renderer control profile viewareas rgi launcher jar bundles lsd lua iap2 smartphone marker'
pathof(){ case "$1" in
  altscreen)  echo "$APP/root/hooks/libmhi2-nar-au57x-altscreen.so";;
  renderer)   echo "$APP/root/vc_render";;
  control)    echo "$APP/root/mib2high-lvds-control.sh";;
  profile)    echo "$APP/root/mib2high-lvds-profile.conf";;
  viewareas)  echo "$APP/root/mib2high-lvds-viewareas.conf";;
  rgi)        echo "$APP/root/hooks/libmhi2-nar-au57x-rgi-ipod.so";;
  launcher)   echo "$APP/root/hooks/mm-ipod-au57x-rgi.sh";;
  jar)        echo "$APP/eso/hmi/lsd/jars/mhi2-nar-au57x-rgi.jar";;
  bundles)    echo "$APP/eso/hmi/lsd/bundles_au57x_rgi.properties";;
  lsd)        echo "$APP/eso/hmi/lsd/lsd.sh";;
  lua)        echo "$SYS/etc/usblauncher_otg.lua";;
  iap2)       echo "$SYS/etc/mm/iap2.cfg";;
  smartphone) echo "$SYS/etc/eso/production/smartphone_integrator.json";;
  marker)     echo "$APP/carplay_altscreen";;
esac; }
payloadof(){ case "$1" in
  altscreen) echo "$PAY/libmhi2-nar-au57x-altscreen.so";;
  renderer) echo "$PAY/vc_render";;
  control) echo "$PAY/mib2high-lvds-control.sh";;
  profile) echo "$PAY/mib2high-lvds-profile.conf";;
  viewareas) echo "$PAY/mib2high-lvds-viewareas.conf";;
  rgi) echo "$PAY/libmhi2-nar-au57x-rgi-ipod.so";;
  launcher) echo "$PAY/mm-ipod-au57x-rgi.sh";;
  jar) echo "$PAY/mhi2-nar-au57x-rgi.jar";;
esac; }
newmode(){ case "$1" in altscreen|renderer|control|rgi|launcher) echo 755;; *) echo 644;; esac; }

# QNX images do not consistently include stat(1); derive a safe ordinary mode.
modeof(){ ls -l "$1" | awk 'NR==1{p=substr($1,2,9);m="";for(i=0;i<3;i++){v=0
  if(substr(p,1+3*i,1)=="r")v+=4;if(substr(p,2+3*i,1)=="w")v+=2;x=substr(p,3+3*i,1)
  if(x=="x")v+=1;else if(x!="-")exit 7;m=m v}print m}'; }
rw(){ t="$1/.au57x-rw.$$"; ( : > "$t" ) 2>/dev/null && { rm -f "$t"; return 0; }
  mount -uw "$1" >/dev/null 2>&1; ( : > "$t" ) 2>/dev/null && { rm -f "$t"; return 0; }; return 1; }
put(){ puttmp="$2.au57x.$$"; cp "$1" "$puttmp" && chmod "$3" "$puttmp" && mv -f "$puttmp" "$2" || { rm -f "$puttmp"; return 1; }; }

backup(){ [ ! -e "$BK" ] || fail "backup already exists: $BK"
  mkdir -p "$BK" || return 1
  for n in $NAMES; do f=`pathof "$n"`
    if [ -f "$f" ]; then m=`modeof "$f"` && [ -n "$m" ] || return 1
      cp "$f" "$BK/$n" && echo "$m" > "$BK/$n.mode" || return 1
    elif [ -e "$f" ]; then say "unsupported existing file type: $f"; return 1
    else : > "$BK/$n.absent" || return 1; fi
  done
  : > "$BK/complete"; sync
}
restore(){ [ -f "$BK/complete" ] || { say "no complete backup in $BK"; return 1; }
  for n in $NAMES; do f=`pathof "$n"`
    if [ -f "$BK/$n.absent" ]; then rm -f "$f" || return 1
    else [ -f "$BK/$n" ] && [ -f "$BK/$n.mode" ] || return 1
      put "$BK/$n" "$f" "`cat "$BK/$n.mode"`" || return 1
    fi
  done
  sync
}
onexit(){ rc=$?; trap - 0
  if [ "$TX" -eq 1 ]; then
    say 'INSTALL FAILED: restoring originals'
    if restore; then say 'AUTO_ROLLBACK=PASS'; else say 'AUTO_ROLLBACK=FAIL: do not reboot'; fi
  fi
  exit "$rc"
}

gate_size(){ got=`fsize "$1"` || fail "target file missing: $1"; [ "$got" = "$2" ] || fail "VERSION_GATE size mismatch $1: got $got expected $2"; }
version_gate(){
  vp="$APP/eso/hmi/version.properties"
  [ -f "$vp" ] || fail "VERSION_GATE missing $vp"
  hv=`awk -F: '/^HMI_Version/{gsub(/[ \t\r]/,"",$2);print $2;exit}' "$vp"`
  [ "$hv" = 'HMI_AU_MIB2_H_NAR_G11_C6_184700' ] || fail "VERSION_GATE HMI mismatch: $hv"
  gate_size "$APP/armle/lib/dll/ipod-drvr-iap2.so" 739925
  gate_size "$APP/armle/usr/sbin/mm-ipod" 40297
  gate_size "`pathof lua`" 19907
  gate_size "`pathof iap2`" 5853
  gate_size "`pathof smartphone`" 6788
  gate_size "`pathof lsd`" 4125
  lsdjxe=$IFSROOT/lsd.jxe
  [ -f "$lsdjxe" ] || lsdjxe=${AU57_LSD_JXE:-/net/mmx/ifs/lsd.jxe}
  if [ -f "$lsdjxe" ]; then gate_size "$lsdjxe" 44051746; else say 'VERSION_GATE lsd.jxe unreadable; HMI and six stock-file gates still passed'; fi
  say 'VERSION_GATE=PASS'
}

patch_files(){ t="$1"; lsd=`pathof lsd`; lua=`pathof lua`; iap2=`pathof iap2`; sp=`pathof smartphone`; base="$APP/eso/hmi/lsd/bundles.properties"
  awk '/^on -p 12 \/ifs\/jre\/bin\/j9 /{n++
    print "# mhi2-nar-au57x begin"
    print "if [ -f /eso/hmi/lsd/jars/mhi2-nar-au57x-rgi.jar ] && [ -f /eso/hmi/lsd/bundles_au57x_rgi.properties ] && [ ! -f /eso/hmi/lsd/mhi2-nar-au57x.disable ]; then"
    print "  BOOTCLASSPATH=\"$BOOTCLASSPATH:/eso/hmi/lsd/jars/mhi2-nar-au57x-rgi.jar\""
    print "  VMOPTIONS=\"$VMOPTIONS -Dlsd.bundles=/eso/hmi/lsd/bundles_au57x_rgi.properties\""
    print "fi"
    print "# mhi2-nar-au57x end"}{print}END{if(n!=1)exit 7}' "$lsd" > "$t/lsd" || return 1
  awk '/^Bundle.Startup.Autostart[ \t]*=/{n++;$0=$0 ",K3663RGI"}{print}END{print "K3663RGI=org.mib2high.carplay.rgi.Activator";if(n!=1)exit 7}' "$base" > "$t/bundles" || return 1
  awk '/return "mm-ipod -d iap2,/{n++;sub(/return "mm-ipod /,"return \"sh /mnt/app/root/hooks/mm-ipod-au57x-rgi.sh ")}{print}END{if(n!=1)exit 7}' "$lua" > "$t/lua" || return 1
  if grep -q '^\[ident\]' "$iap2"; then return 1; fi
  { cat "$iap2"; echo; echo '[ident]'; echo 'recvmsgs=0x5201,0x5202,0x5204'; echo 'sendmsgs=0x5200,0x5203'; } > "$t/iap2" || return 1
  awk 'BEGIN{car=0;found=0;inserted=0;env=0}
    /^[[:space:]]*"carplay"[[:space:]]*:/{car=1;found++}
    car && /^[[:space:]]*"envs"[[:space:]]*:[[:space:]]*\[/{env=1;print;print "                \"LD_PRELOAD=/mnt/app/root/hooks/libmhi2-nar-au57x-altscreen.so\",";inserted++;next}
    env && /"LD_PRELOAD=/{next} env && /^[[:space:]]*\]/{env=0;car=0}{print}
    END{if(found!=1||inserted!=1)exit 7}' "$sp" > "$t/smartphone" || return 1
}

install(){
  version_gate
  for n in altscreen renderer control profile viewareas rgi launcher jar; do p=`payloadof "$n"`; [ -s "$p" ] || fail "payload missing: $p"; done
  for f in "$APP/eso/hmi/lsd/bundles.properties"; do [ -f "$f" ] || fail "stock file missing: $f"; done
  grep -q mhi2-nar-au57x "`pathof lsd`" && fail 'already patched or ambiguous lsd.sh'
  grep -q mm-ipod-au57x "`pathof lua`" && fail 'already patched or ambiguous usblauncher'
  tmp=${AU57_TMP:-/tmp}/mhi2-nar-au57x.$$
  mkdir -p "$tmp" || fail 'cannot create work directory'
  patch_files "$tmp" || { rm -rf "$tmp"; fail 'stock config layout is not supported'; }
  rw "$APP" || fail "$APP is not writable"; rw "$SYS" || fail "$SYS is not writable"
  mkdir -p "$APP/root/hooks" "$APP/eso/hmi/lsd/jars" || fail 'cannot create target directories'
  backup || fail 'backup failed'
  cp "$0" "$BK/installer.sh" 2>/dev/null || true
  TX=1
  for n in altscreen renderer control profile viewareas rgi launcher jar; do put "`payloadof "$n"`" "`pathof "$n"`" "`newmode "$n"`" || fail "install failed: $n"; done
  put "$tmp/bundles" "`pathof bundles`" 644 || fail bundles
  put "$tmp/lsd" "`pathof lsd`" "`cat "$BK/lsd.mode"`" || fail lsd
  put "$tmp/lua" "`pathof lua`" "`cat "$BK/lua.mode"`" || fail lua
  put "$tmp/iap2" "`pathof iap2`" "`cat "$BK/iap2.mode"`" || fail iap2
  put "$tmp/smartphone" "`pathof smartphone`" "`cat "$BK/smartphone.mode"`" || fail smartphone
  : > "`pathof marker`" || fail marker
  [ "${AU57_FAIL_AFTER:-}" != 'writes' ] || fail 'injected post-write failure'
  sync; TX=0; rm -rf "$tmp"
  say 'INSTALL=PASS (offline-qualified; vehicle behavior not yet tested)'
  say 'Reboot the MMI, then test CarPlay Maps and collect logs before rollback.'
}
status(){ version_gate 2>/dev/null || true; for n in $NAMES; do f=`pathof "$n"`; [ -f "$f" ] && say "present $f" || say "absent  $f"; done; [ -f "$BK/complete" ] && say "backup complete: $BK" || say 'no backup'; }

trap onexit 0
case ${1:-} in
  install) install;;
  rollback) rw "$APP" && rw "$SYS" || fail 'filesystems not writable'; restore || fail 'restore failed: do not reboot'; mv "$BK" "$BK.done.$$" && sync; say 'ROLLBACK=PASS. Reboot the MMI.';;
  status) status;;
  *) echo "usage: sh $0 install|rollback|status [payload-directory]"; exit 2;;
esac
