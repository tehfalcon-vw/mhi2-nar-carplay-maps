#!/bin/sh
set -eu
case $0 in */*) DIR=${0%/*} ;; *) DIR=. ;; esac
TARGET=$(cat "$DIR/TARGET" 2>/dev/null || true)
case "$TARGET" in
    au37x-p5107) AU37_CHECK_ONLY=1; export AU37_CHECK_ONLY ;;
    au43x-p5124) AU43_CHECK_ONLY=1; export AU43_CHECK_ONLY ;;
    au43x-p5180) AU43_P5180_CHECK_ONLY=1; export AU43_P5180_CHECK_ONLY ;;
    au62x-p5181) AU62_CHECK_ONLY=1; export AU62_CHECK_ONLY ;;
    *) echo "ERROR: missing or invalid TARGET marker" >&2; exit 1 ;;
esac
exec sh "$DIR/target-gate.sh"
