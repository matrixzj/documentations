---
title: Bash String Manipulate
tags: [bash]
keywords: bash, string manipulate
last_updated: Aug 5, 2023
summary: "Bash string manipulate"
sidebar: mydoc_sidebar
permalink: bash_string_manipulate.html
folder: bash
---

# Bash String Manipulate 
=====

## String Length
Syntx:
```bash
${#variable_naem}

expr length "$string"

expr "$string" : '.*'
```
Example:
```bash
full_name="Matrix Zou"

$ echo "${#full_name}"
10

$ echo $(expr length "${full_name}")
10

$ echo $(expr "${full_name}" : '.*')
10
```

## Length of Matching SubString from Beginning of String
Syntax: 
```bash
expr match "$string" '$substring'

expr "$string" : '$substring'
```
Example:  
```bash
$ full_name="Matrix Zou"

$ name="M.*x"

$ echo $(expr match "$full_name" $name)
6

$ echo $(expr match "$full_name" 'M.*x')
6

$ echo $(expr "$full_name" : '.*')
10
```

## Index
Syntax:
```bash
expr index "$string" $substring
```
Example:
```bash
$ full_name="Matrix Zou"

$ name="M.*x"

$ echo $(expr index "$full_name" "$name")
1

$ echo $(expr index "$full_name" 'M.*x')
1
```

## SubString Extraction
Syntax:
```bash
${string:position}

${string:position:length}

expr substr $string $position $length
```
NOTE: for `expr substr`, `$position` counted from 1
Example:
```bash
$ echo ${full_name:3}
rix Zou

$ echo ${full_name:3:3}
rix

$ echo $(expr substr "${full_name}" 4 3)
rix

$ echo ${full_name: -3}
Zou

$ echo ${full_name:(-3)}
Zou

$ index_of_substring=$(echo $(expr index "${full_name}" 'rix'))

$ echo ${full_name:$((--index_of_substring))}
rix Zou
```
Note: When using a negative offset, you need to separate the negative number from the colon by ` `(space or `()`(brackets)

## Substring Removal
### From the beginning  
Remove the described `pattern` trying to match it **from the beginning of the string**. The operator `#` will try to remove the shortest text matching the pattern, while `##` tries to do it with the longest text matching.
Syntax:
```bash
${string#substring}

${string##substring}
```
Example:
```bash
$ name='Matrix Zou Matrix Zou'

$ echo "${name#M*Z}"
ou Matrix Zou

$ echo "${name##M*Z}"
ou
```

### From the end
Syntax: 
```bash
${string%substring}

${string%%substring}
```
Example:
```bash
$ echo "${name%Z*u}"
Matrix Zou Matrix

$ echo "${name%%Z*u}"
Matrix
```

## Search and Replace
Substitute (replace) a substring **matched by a pattern**, on expansion time. The matched substring will be entirely removed and the given string will be inserted. 
### The First Occurrence 
Syntax:
```bash
${string/substring/replacement}
```
Example:
```bash
$ name='Matrix Zou Matrix Zou'

$ echo "${name/Matrix/Test}"
Test Zou Matrix Zou
```

### All Occurrence
Syntax:
```bash
${string//substring/replacement}
```
Example:
```bash
$ echo "${name//Matrix/Tetst}"
Test Zou Test Zou
```  

### Archoring, `#` from beginning, `%` from end
Syntax:
```bash
${string/#substring/replacement}

${string/%substring/replacement}
```
Example:
```bash
$ echo "${name/#Matrix/Test}"
Test Zou Matrix Zou
   
$ echo "${name/%Zou/Test}"
Matrix Zou Matrix Test
```

### Remove Substring
Syntax:
```bash
${string/substring/}

${string/%substring/}
```
Example:
```bash
$ echo "${name/Matrix/}"
Zou Matrix Zou

$ echo "${name/Matrix}"
 Zou Matrix Zou

$ echo "${name/%Zou/}"
Matrix Zou Matrix

$ echo "${name/%Zou}"
Matrix Zou Matrix
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

## Case Modification
`^` modifies the first character to uppercase.  
`,` modifies the first character to lowercase.  
`~`  reverse the case for the first character.      
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

`${parameter^pattern}` / `${parameter^^pattern}` / `${parameter,pattern}` / `${parameter,,pattern}`   
While trying to convert case, it will compare with `pattern`. The `pattern` should not attempt to match more than one character. 
```bash
$ name="matrix"

$ echo ${name^a}
matrix

$ echo ${name^m}
Matrix
```

{% include links.html %}
