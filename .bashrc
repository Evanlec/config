# If not running interactively, don't do anything
if [ -z "$PS1" ]; then
	return
fi

#load colors
source $HOME/.bash/colors

export PS1="\[$txtblu\]\u@\h \[\033[36m\]\W \$: \[\033[00m\]"

# stop wine making file associations
export WINEDLLOVERRIDES='winemenubuilder.exe=d'

# set options
shopt -s autocd
shopt -s cdspell
shopt -s extglob

#environment variables
#export TERM="rxvt-unicode"
export EDITOR="vim"
export BROWSER="google-chrome"
export PAGER="less"
export GREP_OPTIONS='--color=auto' 
export GREP_COLOR='1;32'


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
source $HOME/.aliasrc

if [ -z "$HOST" ] ; then
	export HOST=${HOSTNAME}
fi

HISTIGNORE="[   ]*:&:bg:fg"


#adds some nice version-control stuff to prompt
vcprompt() {
    /usr/bin/vcprompt -f $' on \033[34m%n\033[00m:\033[00m%[unknown]b\033[32m%m%u'
}

sprunge() {
   URI=$(curl -s -F "sprunge=<-" http://sprunge.us)
   # if stdout is not a tty, suppress trailing newline
   if [[ ! -t 1 ]] ; then local FLAGS='-n' ; fi
   echo $FLAGS $URI
}



svdiff()
{
    EDITOR=vimdiff
    sudoedit $1 $2
}

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

function gr
{
    if [[ -z "$1" ]]; then
      echo "Usage: gr <string> [path]"
    elif [[ -z "$2" ]]; then
      grep -rn --color=always "$1" .
    else
      grep -rn --color=always "$1" $2
    fi
}

# go to google for a definition
define() {
  local LNG=$(echo $LANG | cut -d '_' -f 1)
  local CHARSET=$(echo $LANG | cut -d '.' -f 2)
  lynx -accept_all_cookies -dump -hiddenlinks=ignore -nonumbers -assume_charset="$CHARSET" -display_charset="$CHARSET" "http://www.google.com/search?hl=${LNG}&q=define%3A+${1}&btnG=Google+Search" | grep -m 5 -C 2 -A 5 -w "*" > /tmp/deleteme
  if [ ! -s /tmp/deleteme ]; then
    echo "Sorry, google doesn't know this one..."
  else
    cat /tmp/deleteme | grep -v Search
    echo ""
  fi
  rm -f /tmp/deleteme
}

extract () {
    local old_dirs current_dirs lower
    lower=${(L)1}
    old_dirs=( *(N/) )
    if [[ $lower == *.tar.gz || $lower == *.tgz ]]; then
        tar xvzf $1
    elif [[ $lower == *.gz ]]; then
        gunzip $1
    elif [[ $lower == *.tar.bz2 || $lower == *.tbz ]]; then
        tar xvjf $1
    elif [[ $lower == *.bz2 ]]; then
        bunzip2 $1
    elif [[ $lower == *.zip ]]; then
        unzip $1
    elif [[ $lower == *.rar ]]; then
        unrar e $1
    elif [[ $lower == *.tar ]]; then
        tar xvf $1
    elif [[ $lower == *.lha ]]; then
        lha e $1
    else
        print "Unknown archive type: $1"
        return 1
    fi
    # Change in to the newly created directory, and
    # list the directory contents, if there is one.
    current_dirs=( *(N/) )
    for i in {1..${#current_dirs}}; do
        if [[ $current_dirs[$i] != $old_dirs[$i] ]]; then
            cd $current_dirs[$i]
            break
        fi
    done
}

roll () {
    FILE=$1
    case $FILE in
        *.tar.bz2) shift && tar cjf $FILE $* ;;
        *.tar.gz) shift && tar czf $FILE $* ;;
        *.tgz) shift && tar czf $FILE $* ;;
        *.zip) shift && zip $FILE $* ;;
        *.rar) shift && rar $FILE $* ;;
    esac
}

function calc() { echo "$*" | bc; }

function mktar() { 
    if [ ! -z "$1" ]; then
        tar czf "${1%%/}.tar.gz" "${1%%/}/"; 
    else
        echo "Please specify a file or directory"
        return 1
    fi
}

function mkmine() { sudo chown -R ${USER} ${1:-.}; }

# sanitize - set file/directory owner and permissions to normal values (644/755)
# Usage: sanitize <file>
sanitize() {
    chmod -R u=rwX,go=rX "$@"
    chown -R ${USER}.users "$@"
}

upload() {

  if [[ -f $1 ]]; then
    echo "Uploading $1 to el@slice:/var/www/lets-talk.org/html/upload/$1"
    scp -P 50100 $1 el@slice:/var/www/lets-talk.org/html/upload/$1
    echo "http://lets-talk.org/upload/$1" | xclip
    xclip -o
    return $?
  elif [[ -d $1 ]]; then
    1=$(cd $1 &> /dev/null && pwd)
    echo "Copying ${1} to el@slice:${2:=$1}"
    scp -P 50100 -r $1 el@slice:${2}
    return $?
  else
    echo "Please specify a file or directory"
    return 1
  fi
}

cptoslice() {
  if [[ -f $1 ]]; then
    local=$(cd "$(dirname "$1")" 2>/dev/null && pwd)/$(basename "$1")
    remote="$local"
    echo "Copying $local to el@slice:$remote"
    scp -C -P 50100 "$local" el@slice:"$remote"
    return $?
  elif [[ -d $1 ]]; then
    local=$(cd "$(dirname $1)" 2>/dev/null && pwd)/$(basename "$1")
    remote="$local"
    echo "Copying $local to el@slice:$remote"
    scp -C -P 50100 -r "$local" el@slice:"$remote"
    return $?
  else
    echo "Please specify a file or directory"
    return 1
  fi
}

cptocloud() {
  if [[ -f $1 ]]; then
    local=$(cd "$(dirname "$1")" 2>/dev/null && pwd)/$(basename "$1")
    remote="$local"
    echo "Copying $local to el@cloud:$remote"
    scp -C -P 50100 "$local" el@cloud:"$remote"
    return $?
  elif [[ -d $1 ]]; then
    local=$(cd "$(dirname $1)" 2>/dev/null && pwd)/$(basename "$1")
    remote="$local"
    echo "Copying $local to el@cloud:$remote"
    scp -C -P 50100 -r "$local" el@cloud:"$remote"
    return $?
  else
    echo "Please specify a file or directory"
    return 1
  fi
}

cptohome() {
  if [[ -f $1 ]]; then
    local=$(cd "$(dirname "$1")" 2>/dev/null && pwd)/$(basename "$1")
    remote="$local"
    echo "Copying $local to el@elecompte.com:$remote"
    scp -C -P 50100 "$local" el@elecompte.com:"$remote"
    return $?
  elif [[ -d $1 ]]; then
    local=$(cd "$(dirname $1)" 2>/dev/null && pwd)/$(basename "$1")
    remote="$local"
    echo "Copying $local to el@elecompte.com:$remote"
    scp -C -P 50100 -r "$local" el@elecompte.com:"$remote"
    return $?
  else
    echo "Please specify a file or directory"
    return 1
  fi
}


join_avi() {
  mencoder -forceidx -oac copy -ovc copy $1 -o $2
}
