#!/bin/sh
set -eu
case $0 in */*) DIR=${0%/*} ;; *) DIR=. ;; esac
[ -f "$DIR/TARGET" ] || { echo "ERROR: TARGET marker missing" >&2; exit 1; }
[ ! -f "$DIR/PDC" ] || { echo "ERROR: PDC is not supported by these NAR beta packages" >&2; exit 1; }
[ ! -f "$DIR/IGNORE_CONFLICTS" ] || { echo "ERROR: IGNORE_CONFLICTS is disabled for beta testing" >&2; exit 1; }
SRC_DIR="$DIR" PDC=0 IGNORE_CONFLICTS=0 exec sh "$DIR/target-gate.sh" "$DIR/install.sh"
