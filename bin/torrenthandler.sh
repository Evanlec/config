#!/bin/sh

mv "$1" /home/el/download/watch/

wchat_screen=`screen -ls | grep weechat`

if [[ -n "$wchat_screen" ]]
then
  urxvtc -e screen -d -X screen rtorrent
else
  urxvtc -e screen -S weechat weechat-curses 
  sleep 1
  screen -d -X screen rtorrent
fi

exit 0
