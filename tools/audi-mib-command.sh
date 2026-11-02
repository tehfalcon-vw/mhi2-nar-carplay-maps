#!/bin/sh
case $0 in */*) DIR=${0%/*} ;; *) DIR=. ;; esac
exec sh "$DIR/custom.sh"
