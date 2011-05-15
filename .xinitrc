
#xmodmap /home/el/.Xmodmap &

xmodmap -e "keycode 66 = Caps_Lock"
xmodmap -e "remove Lock = Caps_Lock"
xmodmap -e "keysym Caps_Lock = Escape"
#xmodmap -e "keycode 109 = Control_R"
#xmodmap -e "remove Control = Control_R"
#xmodmap -e "keysym Control_R = Caps_Lock"

xbindkeys &

# xcompmgr -cC -r7 -o.65 -l-10 -t-8 &


#urxvtc -g 80x30+0+0 &
#urxvtc -g 80x30+0+0 &
#weechat_screen &


#tint2 &
#pypanel &
xrdb -merge ~/.Xdefaults
xset m 7/5 1 &
xset r rate 250 70 &
numlockx &
# tilda &
urxvtd -q -o -f &

#****Window Manager Selection****

# exec awesome 
#exec compiz ccp
#exec musca
#exec openbox-session
#xset r rate 250 70 &
# exec startlxde
# exec ck-launch-session gnome-session
exec wmfs
