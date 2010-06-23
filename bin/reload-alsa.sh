#!/bin/bash

LSOF=$(which lsof 2>/dev/null | sed 's|^[^/]*||' 2>/dev/null);
ALSACTL=$(which alsactl 2>/dev/null | sed 's|^[^/]*||' 2>/dev/null);

if [[ -z $LSOF ]]
then
echo "This script requires lsof. Please install it."
exit 0
fi

if [[ -z $ALSACTL ]]
then
echo "This script requires alsactl."
exit 0
fi

SNDMODULES=`lsmod |grep ^snd |awk {'print $1'}`
SNDAPPS=`lsof +c15 /dev/snd/* /dev/dsp*|awk {'print $1'}|grep -v COMMAND >/dev/null 2>&1`

echo "Saving mixer settings.."
alsactl store

echo "Closing ALL sound apps.."
for x in $SNDAPPS;do killall $x;sleep 0.2;done

echo "Unloading ALL sounds-related kernel modules.."
for y in $SNDMODULES; do rmmod $y; sleep 0.2;done

echo "Reloading sound-related kernel modules.."
for z in $SNDMODULES; do modprobe $z;sleep 0.2;done

echo "Loading mixer settings.."
alsactl restore
echo "Done."
