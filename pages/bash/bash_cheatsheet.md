---
title: Bash CheatSheet
tags: [bash]
keywords: bash, script
last_updated: May 2, 2020
summary: "Bash Script cheatsheet"
sidebar: mydoc_sidebar
permalink: bash_cheatsheet.html
folder: bash
---

# Bash Cheatsheet
=====

## Basic
### String quotes
```bash
$ NAME="Matrix"

$ echo "Hi $NAME"
Hi Matrix

$ echo 'Hi $NAME'
Hi $NAME
```

### Shell Execution
```bash
$ echo "I'm in $(pwd)"
I'm in /home/Matrix/documentations

$ echo "I'm in `pwd`"
I'm in /home/Matrix/documentations
```
[Command Substitution](http://wiki.bash-hackers.org/syntax/expansion/cmdsubst)

###x Functions
```bash
get_name() {
   echo "Matrix"
}

$ echo "You are $(get_name)"
You are Matrix
```

### Strict Mode
```bash
set -euo pipefail
IFS=$'\n\t'
```
[Unofficial bash strict mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/)

#### `set -e`
The `set -e` option instructs bash to immediately exit if any command has a non-zero exit status. You wouldn't want to set this for your command-line shell, but in a script it's massively helpful. Specifically, if any pipeline; any command in parentheses; or a command executed as part of a command list in braces exits with a non-zero exit status, the script exits immediately with that same status. 

#### `set -u`
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

#### `set -o pipefail`
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

#### set `IFS`
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
```

### Brace expansion
```bash
$ echo {A,B}
A B

$ echo {A,B}.js
A.js B.js

$ echo {A..E}
A B C D E
```

### Conditional Execution
```bash
$ grep test /tmp/test || echo 'Matrix'
grep: /tmp/test: No such file or directory
Matrix

$ grep test /tmp/test && echo 'Matrix'
grep: /tmp/test: No such file or directory
```

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



## Parameter expansions
### Basic
```bash
$ NAME="Matrix"

$ echo $NAME
Matrix

$ echo "$NAME"
Matrix

$ echo "${NAME}"
Matrix
```

### Indirection
```bash
$ food="Cake"

$ Cake="Cup cake"

$ echo "${!food}"
Cup cake
```

### Case modification
The `^` operator modifies the first character to uppercase, the `,` operator to lowercase, the `~` reverse case. When using the double-form (`^^` / `,,` / `~~`), all characters are converted. 
```bash
$ name="matrix"

$ echo ${name^}
Matrix

$ echo ${name~}
Matrix

$ echo ${name^^}
MATRIX

$ echo ${name~~}
MATRIX

$ name="MATrix"

$ echo ${name,}
mATrix

$ echo ${name~}
mATrix

$ echo ${name,,}
matrix

$ echo ${name~~}
matRIX
```

### Variable name expansion
This expands to a list of all set `variable names` beginning with the string **PREFIX**. The elements of the list are separated by the first character in the `IFS`-variable (<space> by default). 
```bash
$ test1="Matrix1"

$ test2="Matrix2"

$ test3="Matrix3"

$ echo "${!test@}"
test1 test2 test3

$ echo "${!test*}"
test1 test2 test3
```

### Substring removal
1. From the beginning  
   Remove the described `pattern` trying to match it **from the beginning of the string**. The operator `#` will try to remove the shortest text matching the pattern, while `##` tries to do it with the longest text matching.
   ```bash
   $ name='Matrix Zou Matrix Zou'
   
   $ echo "${name#M*Z}"
   ou Matrix Zou
   
   $ echo "${name##M*Z}"
   ou
   ```

2. From the end
   ```bash
   $ echo "${name%Z*u}"
   Matrix Zou Matrix
   
   $ echo "${name%%Z*u}"
   Matrix
   ```

### Search and replace
Substitute (replace) a substring **matched by a pattern**, on expansion time. The matched substring will be entirely removed and the given string will be inserted. 
1. Substitute first occurrence with `/`
   ```bash
   $ name='Matrix Zou Matrix Zou'
   
   $ echo "${name/Matrix/Test}"
   Test Zou Matrix Zou
   ```

2. Substitute all occurrence with `//`
   ```bash
   $ echo "${name//Matrix/Tetst}"
   Test Zou Test Zou
   ```  

3. Archoring, `#` from beginning, `%` from end
   ```bash
   $ echo "${name/#Matrix/Test}"
   Test Zou Matrix Zou
   
   $ echo "${name/%Zou/Test}"
   Matrix Zou Matrix Test
   ```

4. Remove matched pattern
   ```bash
   $ echo "${name/Matrix/}"
    Zou Matrix Zou
   
   $ echo "${name/Matrix}"
    Zou Matrix Zou
   
   $ echo "${name/%Zou}"
   Matrix Zou Matrix
   ```

### String length
```bash
$ name="Matrix"

$ echo "${#name}"
6
```

### Substring expansion
```bash
$ name="Matrix"

$ echo ${name:0:2}    #=> "Ma" (slicing)
Ma

$ echo ${name::2}     #=> "Ma" (slicing)
Ma

$ echo ${name::-1}    #=> "Matri" (slicing)
Matri

$ echo ${name:(-1)}   #=> "x" (slicing from end)
x

$ echo "${name: -1:1}" #=> same as above
x

$ echo ${name:(-2):1} #=> "x" (slicing from right)
i

$ echo "${name:1: -1}" #=> "atri" (negative length means slicing LENGTH charater(s) from end)
atri
```
Note: When using a negative offset, you need to separate the negative number from the colon by ` `(space or `()`(brackets)


### Use a default value
`${var:-DEFAULT}`
`${var-DEFAULT}`
**var** is unset (never was defined) or null (empty), this one expands to **DEFAULT**, otherwise it expands to the value of **var**, as if it just was `${var}`. If you omit the `:` (colon), like shown in the second form, the default value is only used when the **var** was unset, not when it was empty. 
```bash
$ unset food

$ echo ${food-Cake}
Cake

$ echo ${food:-Cake}
Cake

$ food=""

$ echo ${food-Cake}


$ echo ${food:-Cake}
Cake

$ food="Bread"

$ echo ${food-Cake}
Bread

$ echo ${food:-Cake}
Bread
```

### Assign a default value
`${var:=DEFAULT}`
`${var=DEFAULT}`
This one works like the using default values, but the default text you give is not only expanded, but also assigned to the **var**, if it was unset or null. Equivalent to using a default value, when you omit the `:`(colon), as shown in the second form, the default value will only be assigned when the **var** was unset. 
```bash
$ unset food

$ echo ${food=Cake}
Cake

$ echo ${food}
Cake

$ unset food

$ food=""

$ echo ${food=Cake}


$ echo ${food:=Cake}
Cake

$ echo ${food}
Cake
```

### Use an alternate value
`${var:+WORD}`
`${var+WORD}`
This form expands to nothing if the **var** is unset or empty. If it is set, it does not expand to the **var**'s value, but to **WORD**. For the second form, expand to **WORD** only when **var** is empty.
```bash
$ unset foo

$ echo "${foo:+bread}"


$ echo "${foo+bread}"


$ unset foo; foo="Cake"

$ echo "${foo+bread}"
bread

$ echo "${foo:+bread}"
bread

$ unset foo; foo=""

$ echo "${foo+bread}"
bread

$ echo "${foo:+bread}"

```

### Display error if null or unset
`${var:?WORD}`
`${var?WORD}`
If **var** is unset or empty, the expansion of **WORD** will be used as appendix for an error message. The second form is only apply to unset.
```bash
$ unset foo

$ echo "${foo?not set}"
-bash: foo: not set

$ echo "${foo}"


$ echo "${foo:?not set}"
-bash: foo: not set

$ foo=""

$ echo "${foo:?not set}"
-bash: foo: not set

$ echo "${foo?not set}"

```

### Matrix
||**var** Set and Not Null|**var** Set but Null|**var** Unset
| :------ | :------ | :------ | :------ 
|${var:-word}|substitude *var*|substitude *word*|substitude *word*|
|${var-word}|substitude *var*|substitude null|substitude *word*|
|${var:=word}|substitude *var*|assign *word*|assign *word*|
|${var=word}|substitude *var*|substitude null|assign *word*|
|${var:?word}|substitude *var*|error, exit|error, exit|
|${var?word}|substitude *var*|substitude null|error, exit|
|${var:+word}|substitude *word*|substitude null|substitude null|
|${var?word}|substitude *word*|substitude *word*|substitude null|

{% include links.html %}
