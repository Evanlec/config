#!/usr/bin/env bash
 
#Logs to watch
logs='/var/log/kernel.log '
logs="$logs /var/log/syslog.log"
logs="$logs /var/log/dmesg.log"
 
#Urgency
infoUrgency='low'
warningUrgency='normal'
errorUrgency='critical'
securityUrgency='critical'
 
#Popup time
infoPopupTime=5000
warningPopupTime=8000
errorPopupTime=11000
securityPopupTime=11000
 
#Icons
infoIcon='/usr/share/icons/gnome/32x32/status/dialog-information.png'
warningIcon='/usr/share/icons/gnome/32x32/status/dialog-warning.png'
errorIcon='/usr/share/icons/gnome/32x32/status/dialog-error.png'
securityIcon='/usr/share/icons/gnome/32x32/status/security-medium.png'

while [ 1 ]
do
    logModify=`inotifywait -e modify $logs --format %w`
    notification=`tail -n 1 $logModify`
    # you might want to modify this
    colored_notification=`echo $notification | source-highlight --failsafe --src-lang=log --style-file=default.style --outlang-def=/usr/share/awesome/themes/evanlec/awesome.outlang`
    
    if [[ $notification!='' ]]; then
    
        if [[ `echo $logModify|grep info` ]]; then messageType='info'; fi        
        if [[ `echo $logModify|grep warn` ]]; then messageType='warning'; fi        
        if [[ `echo $logModify|grep err` ]]; then messageType='error'; fi
        if [[ `echo $logModify|grep auth` ]]; then messageType='security'; fi
        if [[ `echo $logModify|grep access` ]]; then messageType='security'; fi
        if [[ `echo $notification|grep 'UFW BLOCK INPUT'` ]]; then messageType='security'; fi
        if [[ $messageType == '' ]]; then messageType='info'; fi
        
        case $messageType in
        info)
            urgency=$infoUrgency
            icon=$infoIcon
            popupTime=$infoPopupTime
        ;;
        warning)
            urgency=$warningUrgency
            icon=$warningIcon
            popupTime=$warningPopupTime
        ;;
        error)
            urgency=$errorUrgency
            icon=$errorIcon            
            popupTime=$errorPopupTime
        ;;
        security)
            urgency=$securityUrgency
            icon=$securityIcon        
            popupTime=$securityPopupTime
        ;;
        esac
 
        notify-send -u $urgency -t $popupTime -i "$icon" "$logModify" "$colored_notification"
#       if naughty is not enabled to understand dbus, you can also do that (but you'll have to modify the popupTimes - divide them by 1000)
#        echo "naughty.notify({ title = '$logmodify', text='$colored_notification', timeout = $popupTime})" | awesome-client
 
        messageType=''
 
    fi
done

