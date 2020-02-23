---
title: Bash History Collector
tags: [misc]
keywords: bash, cmd history
last_updated: Feb 23, 2020
summary: "collecting bash historical cmds for all users"
sidebar: mydoc_sidebar
permalink: misc_bash_history_collector.html
folder: Misc
---

## Bash History Collector
=====

### `bash history collector` script
```
# cat /etc/bash_history_collector
if [ "${SHELL##*/}" != "bash" ]; then
  return
fi

# to avoid sourcing this file more than once
if [ "$AUDIT_INCLUDED" == "$$" ] || { [ -z "$SSH_ORIGINAL_COMMAND" ] && [ "$(cat /proc/$$/cmdline)" == 'bash-c"/etc/forcecommand.sh"' ]; }; then
  return
else
  declare -rx AUDIT_INCLUDED="$$"
fi

# 'history' options
declare -rx HISTFILE="$HOME/.bash_history"
# declare -rx HISTSIZE=500000                                 # nbr of cmds in memory
# declare -rx HISTFILESIZE=500000                             # nbr of cmds on file
declare -rx HISTCONTROL=""                                  # does not ignore spaces or duplicates
declare -rx HISTIGNORE=""                                   # does not ignore patterns
declare -rx HISTCMD                                         # history line number

if groups | grep -q root; then
  declare -x TMOUT=43200                                    # timeout for root's sessions
  chattr +a "$HISTFILE"                                     # set append-only
fi

shopt -s histappend
shopt -s cmdhist

# history substitution ask for a confirmation
shopt -s histverify

## add timestamps in history - obsoleted with logger/syslog
# declare -rx HISTTIMEFORMAT='%F %T '

# enable forward search ('ctrl-s')
if shopt -q login_shell && [ -t 0 ]; then
  stty -ixon
fi

# bash audit & traceability
declare -rx AUDIT_LOGINUSER="$(who -mu | awk '{print $1}')"
declare -rx AUDIT_LOGINPID="$(who -mu | awk '{print $6}')"
declare -rx AUDIT_USER="$USER"                              #defined by pam during su/sudo
declare -rx AUDIT_PID="$$"
declare -rx AUDIT_TTY="$(who -mu | awk '{print $2}')"
declare -rx AUDIT_SSH="$([ -n "$SSH_CONNECTION" ] && echo "$SSH_CONNECTION" | awk '{print $1":"$2"->"$3":"$4}')"
declare -rx AUDIT_TAG="bash_history"
declare -rx AUDIT_STR="[$AUDIT_LOGINUSER/$AUDIT_LOGINPID as $AUDIT_USER/$AUDIT_PID on $AUDIT_TTY/$AUDIT_SSH]"
declare -x AUDIT_LASTHISTLINE=""                            #to avoid logging the same line twice
declare -rx AUDIT_SYSLOG="1"                                #to use a local syslogd

# the logging at each execution of command is performed with a trap DEBUG function
# and having set the required history options (HISTCONTROL, HISTIGNORE)
# and to disable the trap in functions, command substitutions or subshells.
# it turns out that this solution is simple and works well with piped commands, subshells, aborted commands with 'ctrl-c', etc..
set +o functrace                                            # disable trap DEBUG inherited in functions, command substitutions or subshells, normally the default setting already
shopt -s extglob                                            # enable extended pattern matching operators
function AUDIT_DEBUG() {
  if [ -z "$AUDIT_LASTHISTLINE" ]; then                     # initialization
    if [ -f "$HISTFILE" ] && [ "$(wc -l .bash_history | awk '{print $1}')" -ne 0 ]; then
      local AUDIT_CMD="$(fc -l -1 -1)"                        # previous history command
      AUDIT_LASTHISTLINE="${AUDIT_CMD%%+([^ 0-9])*}"
    else
      local AUDIT_CMD=""                                       # handle a newly created home dir
      AUDIT_LASTHISTLINE="${AUDIT_CMD%%+([^ 0-9])*}"
    fi
  else
    AUDIT_LASTHISTLINE="$AUDIT_HISTLINE"
  fi
  local AUDIT_CMD="$(history 1)"                            # current history command
  if [ -z "${HISTTIMEFORMAT}" ]; then
    AUDIT_HISTLINE="$(echo ${AUDIT_CMD%%+([^ 0-9])*})"
  else
    AUDIT_HISTLINE="$(echo ${AUDIT_CMD%%+([^ 0-9])*} | cut -d' ' -f1)"
  fi
  if [ "${AUDIT_HISTLINE:-0}" -ne "${AUDIT_LASTHISTLINE:-0}" ] || [ "${AUDIT_HISTLINE:-0}" -eq "1" ]; then  #AUDIT_HISTLINE avoid logging unexecuted commands after 'ctrl-c', 'empty+enter', or after 'ctrl-d'
    echo -ne "${_backnone}${_frontgrey}"                    # disable prompt colors for the command's output
    # remove in last history cmd its line number (if any) and send to syslog
    if [ -n "$AUDIT_SYSLOG" ]; then
      if ! logger -p user.info -t "$AUDIT_TAG" "$AUDIT_STR $PWD" "${AUDIT_CMD##*( )?(+([0-9])?(\*)+( ))}"; then
        echo error "AUDIT_TAG" "$AUDIT_STR $PWD" "${AUDIT_CMD##*( )?(+([0-9])?(\*)+( ))}"
      fi
    else
      echo $( date +%F_%H:%M:%S ) "AUDIT_TAG" "$AUDIT_STR $PWD" "${AUDIT_CMD##*( )?(+([0-9])?(\*)+( ))}" >>/var/log/cmd.log
    fi
# debug
#    echo "===cmd:$BASH_COMMAND/subshell:$BASH_SUBSHELL/fc:$(fc -l -1)/history:$(history 1)/histline:${AUDIT_CMD%%+([^ 0-9])*}/last_histline:${AUDIT_LASTHISTLINE}===" #for debugging
    return 0
  else
    return 1
  fi
}

# aut the session closing
function AUDIT_EXIT() {
  local AUDIT_STATUS="$?"
  if [ -n "$AUDIT_SYSLOG" ]; then
    logger -p user.info -t "$AUDIT_TAG" "$AUDIT_STR" "#=== session closed $AUDIT_LOGINUSER/$AUDIT_LOGINPID ==="
  else
    echo $( date +%F_%H:%M:%S ) "$AUDIT_TAG" "$AUDIT_STR" "#=== session closed $AUDIT_LOGINUSER/$AUDIT_LOGINPID ===" >>/var/log/cmd.log
  fi
  exit "$AUDIT_STATUS"
}

# make audit trap functions readonly; disable trap DEBUG inherited (normally the default setting already)
declare -frx +t AUDIT_DEBUG
declare -frx +t AUDIT_EXIT

# audit the session opening
if [ -n "$AUDIT_SYSLOG" ]; then
  logger -p user.info -t "$AUDIT_TAG" "$AUDIT_STR" "#=== session opened $AUDIT_LOGINUSER/$AUDIT_LOGINPID ===" #audit the session openning
else
  echo $( date +%F_%H:%M:%S ) "$AUDIT_TAG" "$AUDIT_STR" "#=== session opened $AUDIT_LOGINUSER/$AUDIT_LOGINPID ===" >>/var/log/cmd.log
fi

# when a bash command is executed it launches first the AUDIT_DEBUG(),
# then the trap DEBUG is disabled to avoid a useless rerun of AUDIT_DEBUG() during the execution of pipes-commands;
# at the end, when the prompt is displayed, re-enable the trap DEBUG
declare -x PROMPT_COMMAND="[ -n \"\$AUDIT_DONE\" ]; AUDIT_DONE=; trap 'AUDIT_DEBUG && AUDIT_DONE=1; trap DEBUG' DEBUG"
declare -rx BASH_COMMAND                                    # current command executed by user or a trap
declare -rx SHELLOPT                                        # shell options, like functrace
trap AUDIT_EXIT EXIT                                        # audit the session closing

# terminal/window's size:
shopt -s checkwinsize
```

### Hook it in `/etc/bashrc`
```
# echo "[ -f /etc/bash_history_collector ] && . /etc/bash_history_collector # added for bash history collector"  >> /etc/bashrc
```

{% include links.html %}
