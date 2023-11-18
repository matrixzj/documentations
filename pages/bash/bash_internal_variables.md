---
title: Bash Internal Variables 
tags: [bash]
keywords: bash, variables
last_updated: Aug 5, 2023
summary: "Bash Internal Variables"
sidebar: mydoc_sidebar
permalink: bash_internal_variables.html
folder: bash
---

# Bash Internal Variables
=====

## `$BASH`
The path to `bash` binary itself
```bash
$ echo $BASH
/bin/bash
```

## `$BASH_SUBSHELL`
Indicating subshell level
```bash
$  (echo $BASH_SUBSHELL; (echo $BASH_SUBSHELL))
1
2
```

## `$BASHPID`
current Process ID. Similar as `$$`, but in subshell, it will shown as real Process ID, not parent Process ID as `$$`
```bash
$ echo $$; echo $BASHPID ; ( cd /usr; pstree -p | grep $$; echo "$BASHPID" )
21443
21443
           |-sshd(8595)---sshd(21440)---sshd(21442)---bash(21443)---bash(27203)-+-grep(27205)
27203
```

## `$BASH_VERSINFO[n]`
A 6-element array containing version info for running Bash. Similar as `$BASH_VERSION`, which is a string for current info.
```bash
$ for i in "${BASH_VERSINFO[@]}"; do echo $i; done
4                               # Major version
2                               # Minor version
46                              # Patch level
2                               # Build version
release                         # Release status
x86_64-redhat-linux-gnu         # Arch
```

## `$CDPATH`
A colon-separated list of search paths available to the `cd` command
```bash
$ cd bash-4.2.46
-bash: cd: bash-4.2.46: No such file or directory

$ CDPATH=/usr/share/doc

$ cd bash-4.2.46
/usr/share/doc/bash-4.2.46

$ pwd
/usr/share/doc/bash-4.2.46
```

## `$FUNCNAME`
Current function name. 
```bash
$ function matrix () {
> echo "$FUNCNAME is running"
> }

$ matrix
matrix is running
```

## `$GLOBIGNORE`
A list of filename patterns to be excluded from matching in globbing. 
```bash
$ ls te*
test.sh

$ GLOBIGNORE=te*

$ ls te*
ls: cannot access te*: No such file or directory
```

## `$HOME`
Home Directory of current user. 

## `$HOSTNAME`
Current hostname.

## `$HOSTTYPE`
Arch
```bash
$ echo $HOSTTYPE
x86_64
```

## `$IFS`
internal field separator
Note: When working with `$*`, the first character held in `$IFS` will be used. 
```bash
$ bash -c 'set w x y z; IFS=":-;"; echo "$*"'
w:x:y:z

$ printf "%q" "$IFS"
$' \t\n'

$ echo "$IFS" | cat -vte
 ^I$
$

$ var1="a+b+c"; IFS='+'; echo $var1
a b c
```
Note: `$IFS` treats whitespace differently than other characters. No matter how many continous whitespaces, they will be taken as a single splitter. 
```bash
$ var='  a  b c   '; IFS=' '; echo $var | tr ' ' '#'
a#b#c

$ var='::a::b:c:::'; IFS=':'; echo $var | tr ' ' '#'
##a##b#c##
```

## `$IGNOREEOF`
Ignore EOF: how many end-of-files (control-D) the shell will ignore before logging out.

## `$LINENO`
line number of shell script
```bash
$ cat /tmp/test.sh | awk '{print NR, $0}'
1 #!/bin/bash
2
3 echo test
4 echo $LINENO

$ /tmp/test.sh
test
4
```

## `$OLDPWD`
Last working directory
```bash
$ pwd
/tmp

$ cd ~

$ echo $OLDPWD
/tmp
```

## `$PIPESTATUS`
Array variable holding exit status(es) of last executed foreground pipe.
```bash
$ ls -al | wc -l
110

$ echo ${PIPESTATUS[@]}
0 0
```
`$PIPESTATUS` is a "volatile" variable. It needs to be captured immediately. It will always show last command exit status(es).
```bash
$ ls -al | wc -l
110

$ test

$ echo ${PIPESTATUS[@]}
1

$ test

$ echo $?
1
```

## `$PROMPT_COMMAND`
holding a command to be executed just before the primary prompt, $PS1 is to be displayed.
```bash
$ export PROMPT_COMMAND='echo "Current date and time: $(date)"'
Current date and time: Sat Sep 16 18:07:54 UTC 2023

$
Current date and time: Sat Sep 16 18:08:21 UTC 2023
```

## `$PS1` / `$PS2` / `$PS3` / `$PS4`
`$PS1` main prompt, seen at the command-line.
`$PS2` secondary prompt, seen when additional input is expected. It displays as ">".
`$PS3` tertiary prompt, displayed in a select loop
`$PS4` quartenary prompt, shown at the beginning of each line of output when invoking a script with the `-x`

```bash
$ PS3='Please choose: '; select answer in "Yes" "No"; do echo "Let's check PS3 Value, and your answer is $REPLY"; break;  done
1) Yes
2) No
Please choose: 1
Let's check PS3 Value, and your answer is 1

$ cat /tmp/test.sh
#!/bin/bash
# PS4='___'

echo " test"

$ echo $PS4; bash -x /tmp/test.sh
+
+ echo ' test'
 test

$ cat /tmp/test.sh
#!/bin/bash
PS4='___'

echo " test"

$ bash -x /tmp/test.sh
+ PS4=___
___echo ' test'
 test
```

## `$REPLY`
default value when a variable is not supplied to `read`. In a login shell, it was how many seconds has been log in. 
```bash
$ echo $SECONDS
715
```

## `$SHELLOPTS`
list of enabled shell options, a readonly variable. 
```bash
$ echo $SHELLOPTS; set -o verbose; echo $SHELLOPTS
braceexpand:emacs:hashall:histexpand:history:interactive-comments:monitor
braceexpand:emacs:hashall:histexpand:history:interactive-comments:monitor:verbose
```

## `$SHLVL`
shell level, how deeply Bash is nested.
```bash
$ echo $SHLVL; bash -c 'echo $SHLVL'
1
2
```