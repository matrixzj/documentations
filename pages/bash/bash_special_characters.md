---
title: Bash Special Characters
tags: [bash]
keywords: bash, parameters, characters
last_updated: Aug 19, 2023
summary: "Bash Special Characters"
sidebar: mydoc_sidebar
permalink: bash_special_characters.html
folder: bash
---

# Bash Special Characters
=====

## `#` Comments
comments can be occurred following the end of a command and even embedded with a pipe.
```bash
$ echo "test" |\
# delete `e` from it
ed -e 's/e//g'
tst
```

## `;` semicolon
Command separator. It will permits putting two or more commands on the same line.

## `;;` / `;;&` / `:&`
Terminators of `case` option. `;;&` / `:&` are compatible with verison 4+.

## `.` dot
Equivalent to `source`, which is a bash built-in cmd.

## `,` comma
links together a series of arithmetic operations. All are evaluated, but only the last one is returned. 
```bash
$ let "b=((a=9, 15 / 3))"; echo $a $b
9 5
```
concatenate strings. 
```bash
$ ls /{,tmp}
/:
bin  boot  dev  etc  export  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

/tmp:
bash_test.sh  dido  matrix  pid  set  test  test_pipe  test.sh
```
convert to lowercase
```bash
$ name="MATRIX"; echo ${name,}; echo ${name,,}
mATRIX
matrix
```

## `\` backslash
Escape

## ``` backquote
command substitution
```bastion
$ for i in  `ls -1`; do echo $i; done
bash_test.sh
dido
matrix
pid
set
test
test_pipe
test.sh
```

## `:` colon
null command. It will always return `true` and equivalent as `NO-OP`(do-nothing operation)
```bash
$ ls -1 | grep colon; echo $?
1

$ ls -1 | grep colon; :;  echo $?
0
```
Provide a placeholder where a binary operation is expected. 
```bash
$ n=1; $((n = $n + 1)); echo $n
-bash: 2: command not found
2

$ n=1; : $((n = $n + 1)); echo $n
2
```
Provide a placeholder where a command is expected.
```bash
$ n=1; if [ $n -eq 2 ]; then : ; else echo $n; fi
1
```
Used in parameter substitution / Variable expansion / substring replacement.
combination with the redirection operators
    with `>`, truncates a file to zero length, without changing its permissions. If the file did not previously exist, creates it.
    with `>>`, has no effect on a pre-existing target file. If the file did not previously exist, creates it.
NOTE: applies to regular files, not pipes, symlinks, and certain special files.

## `!` exclamation
reverse 
```bash
$ ! true; echo $?
1

$ true; echo $?
0
```

## `*` asterisk
wild card for filename expansion or arithmetic operator
```bash
$ echo *
bash_test.sh dido matrix pid set test test_pipe test.sh 
```

## `?` question 
test operator in format `condition?result-if-true:result-if-false`
```bash
$ n=1; (( m = n==1?2:3 )) ; echo $m
2
```

## $'...'
Quoted string expansion
```bash
$ echo $'\ttest'
        test
```

## `()` parentheses
List of commands within `()` starts a subshell
```bash
$ echo $BASH_SUBSHELL; (echo $BASH_SUBSHELL)
0
1
```

## `{a,b,c}` brace
brace expansion
```bash
$ echo \"{These,words,are,quoted}\"
"These" "words" "are" "quoted"
```

## `{}` curly brackets
anonymous function. unlike in a "standard" function, the variables inside it remain visible outside
```bash
$ { a=123; } ; echo $a
123
```
The code block enclosed in braces may have I/O redirected to and from it.
```bash
$ { echo a; echo b; } > /tmp/test ; cat /tmp/test
a
b
```

## `(())`
interger expansion
```bash
$ a=$(( 2*2 )) ; echo $a
4
```

## `>` / `&>` / `>>` / `<` / `<>`
redirection
`&>` redirect both `stdout` and `stderr` to file
`<<` redirect used in a `here document` which is a special-purpose code block. It uses a form of I/O redirection to feed a command list to an interactive program or a command, such as `ftp`, `cat`, etc.
```bash
$ cat ./test.sh
#!/bin/bash

sftp localhost <<EOF
cd /tmp
ls -1
quit
EOF

$ ./test.sh
Warning: Permanently added 'localhost' (ECDSA) to the list of known hosts.
Connected to localhost.
sftp> cd /tmp
sftp> ls -1
dido
matrix
subshell.sh
test
test.sh
test_pipe
sftp> quit
```

`<<<` redirect used in a `here string` which can be considered as a stripped-down form of a `here document`.
```bash
$ grep -q test <<< "This is a test string"; echo $?
0
```
same as 
```bash
$ echo "This is a test string" | grep -q test ; echo $?
0
```
`(command)>` / `<(command)` process substitution

## `>|` force overwrite
```bash 
$ bash -C echo > test.sh
bash: test.sh: cannot overwrite existing file

$ ls -al test.sh; bash -C echo >| test.sh; ls -al test.sh
-rwxr-xr-x 1 jun_zou jun_zou 5 Aug 16 19:48 test.sh
/usr/bin/echo: /usr/bin/echo: cannot execute binary file
-rwxr-xr-x 1 jun_zou jun_zou 0 Aug 16 19:48 test.sh
```

## `-` redirect from/to `stdin` or `stdout`
```bash
$ cat -
test
test

$ echo matrix | cat -
matrix
```
Redirect `stdin` 

Transfer files to remote host with `-` redirect
```bash
$ ls -al /tmp/visual; tar cf - visual | ssh -q localhost 'tar xf - -C /tmp'; ls -al /tmp/visual
ls: cannot access /tmp/visual: No such file or directory
-rw-rw-r-- 1 jun_zou jun_zou 2845 Jul 28  2022 /tmp/visual
```

## `~+` current working directory

## `~-` previous working directory
```bash
$ echo ~+; cd ~-; echo ~+ ; cd ~-; echo ~+
/tmp/test
/home/jun_zou
/tmp/test
```

## `$*` / `$@` 
The positional parameters starting from the first.  
```bash
$ cat ./bash_special_characers.sh
#!/bin/bash

echo "$*"

echo "$@"

IFS=$'\n'

echo "$*"

echo "$@"

echo $1

echo $2

$ ./bash_special_parmeters.sh  12 34
12 34
12 34
12
34
12 34
12
34
```

When used inside doublequotes (see quoting), like `$*`, it expands to all positional parameters as one word, delimited by the first character of the **IFS** variable (a space in this example): "$1 $2 $3 $4". But `$@` will be not take **IFS** as delimiter.   
```bash
$ cat bash_special_parmeters.sh
#! /bin/bash

# bash_special_parmeters.sh - Cmd args - positional parameter demo

#### Set the IFS to | ####
IFS='|'

echo "Command-Line Arguments Demo"

echo "*** All args displayed using \$@ positional parameter ***"
echo "$@"        #*** double quote added ***#

echo "*** All args displayed using \$* positional parameter ***"
echo "$*"        #*** double quote added ***#

$ ./bash_special_parmeters.sh apple pear grape lemon
Command-Line Arguments Demo
*** All args displayed using $@ positional parameter ***
apple pear grape lemon
*** All args displayed using $* positional parameter ***
apple|pear|grape|lemon
```

## `$#` hash mark
Number of positional parameters (decimal) 
```bash
$ cat ./bash_special_parmeters.sh
#!/bin/bash

echo "$#"

$ ./bash_special_parmeters.sh  12 34
2
```

## `$?` 
Status of the most recently executed foreground-pipeline (exit/return code)

## `$-` dash
Current option flags set by the shell itself.
```bash
$ cat bash_special_parmeters.sh
#!/bin/bash

echo "$-"

set -euo pipefail

echo "$-"

$ ./bash_special_parmeters.sh 12 34
hB
ehuB
```

## `$$`
The process ID (PID) of the shell. In an explicit subshell it expands to the PID of the current "main shell", not the subshell. This is different from `$BASHPID`!
```bash
$ echo $$; echo $BASHPID ; ( cd /usr; pstree -p | grep $$; echo "$$" )
33969
33969
           |             |-bash(33969)---bash(33868)-+-grep(33870)
33969

$ echo $$; echo $BASHPID ; ( cd /usr; pstree -p | grep $$; echo "$BASHPID" )
33969
33969
           |             |-bash(33969)---bash(34977)-+-grep(34979)
34977
```

## `$!` exclamation mark
The process ID (PID) of the most recently executed background pipeline
```bash
$ ping -c 1000 localhost > /dev/null  &
[1] 47589

$ echo $!
47589
```

## `$0` zero 
The name of the shell or the shell script (filename).
```bash
$ echo $0
-bash

$ cat bash_special_parmeters.sh
#!/bin/bash

echo "$0"

$ ./bash_special_parmeters.sh
./bash_special_parmeters.sh
```

## `$_` underscore
A kind of catch-all parameter. Directly after shell invocation, it's set to the filename used to invoke Bash, or the absolute or relative path to the script, just like $0 would show it. Subsequently, expands to the last argument to the previous command. 
```bash
$ cat bash_special_parmeters.sh
#! /bin/bash

echo "$_"

$ ./bash_special_parmeters.sh
./bash_special_parmeters.sh

$ cat bash_special_parmeters.sh
#! /bin/bash

echo test

echo "$_"

$ ./bash_special_parmeters.sh
test
test
```

[More about bash special parameters and shell vaviables](https://wiki.bash-hackers.org/syntax/shellvars)

{% include links.html %}