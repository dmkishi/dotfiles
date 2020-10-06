# Exit if not running interactively.
case $- in
  *i*) ;;
    *) return;;
esac




################################################################################
# Custom Prompt                                                                #
################################################################################
# USER/HOST CONFIG -------------------------------------------------------------
HOSTICON=👻
SSHSHORTCUT=


# INIT -------------------------------------------------------------------------
USERNAME='\u'

# \w  Current working directory, with $HOME abbreviated with a tilde
# \W  Current working directory name, with $HOME abbreviated with a tilde
DIRECTORYNAME='\w/'

IS_REMOTE_SSH=false
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  IS_REMOTE_SSH=true
fi

HOSTINFO=$HOSTICON
if [ "$IS_REMOTE_SSH" = true ] && [ -n "$SSHSHORTCUT" ]; then
  HOSTINFO="${HOSTICON}[${SSHSHORTCUT}]"
fi

IS_TMUX=false
if [[ "$TERM" != *"xterm"* ]]; then
  IS_TMUX=true
fi

# In tmux, the title bar is set by tmux itself, via `.tmux.conf`
if [ "$IS_TMUX" = false ]; then
  TITLEBAR="\[\033]0;${HOSTINFO} ${DIRECTORYNAME}\007\]"
fi

# tput Color Legend:
#   - 0  Black     - 4  Blue
#   - 1  Red       - 5  Magenta
#   - 2  Green     - 6  Cyan
#   - 3  Yellow    - 7  White
white_on_magenta="\[$(tput setab 5)$(tput setaf 7)\]"
white_on_blue="\[$(tput setab 4)$(tput setaf 7)\]"
green="\[$(tput setaf 2)\]"

DIRECTORYCOLOR=$white_on_magenta
GITBRANCHCOLOR=$white_on_blue
if [ "$IS_REMOTE_SSH" = true ]; then
  DIRECTORYCOLOR=$white_on_blue
  GITBRANCHCOLOR=$white_on_magenta
fi

COMMANDCOLOR=$green
RESETCOLOR="\[$(tput sgr0)\]"

# Return Git branch name (if there's a Git repo) padded with whitespace, e.g.
# " master ".
git_branch_name() {
  git branch 2>/dev/null | grep '^*' | awk '{print " "$2" "}'
}


# START ------------------------------------------------------------------------
PS1="${TITLEBAR}${HOSTICON}  ${DIRECTORYCOLOR}${DIRECTORYNAME}${GITBRANCHCOLOR}$(git_branch_name)${RESETCOLOR}${COMMANDCOLOR}$ "
PS2=">  ${COMMANDCOLOR}"

# Reset the command response color. Traps with "DEBUG" are executed after every
# command.
trap 'printf "\e[0m" "$_"' DEBUG

# Cleanup
unset HOSTICON SSHSHORTCUT USERNAME DIRECTORYNAME IS_TMUX IS_REMOTE_SSH HOSTINFO TITLEBAR white_on_magenta white_on_blue green DIRECTORYCOLOR GITBRANCHCOLOR COMMANDCOLOR RESETCOLOR




################################################################################
# Better History                                                               #
# Much taken from: <https://sanctum.geek.nz/arabesque/better-bash-history/>    #
################################################################################
# Default max is 500, let's embiggen.
HISTSIZE=999
HISTFILESIZE=2000

# Ignore certain commands, keep things tidy.
HISTIGNORE='ls:bg:fg:history:h'

# Prepend commands with date and time.
# HISTTIMEFORMAT='%F %H:%M  '

# Ignore duplicate commands and commands beginning with space (useful if we'd
# like certain commands to not be recorded.)
HISTCONTROL=ignoredups

# Better multi-session history support. By default, the shell overwrites
# .bash_history when a session is closed, so that the history only reflects the
# history of the last session closed.
shopt -s histappend

# WARNING: Bad idea, very confusing. Hitting the up-arrow key calls up previous
#          commands across different tabs, panes, and windows across different
#          working directories. Better to simply save histories at close
#          sessions.
# Write to history immediately (instead of after end of each session, which is
# the default.)
# https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows
# PROMPT_COMMAND='history -a'
# PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"




################################################################################
# Aliases                                                                      #
################################################################################
# General
alias ls='ls -FG'
alias ll='ls -lh'
alias la='ls -Alh'
alias ..='cd ..'
alias h='history'
alias less='less -R'  # Always show ANSI-escaped colors

# Git
alias g='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gl='git log'
alias glh='git log | head'
alias tower='gittower'

# Colorize filepath for ag, AKA Silver Searcher
alias ag='ag --color-path=31'




################################################################################
# Path                                                                         #
################################################################################
# Add ~/bin
PATH=$PATH:$HOME/bin

# For Brew (in particular for `arping`)
export PATH="/usr/local/sbin:$PATH"

# For Go
# export PATH=$PATH:$(go env GOPATH)/bin




################################################################################
# Other                                                                        #
################################################################################
# Make grep color-coded
export GREP_OPTIONS='--color=auto'

# Launch rbenv
eval "$(rbenv init -)"
