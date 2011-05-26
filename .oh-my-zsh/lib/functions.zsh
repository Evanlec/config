function zsh_stats() {
  history | awk '{print $2}' | sort | uniq -c | sort -rn | head
}

function uninstall_oh_my_zsh() {
  /bin/sh $ZSH/tools/uninstall.sh
}

function upgrade_oh_my_zsh() {
  /bin/sh $ZSH/tools/upgrade.sh
}

function take() {
  mkdir -p $1
  cd $1
}

function extract() {
    unset REMOVE_ARCHIVE
    
    if test "$1" = "-r"; then
        REMOVE=1
        shift
    fi
  if [[ -f $1 ]]; then
    case $1 in
      *.tar.bz2) tar xvjf $1;;
      *.tar.gz) tar xvzf $1;;
      *.tar.xz) tar xvJf $1;;
      *.tar.lzma) tar --lzma -xvf $1;;
      *.bz2) bunzip $1;;
      *.rar) unrar $1;;
      *.gz) gunzip $1;;
      *.tar) tar xvf $1;;
      *.tbz2) tar xvjf $1;;
      *.tgz) tar xvzf $1;;
      *.zip) unzip $1;;
      *.Z) uncompress $1;;
      *.7z) 7z x $1;;
      *) echo "'$1' cannot be extracted via >extract<";;
    esac

    if [[ $REMOVE_ARCHIVE -eq 1 ]]; then
        echo removing "$1";
        /bin/rm "$1";
    fi

  else
    echo "'$1' is not a valid file"
  fi
}

function tbt(){
  xfreerdp -u elecompte -p W3stside -g 1650x1040 -z -d tbtdomain.local --plugin cliprdr ${1:-tbtdomain.info:50200}
}

sprunge() {
   URI=$(curl -s -F "sprunge=<-" http://sprunge.us)
   # if stdout is not a tty, suppress trailing newline
   if [[ ! -t 1 ]] ; then local FLAGS='-n' ; fi
   echo $FLAGS $URI
   echo $URI | xclip -sel clipboard
   echo $URI | xclip -sel primary
}

pskill()
{
	local pid

	pid=$(ps -ax | grep $1 | grep -v grep | awk '{ print $1 }')
	echo -n "killing $1 (process $pid)..."
	kill -9 $pid
	echo "slaughtered."
}

watch()
{
        if [ $# -ne 1 ] ; then
                tail -f nohup.out
        else
                tail -f $1
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

upload() {

  if [[ -f $1 ]]; then
    echo "Uploading $1 to el@slice:/var/www/lets-talk.org/html/public/$1"
    scp -P 50100 $1 el@slice:/var/www/lets-talk.org/html/public/$1
    echo "http://lets-talk.org/public/$1" | xclip -selection clipboard
    echo "http://lets-talk.org/public/$1" | xclip -selection primary
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
