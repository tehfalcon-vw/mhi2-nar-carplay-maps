#!/bin/sh
# Keep LD_PRELOAD scoped to mm-ipod. Missing/disabled payload falls back to stock.
LIB=/mnt/app/root/hooks/libmhi2-nar-au57x-rgi-ipod.so
DRV=/mnt/app/armle/lib/dll/ipod-drvr-iap2.so
if [ -f "$LIB" ] && [ ! -f /mnt/app/root/hooks/DISABLE ] && \
   [ "`wc -c < "$DRV" 2>/dev/null`" = 739925 ]; then
  if [ -n "${LD_PRELOAD:-}" ]; then LD_PRELOAD="$LIB:$LD_PRELOAD"; else LD_PRELOAD="$LIB"; fi
  export LD_PRELOAD
fi
exec /mnt/app/armle/usr/sbin/mm-ipod "$@"
