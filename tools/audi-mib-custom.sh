#!/bin/sh
set -u
echo "=== MHI2 NAR CarPlay Maps beta ==="
case $0 in */*) SELF_DIR=${0%/*} ;; *) SELF_DIR=. ;; esac
PAYLOAD=
for d in "$SELF_DIR/carplay" /fs/*/mod/carplay /mnt/*/mod/carplay /net/*/fs/*/mod/carplay; do
    if [ -f "$d/TARGET" ] && [ -f "$d/target-gate.sh" ]; then PAYLOAD=$d; break; fi
done
[ -n "$PAYLOAD" ] || { echo "ERROR: mod/carplay payload not found"; exit 1; }

if [ -f "$PAYLOAD/UNINSTALL" ]; then
    echo "UNINSTALL marker found"
    SRC_DIR="$PAYLOAD" sh "$PAYLOAD/uninstall.sh"
elif [ -f "$PAYLOAD/INSTALL" ]; then
    echo "INSTALL marker found"
    sh "$PAYLOAD/install-nar.sh"
else
    echo "No INSTALL marker: running the read-only target check"
    sh "$PAYLOAD/check-nar.sh"
fi
