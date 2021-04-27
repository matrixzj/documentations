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




{% include links.html %}
