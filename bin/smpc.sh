#!/bin/bash
opt=$@
mpc $opt &> /dev/null 
title="`mpc --format \"[[%artist%  - ]%title%]\" | head -n 1`"
status="`mpc | head -n 2 | tail -n 1`"
volume="`mpc | tail -n 1`"
message="$title -- $status -- $volume" 
echo $message
(echo $message; sleep 2) | dzen2 -u

