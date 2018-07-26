#!/bin/sh
test ! -e /app/Cuberite && test -e /app/Cuberite_debug && ln -s /app/Cuberite_debug /app/Cuberite
cat /etc/os-release
echo "*** $(eval echo "$@")  ***"
exec $(eval echo "$@")
