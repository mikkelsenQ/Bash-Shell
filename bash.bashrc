# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
#    ;;
#esac

# enable bash completion in interactive shells
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
        function command_not_found_handle {
                # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
                   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
                   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
                else
                   printf "%s: command not found\n" "$1" >&2
                   return 127
                fi
        }
fi

# ALIASES AND FUNCTIONS


## General


# A hack for reversing the default flow of the terminal prompt.
alias c='clear; for i in range{1..50}; do echo ; done'
alias e='exit'
alias j='jobs'
alias ftn='fortune'
alias rm='rm -iv'  # -i: Prompt before removing. -v:verbose. Explains what's it doing. 
# TODO Make it output pretty colors (cyan?).
alias ls='ls --color=auto'  # Defaults ls to colorised output. 
#alias rm='rm -v'  # -v:verbose. Explains what's it doing. 
alias grep='grep -i'  # Case insensitive as default.
# Case insensitive, unlimited depth 'find' command. 
# http://unix.stackexchange.com/questions/32155/find-command-how-to-ignore-case
alias seek='find . -mindepth 0 -iname'

# Wifi device on/off. "wf on" "wf off"
wf() {
    nmcli r wifi $1
}

k() {
    kill %$1
}

# Kill all processes by name.
# Usage: "kal <process to be killed's name>" e.g. "kal kate"
kal() {
    killall $1
}

# Stops all running jobs.
alias kj='kill -s stop %?'


## Updating

# TODO Make it the same function, making 'dist-upgrade' a particular case.
update() {
apt-get update
apt-get upgrade
}

d-update() {
apt-get update
apt-get dist-upgrade
}


## Clean & sleek 


# General cleaning
tidy() {
apt-get autoremove && 
apt-get autoclean && 
apt-get remove && 
apt-get clean &
}

# Remove orphaned packages. Logs them prior to removal, just in case something breaks.
# TODO: Wouldn't be better to have a single logfile and append to it on each run? Ask around. 
orphan() {
DIR="/media/01/01-Notes/Logs/"
A="$(deborphan)"  # We evaluate packages to be purged. 
aptitude purge ${A}  # Try to purge said packages
B="$(deborphan)"  # Evaluate again to see if purged successfully. 

if [ "$A" == "$B" ]; then
    :  # Do nothing. 
else
    echo 'Packages have been purged. Writing list to logfile.'
    echo "${A}" > "$DIR"PurgedPackages-$(date +"20%y-%m%b-%d%h-%H%M%S").txt  # List purged packages.
fi  # I forgot about closing the IF statement!
}

# Lists the 150 heavier files and directories and stores them in a file. 
# Takes one argument, size of the 'counting unit'. e.g. '100' The 'unit' will 
# be '100 MB'.
heavy() {
du -ah --block-size=$1M . | sort -n -r | head -n 150 > HeavyFiles-$(date +"20%y-%m%b-%d%h-%H%M%S").txt &
}


## Finance

# Returns stock price, given its ticker from the Amsterdam Euronext. 
# TODO Allow to specify other markets while defaulting to .as (Amsterdam Euronext).
# i.e. If there's no argument, make the second argument ".as"
# Usage: "sp <ticker>" e.g. "sp iwda" (iwda = MSCI Developed World - iShares Blackrock)
sp() {
    stock="$(echo $1 | tr '[:lower:]' '[:upper:]')"
    echo "Price of" $stock":" "$(curl -s 'http://download.finance.yahoo.com/d/quotes.csv?s='"$stock"'.as&f=l1')"
}

# Updates information after purchasing shares, so conky displays updated information.  
alias bh='python /media/01/06-KoEC/Programming/python/OwnProjects/InvestmentTools/SharesNetWorth/snw.py'


## Secure shell 

# Removed for upload to github


## Python

# Removed for upload to github


## Miscellaneous


# PDF compressor by Ghostscript
# Usage: "shrinkpdf <input.pdf> <output.pdf>"
# TODO Rewrite as a function so only input is needed. Output will be the filename plus '-lite'. 
alias shrinkpdf='/media/01/06-KoEC/scripts/shrinkpdf.sh'

# Wake Up function. Beeps after specified time. 
# Usage: "wu <specified time>" e.g. "wu 3m"
wu() {
    sleep "$1" && beep -r 3 &
}

gimme() {
# Downloads the file given its url as argument.
# Usage: "gimme <url to file>" "gimme http://www.website.org/filetodownload.pdf"
curl -C - -L -O $1 &
}

# Pomodoro technique timer. Used instead of 'wu' to avoid confusion. 
# TODO: Make this a particular case of 'wu' by passing an argument. 
pmdr() {
    sleep 25m &&
    beep -r 3 &&
    echo 'Pomodoro break!' &
}

navi() {
# Beeps every N minutes in order to keep track of time's flow. 
# The aim is to promote mindfulness, self-awareness, and hinder procrastination. 
# TODO: Could the beep become 'transparent' if you get used to it?. 
# If so, make the frequency a random number to avoid this effect. 
while true
do
    sleep 3m
    beep -f 4000
done &
}

# Wallpaper slideshow
 alias wss='nohup feh --recursive --randomize --auto-zoom --slideshow-delay 1200 --geometry 1366x768 /media/01/03-Imgs/Wall/Favourites/'


## Power


alias sdown='systemctl poweroff'  # Like shutdown. Available without root. 
alias rboot='systemctl reboot'  # Like reboot. Available without root. 

s2d() {
qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock && # Locks screen. 
# https://wiki.archlinux.org/index.php/NetworkManager#Command_line
systemctl hibernate && # Suspends to disk.
sleep 1s && :; sleep 1s &&

# Try to turn WiFi on until success.  
until [[ $(nmcli dev | grep connected) ]]; do
    nmcli r wifi on  # Try to turn the WiFi on.
    sleep 1s
done &&
sleep 4m
robokureru &  # Runs robokureru upon resuming. 
}

s2r() {
qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock &&  # Locks screen. 
# https://wiki.archlinux.org/index.php/NetworkManager#Command_line
systemctl suspend &&  # Suspends to RAM
sleep 1s && :; sleep 1s &&

# Try to turn WiFi on until success.  
until [[ $(nmcli dev | grep connected) ]]; do
    nmcli r wifi on  # Try to turn the WiFi on.
    sleep 1s
done &&
#echo ''
sleep 5m
robokureru &  # Runs robokureru upon resuming. 
}

alias s2r='s2r &'  # Executes everything in the background. 

s2ru() { 
# https://wiki.archlinux.org/index.php/NetworkManager#Command_line
systemctl suspend && # Suspends to RAM
sleep 1s && :; sleep 1s &&

# Try to turn WiFi on until success.  
until [[ $(nmcli dev | grep connected) ]]; do
    nmcli r wifi on  # Try to turn the WiFi on.
    sleep 1s
done &&
#echo ''
sleep 5m
robokureru &  # Runs robokureru upon resuming. 
}

alias s2ru='s2ru &'  # Executes everything in the background. 


## Back ups


bckpfunction() {

# http://stackoverflow.com/questions/1521462/looping-through-the-content-of-a-file-in-bash
# Two nested while loops copy everything from the origins (p) to the back up destinations (q).
# NOTE Make sure to append a newline at the end of both text files or it will skip the last directory. 
# TODO Make it ignore the line if it starts with '#' so we can add comments about the directories to be backed up.

while read q; do
  #echo $q

    while read p; do
        #echo $p
        rsync -avzP --delete $p $q
    done <.backup-directories.txt
  
done <.backup-destinations.txt

}
