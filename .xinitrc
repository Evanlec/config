
xmodmap /home/el/.Xmodmap &

xmodmap -e "keycode 66 = Caps_Lock"
xmodmap -e "remove Lock = Caps_Lock"
xmodmap -e "keysym Caps_Lock = Escape"
#xmodmap -e "keycode 109 = Control_R"
#xmodmap -e "remove Control = Control_R"
#xmodmap -e "keysym Control_R = Caps_Lock"


#gnome-settings-daemon &
#feh --bg-scale /home/el/gfx/SteelMinimal.jpg & #*****set background******

#startxbindkeys &
#ulimit -c unlimited &
#xcompmgr -cC -r7 -o.65 -l-10 -t-8 &
#killall urxvtd &
#mpd
#zsh ./dzen/status.sh &


#urxvtc -g 80x30+0+0 &
#urxvtc -g 80x30+0+0 &
#weechat_screen &
nvclock -f -F auto -m 900 -n 600 -a flipping=0 -a quality=2 &

#nvidia-settings -a InitialPixmapPlacement=2 -a GlyphCache=1 
sudo nvidia-settings --load-config-only &

#trayer --expand true --widthtype request --height 16 --edge bottom --align left --transparent true --alpha 255 &
#tint2 &
#pypanel &
xset m 7/5 1 &
xset r rate 200 70 &
numlockx &
#iwconfig wlan0 rate 54M & # Fix wifi speed

#****Window Manager Selection****

#exec metacity --replace
#startfluxbox 
#exec openbox-session
#menu &
exec xsetroot -cursor_name left_ptr &
sh /home/el/bin/lognotify.sh &
exec awesome 
#gnome-panel &
#dbus-launch gnome-do &
#exec compiz ccp
#exec musca
#exec openbox
#exec gnome-session
