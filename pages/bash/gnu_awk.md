---
title: GNU AWK
tags: [bash]
keywords: awk 
last_updated: Nov 19, 2023
summary: "awk howto"
sidebar: mydoc_sidebar
permalink: bash_gnu_awk.html
folder: bash
---

GNU AWK
=====

## System Variables

### **FS**    
field separator. By default, its value is a single space. FS can also be set to any single character, or to a regular expression.

### **OFS**   
output field separator. By default awk OFS is a single space character.   


```bash
$ echo "matrix" | awk 'BEGIN{FS="tr"}{print $1}'
ma

$ echo "matrix" | awk 'BEGIN{FS="tr"}{print $1, $2}'
ma ix

$ echo "matrix" | awk 'BEGIN{FS="tr";OFS="\n"}{print $1, $2}'
ma
ix
```

### **RS**    
record separator. By default, its value is a newline.  

#### Paragraph mode
As a special case, when *RS* is set to empty string, one or more consecutive empty lines is used as the input record separator. Consider the below sample file:

```bash
$ cat programming_quotes.txt
Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it by Brian W. Kernighan

Some people, when confronted with a problem, think - I know, I will
use regular expressions. Now they have two problems by Jamie Zawinski

A language that does not affect the way you think about programming,
is not worth knowing by Alan Perlis

There are 2 hard problems in computer science: cache invalidation,
naming things, and off-by-1 errors by Leon Bambrick
```

Here's an example of processing input paragraph wise.

```bash
$ awk -v RS= 'NR == 1' /tmp/programming_quotes.txt
Debugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it by Brian W. Kernighan

$ # print all paragraphs containing 'you'
$ # note that there'll be an empty line after the last record
$ awk -v RS= -v ORS='\n\n' '/you/' /tmp/programming_quotes.txt
Debugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it by Brian W. Kernighan

A language that does not affect the way you think about programming, is not worth knowing by Alan Perlis
```

### **ORS**   
output record separator. By default, its value is a newline.   

```bash
$ echo "matrix" | awk 'BEGIN{RS="tr"}{if(NR==2)print $1}'
ix

$ echo "matrix" | awk 'BEGIN{RS="tr"}{print}' | sed -ne 'l'
ma$
ix$
$

$ echo "matrix" | awk 'BEGIN{RS="tr";ORS="|"}{print}' | sed -ne 'l'
ma|ix$
|$
```

### **RT**
contains the text that was matched by `RS`. This variable gets updated for every input record.
```bash
$ echo "matrix" | awk -v RS='tr' '{print NR, RT}'
1 tr
2
```

### **NF**    
number of fields for the current input record.  

### **NR**    
number of records being processed or line number.     

```bash
$ echo "a|b|c" | awk 'BEGIN{FS="|"}{print NF}'
3

$ echo "a|b|c" | awk 'BEGIN{RS="|"}{print NR}'
1
2
3
```

### **FPAT**
defines what should the fields be made up of, AKA `field pattern`
```bash
$ echo 'Sample123string42with777numbers' | awk 'BEGIN{FPAT="[0-9]+"}{print $2}'
42

$ echo 'Sample123string42with777numbers' | awk -v FPAT="[0-9]+" '{print $2}'
42
```

### **FILENAME** 
the name of the file being read     

```bash
$ echo "a|b|c" | awk '{print FILENAME}'
-

$ cat /tmp/student
matrix  1
eli 2
kirk    3
haiyu   4

$ cat /tmp/score
1 60
2 70
4 100

$ awk '{print FILENAME}' /tmp/student /tmp/score
/tmp/student
/tmp/student
/tmp/student
/tmp/student
/tmp/score
/tmp/score
/tmp/score
```

### **FNR**   
Number of Records relative to the current input file    

```bash
$ awk '{print NR}' /tmp/student /tmp/score
1
2
3
4
5
6
7

$ awk '{print FNR}' /tmp/student /tmp/score
1
2
3
4
1
2
3
```

### **CONVFMT**   
number-to-string conversions. By default, the value is '%.6g' 

### **OFMT**      
string-to-number conversions. By default, the value is '%.6g'    

```bash
$ awk -v OFMT="%d" 'BEGIN{print str = (5.5 + 3.2)}'
8

$ echo 0.77767686 |  awk '{ print "" 0+$0 }' OFMT='%.1g'
0.777677

$ echo 0.77767686 |  awk '{ print "" 0+$0 }' CONVFMT='%.1g'
0.8
```

### **ENVIRON**
An array containing the values of the current environment.   

```bash
$ awk 'BEGIN{for(item in ENVIRON){print item, ":", ENVIRON[item]}}'
AWKPATH : .:/usr/share/awk
OLDPWD : /home/matrix
SELINUX_LEVEL_REQUESTED :
SELINUX_ROLE_REQUESTED :
LANG : en_US.UTF-8
PYENV_VIRTUALENV_INIT : 1
LC_ALL : en_US.UTF-8
HISTSIZE : 1000
XDG_RUNTIME_DIR : /run/user/1001
USER : matrix
HISTFILESIZE : 10000
_ : /usr/bin/awk
SELINUX_USE_CURRENT_RANGE :
TERM : screen-256color
HISTTIMEFORMAT : %d/%m/%y %T
SHELL : /bin/bash
PYENV_SHELL : bash
SSH_CONNECTION : 31.215.112.217 63239 10.0.0.4 22
XDG_SESSION_ID : 56574
LESSOPEN : ||/usr/bin/lesspipe.sh %s
PATH : /home/matrix/.pyenv/plugins/pyenv-virtualenv/shims:/home/matrix/.pyenv/shims:/home/matrix/.pyenv/shims:/home/matrix/.pyenv/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/local/go/bin:/home/matrix/.local/bin:/home/matrix/bin
MAIL : /var/spool/mail/matrix
SSH_CLIENT : 31.215.112.217 63239 22
PYENV_ROOT : /home/matrix/.pyenv
HOSTNAME : matrix-oracle-instance-1
HOME : /home/matrix
PWD : /home/matrix/git/documentations
SSH_TTY : /dev/pts/1
HISTCONTROL : ignoredups
LC_CTYPE : UTF-8
LOGNAME : matrix
SHLVL : 1
LS_COLORS : rs=0:di=38;5;27:ln=38;5;51:mh=44;38;5;15:pi=40;38;5;11:so=38;5;13:do=38;5;5:bd=48;5;232;38;5;11:cd=48;5;232;38;5;3:or=48;5;232;38;5;9:mi=05;48;5;232;38;5;15:su=48;5;196;38;5;15:sg=48;5;11;38;5;16:ca=48;5;196;38;5;226:tw=48;5;10;38;5;16:ow=48;5;10;38;5;21:st=48;5;21;38;5;15:ex=38;5;34:*.tar=38;5;9:*.tgz=38;5;9:*.arc=38;5;9:*.arj=38;5;9:*.taz=38;5;9:*.lha=38;5;9:*.lz4=38;5;9:*.lzh=38;5;9:*.lzma=38;5;9:*.tlz=38;5;9:*.txz=38;5;9:*.tzo=38;5;9:*.t7z=38;5;9:*.zip=38;5;9:*.z=38;5;9:*.Z=38;5;9:*.dz=38;5;9:*.gz=38;5;9:*.lrz=38;5;9:*.lz=38;5;9:*.lzo=38;5;9:*.xz=38;5;9:*.bz2=38;5;9:*.bz=38;5;9:*.tbz=38;5;9:*.tbz2=38;5;9:*.tz=38;5;9:*.deb=38;5;9:*.rpm=38;5;9:*.jar=38;5;9:*.war=38;5;9:*.ear=38;5;9:*.sar=38;5;9:*.rar=38;5;9:*.alz=38;5;9:*.ace=38;5;9:*.zoo=38;5;9:*.cpio=38;5;9:*.7z=38;5;9:*.rz=38;5;9:*.cab=38;5;9:*.jpg=38;5;13:*.jpeg=38;5;13:*.gif=38;5;13:*.bmp=38;5;13:*.pbm=38;5;13:*.pgm=38;5;13:*.ppm=38;5;13:*.tga=38;5;13:*.xbm=38;5;13:*.xpm=38;5;13:*.tif=38;5;13:*.tiff=38;5;13:*.png=38;5;13:*.svg=38;5;13:*.svgz=38;5;13:*.mng=38;5;13:*.pcx=38;5;13:*.m
```

### **ARGC**   
The number of command line arguments
### **ARGV**        
Array of command line arguments
```bash
$ awk 'BEGIN{print ARGC}' n=1
2

$ awk 'BEGIN{print ARGC; for(i=0; i<ARGC; i++){printf("%d: %s\n", i, ARGV[i])}}' n=1
2
0: awk
1: n=1
```

## Operators

| **<** | Less than |    
| **>** | Greater than |  
| **<=** | Less than or equal to >= Greater than or equal to == Equal to |  
| **!=** | Not equal to |  
| **~**  | Matches |  
| **!~** | Does not match |  
| **\|\|** | Logical OR |  
| **&&** | Logical AND |  
| **!** | Logical NOT |  

Precedence for operators   

| Precedence | Operators | Notes |  
| ------------: | :------------ | :------------ |  
| 1 | (…) | Grouping |  
| 2 | $ | Field reference |  
| 3 | ++ -\- | Increment, decrement |  
| 4 | ^ ** | Exponentiation. These operators group right to left |  
| 5 | + - ! | Unary plus, minus, logical "not" |  
| 6 | * / % | Multiplication, division, remainder |  
| 7 | + - | Addition, subtraction |  
| 8 | String concatenation | [Note 1](#note-1) |
| 9 | < <= == != > >= >> \| \|& | Relational and redirection [Note 2](#note-2) |  
| 10 | ~ !~ | Matching, nonmatching |  
| 11 | in | Array membership |  
| 12 | && | Logical "and" |  
| 13 | \|\| | Logical "or" |  
| 14 | ?: | Conditional. This operator groups right to left |  
| 15 | = += -= *= /= %= ^= **= | Assignment. These operators group right to left |  

###### Note 1   
There is no special symbol for concatenation. The operands are simply written side by side.  
###### Note 2 
The relational operators and the redirections have the same precedence level. Characters such as '>' serve both as relationals and as redirections; the context distinguishes between the two meanings. Note that the I/O redirection operators in print and printf statements belong to the statement level, not to expressions. The redirection does not produce an expression that could be the operand of another operator. As a result, it does not make sense to use a redirection operator near another operator of lower precedence without parentheses. Such combinations (e.g., 'print foo > a ? b : c') result in syntax errors. The correct way to write this statement is 'print foo > (a ? b : c)'.

## Array sorting   
### `"@unsorted"`   
Array elements are processed in arbitrary order, which is the default awk behavior.

### `"@ind_str_asc"`   
Order by indices in ascending order compared as strings. (Internally, array indices are always strings, so with ‘a[2*5] = 1’ the index is "10" rather than numeric 10.)

### `"@ind_num_asc"`   
Order by indices in ascending order but force them to be treated as numbers in the process. Any index with a non-numeric value will end up positioned as if it were zero.

### `"@val_type_asc"`    
Order by element values in ascending order. Ordering is by the type: numeric values; string values; all subarrays.

### `"@val_str_asc"`   
Order by element values in ascending order. Scalar values are compared as strings. If the string values are identical, the index string values are compared instead. When comparing non-scalar values, "@val_type_asc" sort ordering is used, so subarrays, if present, come out last.

### `"@val_num_asc"`   
Order by element values in ascending order. Scalar values are compared as numbers. Non-scalar values are compared using "@val_type_asc" sort ordering, so subarrays, if present, come out last. When numeric values are equal, the string values are used to provide an ordering. If the string values are also identical, the index string values are compared instead.

### `"@ind_str_desc"`   
 Like `"@ind_str_asc"`, but the string indices are ordered from high to low.

### `"@ind_num_desc"`     
Like `"@ind_num_asc"`, but the numeric indices are ordered from high to low.

### `"@val_type_desc"`     
Like `"@val_type_asc"`, but the element values, based on type, are ordered from high to low. Subarrays, if present, come out first.

### `"@val_str_desc"`        
Like "@val_str_asc", but the element values, treated as strings, are ordered from high to low. If the string values are identical, the index string values are compared instead. When comparing non-scalar values, `"@val_type_desc"` sort ordering is used, so subarrays, if present, come out first.

### `"@val_num_desc"`    
Like `"@val_num_asc"`, but the element values, treated as numbers, are ordered from high to low. If the numeric values are equal, the string values are compared instead. If they are also identical, the index string values are compared instead. Non-scalar values are compared using `"@val_type_desc"` sort ordering, so subarrays, if present, come out first.    

```bash
$ awk 'BEGIN{array[1]="a"; array[2]="c"; array[3]="b"; array[4]=0; PROCINFO["sorted_in"] = "@ind_num_desc"; for(x in array) print x, array[x]}'
4 0
3 b
2 c
1 a

$ awk 'BEGIN{array[1]="a"; array[2]="c"; array[3]="b"; array[4]=0; PROCINFO["sorted_in"] = "@val_num_asc"; for(x in array) print x, array[x]}'
4 0
1 a
3 b
2 c
```

## Multidimensional Arrays
A `multidimensional array` is an array in which an element is identified by two or more indices. For example, a two-dimensional array element is similar as grid[x,y].   
Multidimensional arrays are supported in `awk` through `concatenation` of indices into one string. awk converts the indices into strings and concatenates them together with a default separator (`SUBSEP` / `\034`). 

```bash
$ awk 'BEGIN{print SUBSEP}'  | sed -n 'l'
\034$

$ awk 'BEGIN{a[1, 2]; for (x in a)print x}' | sed -n 'l'
1\0342$
```

To iterate over a `multidimensional array`   
```bash
$ cat awk
BEGIN {
  a[1, 2] = "the first element"
  a[3, 4] = "the second element"
  a[5, 6] = "the third element"

  PROCINFO["sorted_in"] = "@ind_num_asc"
  for (x in a) {
    split(x, indices, SUBSEP)
    print indices[1], indices[2], a[indices[1], indices[2]]
  }
}

$ awk -f awk
1 2 the first element
3 4 the second element
5 6 the third element
```

## Functions

### Numberic Functions

<div id="toc" style="">
   <ul>
      <li><a href="#expx">exp(x)</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#intx">int(x)</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#logx">log(x)</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#rand">rand()</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#sqrtx">sqrt(x)</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
   </ul>
</div>

#### **exp(x)**    
Return the exponential of x (e ^ x) or report an error if x is out of range.

#### **int(x)**    
Return the nearest integer to x.

#### **log(x)**    
Return the natural logarithm of x, if x is positive; otherwise, return NaN (“not a number”) on IEEE 754 systems.

#### **rand()**    
Return a random number. The values of rand() are uniformly distributed between zero and one. The value could be zero but is never one.

#### **sqrt(x)**   
Return the positive square root of x.

### String Functions    
<div id="toc" style="">
   <ul>
      <li><a href="#backreferences-1">Backreferences</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#asort">asort</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#sub">sub</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#gensub">gensub</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#gsub">gsub</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#index">index</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#length">length</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#match">match</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#patsplit">patsplit</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#split">split</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#sprintf">sprintf</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#strtonum">strtonum</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#substr">substr</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#tolower--toupper">tolower / toupper</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
   </ul>
</div>


#### Backreferences
Backreferences of the form *\N* can only be used with *gensub* function. *&* can be used with *sub*, *gsub* and *gensub* functions. *\0* can also be used instead of *&* with *gensub* function.

#### asort
```bash
asort(source [, dest [, how ] ]) / asorti(source [, dest [, how ] ])
```
Both functions return the number of elements in the array *source*. For *asort()*, awk sorts the values of *source* and replaces the indices of the sorted values of *source* with sequential integers starting with one. If the optional array *dest* is specified, then *source* is duplicated into *dest*. *dest* is then sorted, leaving the indices of *source* unchanged. If the *source* array contains subarrays as values, they will come last, after all scalar values. Subarrays are not recursively sorted. 
The *asorti()* function works similarly to *asort()*; however, the indices are sorted, instead of the values.   
```bash
$ cat /tmp/test
last|de
first|sac
middle|cul

$ awk '{split($0, entry, "|"); source[entry[1]]=entry[2]} END{count=asort(source, dest); for (i=1; i<=count; i++) {print dest[i]}}' test
cul
de
sac

$ awk '{split($0, entry, "|"); source[entry[1]]=entry[2]} END{count=asorti(source, dest); for (i=1; i<=count; i++) {print dest[i]}}' test
first
last
middle
```

#### sub
```bash
sub(regexp, replacement [, target])
```
Search *target*, which is treated as a string, for the leftmost, longest substring matched by the regular expression *regexp*. Modify the entire string by replacing the matched text with *replacement*. The modified string becomes the new value of *target*. Return the number of substitutions made (zero/failure or one/success).   
The *regexp* argument may be either a regexp constant (/…/) or a string constant ("…"). In the latter case, the string is treated as a regexp to be matched.   
This function is peculiar because *target* is not simply used to compute a value, and not just any expression will do—it must be a variable, field, or array element so that sub() can store a modified value there. If this argument is omitted, then the default is to use and alter *$0*.  
```bash
$ awk 'BEGIN{test = "matrix"; result=sub("tri", "", test); print test; print result}'
max
1

$ awk 'BEGIN{test = "matrix"; result=sub("tria", "", test); print test; print result}'
matrix
0
```

If the special character *&* appears in replacement, it stands for the precise substring that was matched by *regexp*. If the *regexp* can match more than one string, then this precise substring may vary.  
```bash
$ awk 'BEGIN{test = "matrix"; result = sub(/matrix/, "& &", test); print test; print result}'
matrix matrix
1

$ cat /tmp/test
max
maxx

$ awk '{result = sub(/x+/, "& test"); print; print result}' /tmp/test
max test
1
maxx test
1
```

#### gensub
```bash
gensub(regexp, replacement, how [, target])
```
Search the *target* string target for matches of the regular expression *regexp*. If *how* is a string beginning with 'g' or 'G' (short for "global"), then replace all matches of *regexp* with *replacement*. Otherwise, treat *how* as a number indicating which match of *regexp* to replace. Treat numeric values less than one as if they were one. If no *target* is supplied, use *$0*. Return the modified string as the result of the function. The original target string is *not* changed.  
*gensub()* is a general substitution function. Its purpose is to provide more features than the standard *sub()* and *gsub()* functions.  
*gensub()* provides an additional feature that is not available in *sub()* or *gsub()*: the ability to specify components of a regexp in the replacement text. This is done by using parentheses in the regexp to mark the components and then specifying *'\N'* in the replacement text, where *N* is a digit from 1 to 9.  
```bash
$ awk 'BEGIN{test="max zou max"; dest = gensub(/m.x/, "matrix", "1", test); print dest}'
matrix zou max
```

#### gsub
```bash
gsub(regexp, replacement [, target])
```
Search *target* for all of the longest, leftmost, nonoverlapping matching substrings it can find and replace them with replacement. The 'g' in gsub() stands for "global", which means replace everywhere.   
The *gsub()* function returns the number of substitutions made. If the variable to search and alter ( *target* ) is omitted, then the entire input record ( *$0* ) is used.   
```bash
$ awk 'BEGIN{test="matrix matrix"; count = gsub(/matrix/, "zou", test); print test; print count}'
zou zou
2

$ awk 'BEGIN{test="matrix matrix"; count = gsub(/matrix/, "[&] test", test); print test; print count}'
[matrix] test [matrix] test
2
```

#### index
```bash
index(string, target_string)
```
Search the string *string* for the first occurrence of the string *target_string*, and return the position in characters where that occurrence begins in the string *string*.   
```bash
$ awk 'BEGIN{print index("matrix matrix", " matrix")}'                        
7

$ awk 'BEGIN{print index("matrix matrix", "  matrix")}'
0

$ awk 'BEGIN{print index("matrix matrix", "matrix")}'                         
1
```

#### length
```bash
length([string])
```
Return the number of characters in *string*. If no argument is supplied, *length()* returns the length of *$0*. When given an array argument, the *length()* function returns the number of elements in the array.  
```bash
$ awk 'BEGIN{test = "matrix"; print length(test)}'
6

$ awk 'BEGIN{test[1] = "matrix"; test[2] = "zou"; print length(test)}'
2
```

#### match
```bash
match(string, regexp [, array])
```
Search *string* for the longest, leftmost substring matched by the regular expression *regexp* and return the character position (index) at which that substring begins (one, if it starts at the beginning of *string*). If no match is found, return zero.
The *regexp* argument may be either a regexp constant (/…/) or a string constant ("…").  
The order of the first two arguments is the opposite of most other string functions that work with regular expressions, such as *sub()* and *gsub()*. It might help to remember that for *match()*, the order is the same as for the *~* operator: *string ~ regexp*.  
The match() function sets the predefined variable *RSTART* to the index. It also sets the predefined variable *RLENGTH* to the length in characters of the matched substring. If no match is found, *RSTART* is set to zero, and *RLENGTH* to -1.   
```bash
$ awk 'BEGIN{test = "matrix"; print match(test, /t.*x/); print RLENGTH, RSTART}'
3
4 3
```

```bash
$ awk 'BEGIN{test = "matrix zou"; match(test, /(m.*x) (z.*u)/, array); count=length(array); for(i = 0; i<=2; i++)print array[i]}'
matrix zou
matrix
zou
```

If *array* is present, it is cleared, and then the firth (0) element of *array* is set to the entire portion of *string* matched by *regexp*. If *regexp* contains parentheses, the integer-indexed elements of *array* are set to contain the portion of *string* matching the corresponding parenthesized subexpression.   
```bash
$ awk 'BEGIN{test = "matrix"; if(match(test, /t.*x/, array)){for (i in array) printf("index: %s, value: %s\n", i, array[i])}}'
index: 0start, value: 3
index: 0length, value: 4
index: 0, value: trix
```

In addition, multidimensional subscripts are available providing the start index and length of each matched subexpression:    
```bash
$ awk 'BEGIN{test = "matrix zou"; match(test, /(m.*x) (z.*u)/, array); for (x in array)print x, array[x]}'
0start 1
0length 10
1start 1
2start 8
0 matrix zou
1 matrix
2 zou
2length 3
1length 6
```

#### patsplit
```bash
patsplit(string, array [, regexp [, seps ] ])
```
Search *regexp* in *string* and store the pieces in *array* and the separator strings in the *seps* array. The first piece is stored in *array[1]*, the second piece in *array[2]*, and so forth. The third argument, *fieldpat*, is a regexp describing the fields in *string*. It may be either a regexp constant or a string. If *regexp* is omitted, the value of FPAT is used. *patsplit()* returns the number of elements created. *seps[i]* is the possibly null separator string after *array[i]*.     
```bash
$ awk 'BEGIN{patsplit("matrix|zou", a, /[a-z]*/, seps); print "array result:"; for(i=1;i<=length(a);i++)print a[i]; print length(a); print "seperator result:"; for(j=0;j<length(seps);j++) print seps[j]; print length(seps)}'
array result:
matrix
zou
2
seperator result:

|
2

$ awk 'BEGIN{patsplit("matrix|zou", a, /[^|]*/, seps); print "array result:"; for(i=1;i<=length(a);i++)print a[i]; print length(a); print "seperator result:"; for(j=0;j<length(seps);j++) print seps[j]; print length(seps)}'
array result:
matrix
zou
2
seperator result:

|
2
```
NOTE: *regexp [^|]* refers to everything except *|* 

The possibly null leading separator will be in *seps[0]*. So a non-null string with *n* fields will have *n+1* separators.   
```bash
$ echo test- | awk '{patsplit($0, result, /\w+/, seps); for (x in result) print x, result[x]; for (y in seps) print y, seps[y]}'
1 test
0
1 -

$ echo -test- | awk '{patsplit($0, result, /\w+/, seps); for (x in result) print x, result[x]; for (y in seps) print y, seps[y]}'
1 test
0 -
1 -
```

#### split
```bash
split(string, array  [, regexp [, seps ] ])
```
Divide *string* into pieces separated by *regexp* and store the pieces in *array* and the separator strings in the *seps* array.  The first piece is stored in *array[1]*, the second piece in *array[2]*, and so forth. The string value of the third argument, *regexp*, is a regexp describing where to split *string*. If *regexp* is omitted, the value of FS is used. *split()* returns the number of elements created. *seps* is a gawk extension, with *seps[i]* being the separator string between *array[i]* and *array[i+1]*. If *regexp* is a single space, then any leading whitespace goes into *seps[0]* and any trailing whitespace goes into *seps[n]*, where *n* is the return value of *split()* (i.e., the number of elements in array).    
The split() function splits strings into pieces in the same way that input lines are split into fields.    
```bash
$ awk 'BEGIN{split("matrix|zou", a, /[|]/, seps); print "array result:"; for(i=1;i<=length(a);i++)print a[i]; print length(a); print "seperator result:"; for(j=0;j<length(seps);j++) print seps[j]; print length(seps)}'
array result:
matrix
zou
2
seperator result:

|
2

$ awk 'BEGIN{split("matrix|zou", a, "|", seps); print "array result:"; for(i=1;i<=length(a);i++)print a[i]; print length(a); print "seperator result:"; for(j=0;j<length(seps);j++) print seps[j]; print length(seps)}'
array result:
matrix
zou
2
seperator result:

|
2
```
NOTE: Index for list `array` is started from `1`, and index for list `seps` is also started from `0`

For the `string` will be splitted, if `fieldsep` is on the start of `string`, `array[1]` will be an `empty` result. It will be similar if `fieldsep` is in the end of `string`
```bash
$ echo -test- | awk '{split($0, result, /-/, seps); for (x in result) print x, result[x]; for (y in seps) print y, seps[y]}'
1
2 test
3
1 -
2 -
```

#### sprintf
```bash
sprintf(format, expression1, …)
```
Return (without printing) the string that *printf* would have printed out with the same arguments. In fact, *sprintf* acts in exactly the same way as *printf*, except that *sprintf* assigns its output to a variable, not standard output.    
```bash
$ awk 'BEGIN{pival = sprintf("matrix is a good boy")}'

$ awk 'BEGIN{pival = sprintf("matrix is a good boy"); print pival}'
matrix is a good boy
```

#### strtonum
```bash
strtonum(str)
```
Examine *str* and return its numeric value. If *str* begins with a leading ‘0’, *strtonum()* assumes that str is an octal number. If *str* begins with a leading ‘0x’ or ‘0X’, *strtonum()* assumes that str is a hexadecimal number.    
```bash
$ awk 'BEGIN{val = "0x11"; print strtonum(val)}'
17
```

#### substr
```bash
substr(string, start [, length ])
```
Return a *length*-character-long substring of *string*, starting at character number *start*. The first character of a string is character number one. For example, substr("washington", 5, 3) returns "ing".    
If *length* is not present, *substr()* returns the whole suffix of string that begins at character number *start*. For example, substr("washington", 5) returns "ington". The whole suffix is also returned if *length* is greater than the number of characters remaining in the *string*, counting from character *start*.   
If *start* is less than one, *substr()* treats it as if it was one. If *start* is greater than the number of characters in the *string*, *substr()* returns the null string. Similarly, if *length* is present but less than or equal to zero, the null string is returned.     

#### tolower / toupper
```bash
tolower(string) / toupper(string)
```
Return a copy of *string*, with each uppercase/lowercase character in the *string* replaced with its corresponding lowercase/uppercase character. Nonalphabetic characters are left unchanged. For example, tolower("MiXeD cAsE 123") returns "mixed case 123", and toupper("MiXeD cAsE 123") returns "MIXED CASE 123". 

### IO Function
Important: `awk` also buffers its output, and buffer size by default is 4k
```bash
$ tail -F -n 0 /tmp/test | awk '{print $0}' | while read -r line; do echo $line; done
```
Inject `test\n` to file `/tmp/test` until there is some output
```bash
$ count=1; while [ $count -le 820 ]; do echo $((count++)); echo test >> /tmp/test ; done
```
If it is `819`, there will be no output

#### fflush
```bash
fflush()
```
Flush any buffered output 
```bash
$ tail -F -n 0 /tmp/test | awk '{print $0; fflush}' | while read -r line; do echo $line; done
```
Output will be always shown in console
Alternative way with `stdbuf`
```bash
$ tail -F -n 0 /tmp/test | stdbuf -oL awk '{print $0}' | while read -r line; do echo $line; done
```

### Customised Function
```bash
function name (parameter-list) {
	statements
}
```

Examples    
```bash
$ cat insert.awk
# insert.awk - insert characters on position

function insert(STRING, POS, INS) {
    before = substr(STRING, 1, POS)
    after = substr(STRING, POS+1)
    new_STRING = sprintf("%s%s%s", before, INS, after)
    return new_STRING
}

BEGIN {
    print insert("matrix", position, insertion)
}

$ awk -v position=2 -v insertion=" " -f insert.awk
ma trix

$ cat ~/insert.awk
# insert.awk - insert characters on position

function insert(STRING, POS, INS) {
    before = substr(STRING, 1, POS)
    after = substr(STRING, POS+1)
    return before INS after
}

BEGIN {
    print insert("matrix", position, insertion)
}

$ awk -v position=3 -v insertion=' good ' -f ~/insert.awk
mat good rix
```

## Multiple File Input   
*BEGINFILE* — this block gets executed before start of each input file  
*ENDFILE*  — this block gets executed after processing each input file  
*FILENAME* — special variable having file name of current input file  
*nextfile* - skip remaining records from the current file being processed and move on to the next file  

## `$1 = $1`    
force record to be reconstituted

## Examples   
### Show Duplicated Lines   
```bash
$ cat /tmp/test
test
test1
test2
test2
test3

$ awk 'a[$0]++ {b[$0]}; END{for (i in b) print i}' /tmp/test
test2

$ cat show_dup.awk
# put entry counts 2+ in array `b`, but count 3 and more will overwrite previous
a[$0]++ {
  b[$0]
}

# iterate array `b`
END {
  for (i in b) print i
}

$ awk -f show_dup.awk /tmp/test
test2
test3
```
 
{% include links.html %} 