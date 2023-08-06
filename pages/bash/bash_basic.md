---
title: Bash Basic
tags: [bash]
keywords: bash, script
last_updated: Aug 5, 2023
summary: "Bash Basic"
sidebar: mydoc_sidebar
permalink: bash_basic.html
folder: bash
---

# Bash Basic
=====

Useful Documentations:  
[Bash Reference Manual](https://www.gnu.org/software/bash/manual/html_node/index.html)   
[Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/index.html)  

## String quotes
```bash
$ NAME="Matrix"

$ echo "Hi $NAME"
Hi Matrix

$ echo 'Hi $NAME'
Hi $NAME
```

## Shell Execution
```bash
$ echo "I'm in $(pwd)"
I'm in /home/Matrix/documentations

$ echo "I'm in `pwd`"
I'm in /home/Matrix/documentations
```

## Functions
```bash
get_name() {
   echo "Matrix"
}

$ echo "You are $(get_name)"
You are Matrix
```

## Strict Mode   
```bash
set -euo pipefail
IFS=$'\n\t'
```
[Unofficial bash strict mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/)

<div id="toc" style="">
   <ul>
      <li><a href="#set--e">`set -e`</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#set--u">`set -u`</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#set--o-pipefail">`set -o pipefail`</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#set-ifs">set `IFS`</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
   </ul>
</div>

### `set -e`
The `set -e` option instructs bash to immediately exit if any command has a non-zero exit status. You wouldn't want to set this for your command-line shell, but in a script it's massively helpful. Specifically, if any pipeline; any command in parentheses; or a command executed as part of a command list in braces exits with a non-zero exit status, the script exits immediately with that same status. 

### `set -u`
`set -u` affects variables. When set, a reference to any variable you haven't previously defined - with the exceptions of `$*` and `$@` - is an error, and causes the program to immediately exit.

Without this option
```bash 
$ cat test.sh
#!/bin/bash

firstName="Aaron"
fullName="$firstname Maxwell"
echo "$fullName"

$ ./test.sh
 Maxwell

 $ echo $?
 0
 ```

With this option
```bash 
$ cat test.sh
#!/bin/bash
set -u

firstName="Aaron"
fullName="$firstname Maxwell"
echo "$fullName"

$ ./test.sh
./test.sh: line 5: firstname: unbound variable

$ echo $?
1
```

### `set -o pipefail`
This setting prevents errors in a pipeline from being masked. If any command in a pipeline fails, that return code will be used as the return code of the whole pipeline. By default, the pipeline's return code is that of the last command - even if it succeeds.

```bash
$ grep test /tmp/test | sort
grep: /tmp/test: No such file or directory

$ echo $?
0

$ set -o pipefail

$ grep test /tmp/test | sort
grep: /tmp/test: No such file or directory

$ echo $?
2
```

### set `IFS`
The `IFS` variable - which stands for `I`nternal `F`ield `S`eparator - controls what Bash calls word splitting. When set to a string, each character in the string is considered by Bash to separate words. This governs how bash will iterate through a sequence. For example, this script:
```
$ cat test.sh
#!/bin/bash
IFS=$' '
items="a b c"
for x in $items; do
    echo "$x"
done

IFS=$'\n'
for y in $items; do
    echo "$y"
done


$ ./test.sh
a
b
c
a b c

# show current IFS
$ printf %q "$IFS"
$' \t\n'
```

## Brace expansion
```bash
$ echo {A,B}
A B

$ echo {A,B}.js
A.js B.js

$ echo {A..E}
A B C D E
```

## Conditional Execution
```bash
$ grep test /tmp/test || echo 'Matrix'
grep: /tmp/test: No such file or directory
Matrix

$ grep test /tmp/test && echo 'Matrix'
grep: /tmp/test: No such file or directory
```

## Functions
### Return values
```bash
$ cat bash_return_values.sh
#!/bin/bash

myfunc() {
    local myresult='some value'
    echo ${myresult}
}

result="$(myfunc)"

echo ${result}

$ ./bash_return_values.sh
some value
```

### Raising errors
```bash
$ cat bash_raising_errors.sh
#!/bin/bash

myfunc() {
    return 1
}

if myfunc; then
    echo "success"
else
    echo "failure"
fi

$ ./bash_raising_errors.sh
failure

$ cat bash_raising_errors.sh
#!/bin/bash

myfunc() {
    return 1
}

myfunc

$ ./bash_raising_errors.sh

$ echo $?
1
```

## Various Useful Questions
### Difference between `[` and `[[`  
NOTE: `[[` is a bash extension, so if you are writing sh-compatible scripts then you need to stick with `[`. Make sure you have the `#!/bin/bash` shebang line for your script if you use double brackets.

1. empty strings and strings with whitespaces can be intuitively handled 

   ```bash
   $ ls -al file\ test
   -rw-r--r-- 1 Matrix Matrix 0 Apr 26 08:18 file test
   
   $ file='file test'
   
   $ if [[ -f $file ]]; then echo 'Matrix'; fi
   Matrix
   
   $ if [ -f "$file" ]; then echo 'Matrix'; fi
   Matrix
   
   $ if [ -f $file ]; then echo 'Matrix'; fi
   -bash: [: file: binary operator expected
   
   $ if [ -f ${file} ]; then echo 'Matrix'; fi
   -bash: [: file: binary operator expected
   ```

2. user `&&` / `||` for boolean test and `<` / `>` for string comparisons

   ```bash
   $ string1='aaa'
   
   $ string2='aab'
   
   $ [ -n "$string1" && -n "$string2" ] && echo test
   -bash: [: missing `]'
   
   $ [[ -n "$string1" && -n "$string2" ]] && echo test
   test
   
   $ if [[ "$string1" > "$string2" ]]; then echo test; fi
   
   $ if [[ "$string1" < "$string2" ]]; then echo test; fi
   test
   
   $ if [ "$string1" > "$string2" ]; then echo test; fi
   test
   ```

3. Wonderful `=~` operator for doing regular expression matches.

   with `[`
   ```bash
   if [ "$answer" = y -o "$answer" = yes ]
   ```
   
   with `[[`
   ```bash
   if [[ $answer =~ ^y(es)?$ ]]
   ```
   
   NOTE: captured groups which it stores in `BASH_REMATCH`
   The entire match is assigned to BASH_REMATCH[0], the first sub-pattern is assigned to BASH_REMATCH[1], etc.
   ```bash
   $ answer=yes
   
   $ if [[ $answer =~ ^y(es)$ ]]; then echo test; fi
   test
   
   $ echo ${BASH_REMATCH[*]}
   yes es
   ```
   
   ```bash
   $ answer=yesyes
   
   $ if [[ $answer =~ ^y(es)(yes)$ ]]; then echo test; fi
   test
   
   $ echo ${BASH_REMATCH[*]}
   yesyes es yes
   ```

4. Less strict 

   ```bash
   $ answer=yes
   
   $ if [ $answer = y* ]; then echo test; fi
   
   $ if [[ $answer = y* ]]; then echo test; fi
   test
   ```

[What's the difference between `[` and `[[` in Bash](https://stackoverflow.com/questions/3427872/whats-the-difference-between-and-in-bash)

### Escape `'` within `'` strings
```bash
$ echo 'it is a single quote \''
>
```

```bash
$ echo 'it is a single quote '"'"''
it is a single quote '
```
Explanation of how `'"'"'` is interpreted as just :
1. `'` End first quotation which uses single quotes.
2. `"` Start second quotation, using double-quotes.
3. `'` Quoted character.
4. `"` End second quotation, using double-quotes.
5. `'` Start third quotation, using single quotes.

### `pipelines` trap  
```bash
$ ls -1
test

$ file_count=0

$ echo $file_count; ls -1 | while read -r line; do let file_count++; done; echo $file_count
0
0
```

> Each command in a multi-command pipeline, where pipes are created, is executed in its own subshell, which is a separate process (see [Command Execution Environment](https://www.gnu.org/software/bash/manual/html_node/Command-Execution-Environment.html)). If the lastpipe option is enabled using the shopt builtin (see [The Shopt Builtin](https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html)), the last element of a pipeline may be run by the shell process when job control is not active. [^1]

So as whole 1while-loop` is running in a subshell, even value of `file_count` was updated in it, but `file_count` in original shell and other subshells are still with `0`

> lastpipe
> If set, and job control is not active, the shell runs the last command of a pipeline not executed in the background in the current shell environment.[^2]


```bash
cat <<EOF> test.sh
#!/bin/bash

# Disable Job Controle
set +m

shopt -u lastpipe
shopt | grep lastpipe

echo "This is first pipe"  | { echo $BASH_SUBSHELL; }

shopt -s lastpipe
shopt | grep lastpipe

echo "This is first pipe"  | { echo $BASH_SUBSHELL; }

$ ./test.sh
lastpipe        off
1
lastpipe        on
0
```
Note: `{}` is very important in above example. Without it, `$BASH_SUBSHELL` will be expanded before it was really running. As a result, no matter `lastpipe` is `on` or `off`, the result will be always `0`.   
```bash
$ cat <<EOF> test.sh
#!/bin/bash

set +m

shopt -u lastpipe
shopt | grep lastpipe

echo "This is first pipe"  | echo $BASH_SUBSHELL

shopt -s lastpipe
shopt | grep lastpipe

echo "This is first pipe"  | echo $BASH_SUBSHELL
EOF

$ ./test.sh
lastpipe        off
0
lastpipe        on
0
```
To resolve the original issue to change `file_count` value after `while-loop` ended, [Process Substitution](https://tldp.org/LDP/abs/html/process-sub.html) will be used.
```bash
$ file_count=0

$ echo $file_count; while read -r line; do let file_count++; done < <(ls -1); echo $file_count
0
1
```

[^1]: REF: [Bash Reference Manual - Pipelines](https://www.gnu.org/software/bash/manual/html_node/Pipelines.html)
[^2]: REF: [Bash Reference Manual - Shopt Builtin](https://www.gnu.org/software/bash/manual/html_node/The-Shopt-Builtin.html)

{% include links.html %}