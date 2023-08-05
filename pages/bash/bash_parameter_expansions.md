---
title: Bash Parameter expansions
tags: [bash]
keywords: bash, Parameter expansions
last_updated: Aug 5, 2023
summary: "Bash Parameter expansions"
sidebar: mydoc_sidebar
permalink: bash_parameter_expansions.html
folder: bash
---

# Bash Parameter expansions
=====

## Basic
```bash
$ NAME="Matrix"

$ echo $NAME
Matrix

$ echo "$NAME"
Matrix

$ echo "${NAME}"
Matrix
```

## Indirection
```bash
$ food="Cake"

$ Cake="Cup cake"

$ echo "${!food}"
Cup cake
```

## Case Modification
`^` modifies the first character to uppercase.  
`,` modifies the first character to lowercase.  
`~  reverse the case for the first character.    
When using the double-form (`^^` / `,,` / `~~` ), all characters are converted.
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

## Variable Name Expansion
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
NOTE: When `@` is used and the expansion appears within double quotes, each variable name expands to a separate word. 
```bash
$ cat <<EOF > test.sh
echo $1
EOF

$ ./test.sh "${!test@}"
test1

$ ./test.sh "${!test*}"
test1 test2 test3
```

## Substring Removal
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

## Search and Replace
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

## String Length
```bash
$ name="Matrix"

$ echo "${#name}"
6
```

## Substring Expansion
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


## Default Value / Alternative Value
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

### Parameters Expansion Matrix

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
{: .table-bordered }

{% include links.html %}
