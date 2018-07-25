#!/bin/sh
cat /etc/os-release
echo "*** $@ ***"
exec $(eval echo "$@")
