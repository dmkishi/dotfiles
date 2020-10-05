# Don't do anything if not running interactively.
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
# \w  Current working directory, with $HOME abbreviated with a tilde
# \W  Current working directory name, with $HOME abbreviated with a tilde
USERNAME='\u'
DIRECTORYNAME='\w/'

IS_TMUX=false
if [[ $TERM != *"xterm"* ]]; then
  IS_TMUX=true
fi

IS_REMOTE_SSH=false
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  IS_REMOTE_SSH=true
fi

HOSTINFO=$HOSTICON
if $IS_REMOTE_SSH && [ ! -z "$SSHSHORTCUT" ]; then
  HOSTINFO="${HOSTICON}[${SSHSHORTCUT}]"
fi

TITLEBAR="${HOSTINFO} ${DIRECTORYNAME}"
if $IS_TMUX; then
  # Additional information appended via `~/.tmux.conf`
  TITLEBAR=$HOSTINFO
fi
TITLEBAR="\[\033]0;${TITLEBAR}\007\]"

# Setup prompt with colors
#   Color Legend:
#     - 0  Black     - 4  Blue
#     - 1  Red       - 5  Magenta
#     - 2  Green     - 6  Cyan
#     - 3  Yellow    - 7  White
DIRECTORYCOLOR="\[$(tput setab 5)\]\[$(tput setaf 7)\]"    # White on magenta
if $IS_REMOTE_SSH; then
  DIRECTORYCOLOR="\[$(tput setab 4)\]\[$(tput setaf 7)\]"  # White on blue
fi
COMMANDCOLOR="\[$(tput setaf 2)\]"                         # Green
RESETCOLOR="\[$(tput sgr0)\]"

# START ------------------------------------------------------------------------
# The title bar is declared with the prompt but does not appear with it.
# NOTE: The title bar variable fucks up when I scroll through history with the
#       arrow key....
PS1="${TITLEBAR}${HOSTICON}  ${DIRECTORYCOLOR}${DIRECTORYNAME}${RESETCOLOR} ${COMMANDCOLOR}"
PS2=">  ${COMMANDCOLOR}"

# Traps with DEBUG are executed after every command. This resets the command
# color.
trap 'printf "\e[0m" "$_"' DEBUG


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

# Git
alias g='git status'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gl='git log'
alias glh='git log | head'
alias tower='gittower'


################################################################################
# Other                                                                        #
################################################################################
# Add ~/bin as part of path
PATH=$PATH:$HOME/bin

# Make grep color-coded
export GREP_OPTIONS='--color=auto'

# Launch rbenv
eval "$(rbenv init -)"
