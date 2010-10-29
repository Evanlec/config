PS1='\[\033[37m\]\u@\h \[\033[36m\]\W \$: \[\033[00m\]'

if [ -z "$PS1" ]; then
	return
fi
# stop wine making file associations
export WINEDLLOVERRIDES='winemenubuilder.exe=d'

# set options
shopt -s autocd
shopt -s cdspell
shopt -s extglob

#environment variables
export TERM="rxvt-unicode"
export EDITOR="vim"
export BROWSER="google-chrome"

# bogus
if [ -f /unix ] ; then	
	alias ls='/bin/ls -CF'
else
	alias ls='/bin/ls -F'
fi

# burn it {{{
#
# burns an iso to disc
burn_iso() {
  local iso="$1"

  [ -e "$iso" ] || errorout "$1 does not exist"

  # removed hal-device
  # sets $type as CD/DVD
  #check_disc_type
  type="${type:-DVD}"
  # removed hal-device

  logger 'burning iso...'
  case "$type" in
    CD)  cdrecord -v speed=48 dev=$dev "$iso" 2>/dev/null ;;
    DVD) growisofs -dvd-compat -Z $dev="$iso" 2>/dev/null ;;
  esac

  ret=$?

  # wait, eject, and exit
  sleep 5 && eject "$dev"
  exit $ret
}

# }}}


# load my aliases
source /home/el/.aliasrc

if [ -z "$HOST" ] ; then
	export HOST=${HOSTNAME}
fi

HISTIGNORE="[   ]*:&:bg:fg"

psgrep()
{
	ps -aux | grep $1 | grep -v grep
}

#
# This is a little like `zap' from Kernighan and Pike
#

pskill()
{
	local pid

	pid=$(ps -ax | grep $1 | grep -v grep | awk '{ print $1 }')
	echo -n "killing $1 (process $pid)..."
	kill -9 $pid
	echo "slaughtered."
}


# prompt with color
#source $HOME/.bashprompt

term()
{
        TERM=$1
	export TERM
	tset
}

xtitle () 
{ 
	echo -n -e "\033]0;$*\007"
}

cd() {
    if [ $# -ne 1 ]; then builtin cd;
    else
        if [ -f $1 ]; then
            builtin cd $(dirname $1)
            $EDITOR $(basename $1)
       else
            builtin cd $1
        fi
    fi
}

bold()
{
	tput smso
}

unbold()
{
	tput rmso
}

if [ -f /unix ] ; then
clear()
{
	tput clear
}
fi

rot13()
{
	if [ $# = 0 ] ; then
		tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
	else
		tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
	fi
}

watch()
{
        if [ $# -ne 1 ] ; then
                tail -f nohup.out
        else
                tail -f $1
        fi
}

#
#       Remote login passing all 8 bits (so meta key will work)
#
rl()
{
        rlogin $* -8
}

function setenv()
{
	if [ $# -ne 2 ] ; then
		echo "setenv: Too few arguments"
	else
		export $1="$2"
	fi
}

function chmog()
{
	if [ $# -ne 4 ] ; then
		echo "usage: chmog mode owner group file"
		return 1
	else
		chmod $1 $4
		chown $2 $4
		chgrp $3 $4
	fi
}
