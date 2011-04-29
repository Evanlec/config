#!/bin/bash
# Status script for wmfs

red="\\#BF4D80\\"
yel="\\#A270A3\\"
blu="\\#477AB3\\"
grn="\\#53A6A6\\"
cyn="\\#6096BF\\"
mag="\\#7E62B3\\"
gry="\\#666666\\"
wht="\\#C0C0C0\\"

        # Collect system information 
#    chg=$(acpi -V | awk '{ gsub(/,/, "");} NR==1 {print $4}')
#    bat=$(grep -q "on-line" <(acpi -V) && echo $blu$chg || echo $red$chg)
# temp=$(sensors | grep 'CPU Temp' | grep -Eo \+[0-9][0-9])
    mem=$(awk '/Mem/ {print $3}' <(free -m))
        # CPU line courtesy Procyon: https://bbs.archlinux.org/viewtopic.php?pid=661592
    cpu=$(eval $(awk '/^cpu /{print "previdle=" $5 "; prevtotal=" $2+$3+$4+$5 }' /proc/stat); sleep 0.4; 
          eval $(awk '/^cpu /{print "idle=" $5 "; total=" $2+$3+$4+$5 }' /proc/stat); 
          intervaltotal=$((total-${prevtotal:-0})); 
          echo "$((100*( (intervaltotal) - ($idle-${previdle:-0}) ) / (intervaltotal) ))")

    hdd=$(awk '/^\/dev/{print $5}' <(df -P))
#    pac=$("$HOME/Scripts/pacman-up.pl")
    int=$(host google.com>/dev/null && echo $grn"ON" || echo $red"NO")
    dte=$(date "+%b%e %I:%M %p")

# Pipe to status bar
wmfs -s "[CPU $yel$cpu%$gry] [MEM $cyn$mem$gry] [HDD $mag$hdd$gry] [NET $int$gry] • $wht$dte"
