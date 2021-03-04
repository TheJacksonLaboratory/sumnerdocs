#!/bin/bash

## default .bash_aliases for Sumner Env
## https://github.com/TheJacksonLaboratory/linuxenv

alias cd..='cd ..'

alias df='df -H'
alias dir='dir --color=auto'

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias l='ls -CF'
alias l.='ls -d .* --color=auto'
alias la='ls -A'
alias ll='ls -alhF'
alias ls='ls --color=auto'
alias lt='ls -At1 && echo "------Oldest------"'
alias ltr='ls -Art1 && echo "------Newest------"'

alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias vi='vim'
alias wget='wget -c'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'

alias getent='/usr/bin/getent $1'

alias gitlog='git log --pretty=format:'\''%h - %an, %ar : %s'\'''
alias gitlog-diff-files='git show --pretty=format: --name-only $1'

alias hs='history | grep'

alias ping='ping -c 5'
## get running process
alias psinfo='ps -e -o pid,args | grep'
alias pss='ps aux | grep '

## timestamp
alias tstamp='date +%d%b%y_%H%M%S_%Z'

################################ bash functions ################################

# extract archives
extract () {
     if [ -f "$1" ] ; then
         case $1 in
             *.tar.bz2)   tar xjf "$1"        ;;
             *.tar.gz)    tar xzf "$1"     ;;
             *.tar.xz)    tar xf "$1"     ;;
             *.bz2)       bunzip2 "$1"       ;;
             *.rar)       rar x "$1"     ;;
             *.gz)        gunzip "$1"     ;;
             *.tar)       tar xf "$1"        ;;
             *.tbz2)      tar xjf "$1"      ;;
             *.tgz)       tar xzf "$1"       ;;
             *.zip)       unzip "$1"     ;;
             *.Z)         uncompress "$1"  ;;
             *.7z)        7z x "$1"    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

###

## This is quite useful command to quickly search bash history over years of work!
## require valid settings under ~/.bashrc
deephs(){
if [ "$#" -lt 1 ]; then
  echo "Usage: deephs query or deephs "bedtools.*wgEncode.*bed""
else
  grep -rhn "$1" ~/.history/
fi
}

## END ##
