---
title: awk
tags: [bash]
keywords: awk 
last_updated: Mar 5, 2021
summary: "awk tips"
sidebar: mydoc_sidebar
permalink: bash_awk.html
folder: bash
---

# awk
=====

## System Variables

* **FS**    field separator. By default, its value is a single space. FS can also be set to any single character, or to a regular expression.
* **OFS**   output field separator. By default awk OFS is a single space character.   

```bash
$ echo "matrix" | awk 'BEGIN{FS="tr"}{print $1}'
ma

$ echo "matrix" | awk 'BEGIN{FS="tr"}{print $1, $2}'
ma ix

$ echo "matrix" | awk 'BEGIN{FS="tr";OFS="\n"}{print $1, $2}'
ma
ix
```

* **RS**    record separator. By default, its value is a newline.  
* **ORS**   output record separator. By default, its value is a newline.   

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


* **NF**    number of fields for the current input record.  
* **NR**    number of records being processed or line number.     

```bash
$ echo "a|b|c" | awk 'BEGIN{FS="|"}{print NF}'
3

$ echo "a|b|c" | awk 'BEGIN{RS="|"}{print NR}'
1
2
3
```

* **FILENAME** the name of the file being read     

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

* **FNR**   Number of Records relative to the current input file    

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

* **CONVFMT**   number-to-string conversions. By default, the value is '%.6g'
* **OFMT**      string-to-number conversions. By default, the value is '%.6g'    

```bash
$ awk -v OFMT="%d" 'BEGIN{print str = (5.5 + 3.2)}'
8

$ echo 0.77767686 |  awk '{ print "" 0+$0 }' OFMT='%.1g'
0.777677

$ echo 0.77767686 |  awk '{ print "" 0+$0 }' CONVFMT='%.1g'
0.8
```

## Functions
### Numeric Functions
* **exp(x)**    Return the exponential of x (e ^ x) or report an error if x is out of range.
* **int(x)**    Return the nearest integer to x.
* **log(x)**    Return the natural logarithm of x, if x is positive; otherwise, return NaN (“not a number”) on IEEE 754 systems.
* **rand()**    Return a random number. The values of rand() are uniformly distributed between zero and one. The value could be zero but is never one.
* **sqrt(x)**   Return the positive square root of x.

### String Functions
#### asort(source [, dest [, how ] ]) / asorti(source [, dest [, how ] ])   
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

#### gensub(regexp, replacement, how [, target])
Search the *target* string target for matches of the regular expression *regexp*. If *how* is a string beginning with 'g' or 'G' (short for "global"), then replace all matches of *regexp* with *replacement*. Otherwise, treat *how* as a number indicating which match of *regexp* to replace. Treat numeric values less than one as if they were one. If no *target* is supplied, use *$0*. Return the modified string as the result of the function. The original target string is *not* changed.
*gensub()* is a general substitution function. Its purpose is to provide more features than the standard *sub()* and *gsub()* functions.
*gensub()* provides an additional feature that is not available in *sub()* or *gsub()*: the ability to specify components of a regexp in the replacement text. This is done by using parentheses in the regexp to mark the components and then specifying *'\N'* in the replacement text, where *N* is a digit from 1 to 9.  
```bash
$ awk 'BEGIN{test="max zou max"; dest = gensub(/m.x/, "matrix", "1", test); print dest}'
matrix zou max
```



{% include links.html %}
