---
title: sed
tags: [bash]
keywords: sed
last_updated: Dec 4, 2020
summary: "sed tips"
sidebar: mydoc_sidebar
permalink: bash_sed.html
folder: bash
---

# sed

## How `sed' Works

`sed` maintains two data buffers: the active `pattern` space, and the auxiliary `hold` space. Both are initially empty.
`sed` operates by performing the following cycle on each line of input: first, `sed` reads one line from the input stream, removes any trailing newline, and places it in the `pattern` space. Then commands are executed; each command can have an address associated to it: addresses are a kind of condition code, and a command is only executed if the condition is verified before the command is to be executed.

 When the end of the script is reached, unless the `-n` option is in use, the contents of `pattern` space are printed out to the output stream, adding back the trailing newline. Then the next cycle starts for the next input line.

Unless special commands (like `D`) are used, the pattern space is deleted between two cycles. The hold space, on the other hand, keeps its data between cycles (see commands `h`, `H`, `x`, `g`, `G` to move n data between both buffers).

## Special Characters during replace

### `&` 
Replaced by the string matched by the regular expression
```bash
$ echo 'test test' | sed -e 's/[[:alpha:]]\+/(&)/'
(test) test

$ echo 'Matrix Zou' | sed -e '/[[:alpha:]]\+/s//This is &/'
This is Matrix Zou
```

### `\` 
Matches the nth substring (n is a single digit) previously specified in the pattern using “\(” and “\)”.
```bash
$ echo 'test test' | sed -e 's/\([[:alpha:]]\+\)/(\1)/'
(test) test

$ echo 'test1 test2' | sed -re 's/([[:alpha:]]+[0-9]) ([[:alpha:]]+[0-9])/(\2) (\1)/'
(test2) (test1)
```

### `\L` / `\U` 
Replaced processing string to lower/upper case
```bash
$ echo 'test1 test2' | sed -E 's/([[:alpha:]])/\U\1/'
Test1 test2

$ echo 'test1 test2' | sed -E 's/[[:alpha:]]+/\U&/'
TEST1 test2

$ echo 'tEST1 test2' | sed -E 's/(....)/\L\1/'
test1 test2
```

### `I`
Matchs case-insensitive 
```bash
$ echo 'Hello' | sed -e 's/hello/Matrix/I'
Matrix
```

## Commands

### `a` / `i` / `c` / `d` 
`a` appends a line after every line with the address or pattern  
`i` insert a line before every line with the range or pattern  
`c` change the range or pattern with provided string  
`d` delete  a line or every line with the range or pattern  

```bash
$ echo 'Matrix' | sed -E '/[[:alpha:]]+/a\Zou'
Matrix
Zou

$ echo 'Matrix' | sed -E '/[[:alpha:]]+/i\Zou'
Zou
Matrix

$ echo 'Matrix' | sed -E '/Matrix/c\Zou'
Zou

$ printf 'Matrix\nZou\n'  | sed '/M/d'
Zou
```

### `l` 
displays the contents of the pattern space, showing non-printing characters as two-digit ASCII codes
```bash
$ cat /tmp/test  | sed -n -e  'l'
The Great \033 is a movie starring Steve McQueen.$
\033$
```

### `y` 
transforms each character by position in string `abc` to its equivalent in string `xyz`
```bash
$ echo 'test'  | sed -e 'y/tes/abc/'
abca
```

### `=` 
prints the line number of the matched line
```bash
$ echo 'test'  | sed -e '='
1
test
```

### `r` / `w` 
`r` read content of file into the `pattern` space  
`w` write the contents of `pattern` to the file  
```bash
$ cat /tmp/source
1
2
3

$ cat /tmp/target
4
5
6

$ sed -E '/2/r /tmp/target' /tmp/source
1
2
4
5
6
3

$ sed -E '/[[:digit:]]/w /tmp/test' /tmp/source
1
2
3

$ cat /tmp/test
1
2
3
```

### `q`
stop reading new input lines (and stop sending them to the output)
```bash
$ cat test
Adams, Henrietta        Northeast
Banks, Freda            South
Dennis, Jim             Midwest
Garvey, Bill            Northeast
Jeffries, Jane          West
Madison, Sylvia         Midwest
Sommes, Tom             South

!274 $ cat test | sed -E '/Northeast/q'
Adams, Henrietta        Northeast
```

## Advanced sed commands

### `n` / `N`
`n` outputs the contents of the pattern space and then reads the next line of input without returning to the top of the script. In effect, the next command causes the next line of input to replace the current line in the pattern space. Subsequent commands in the script are applied to the replacement line, not the current line. If the default output has not been suppressed, the current line is printed before the replacement takes place.  
`N` creates a multiline pattern space by reading a new line of input and appending it to the contents of the pattern space. The original contents of pattern space and the new input line are separated by a newline. The embedded newline character can be matched  in patterns by the escape sequence "\n". In a multiline pattern space, the metacharacter "^" matches the very first character of the pattern space, and not the character(s) following any embedded newline(s). Similarly, "$: matches only the final newline in the pattern space, and not any embedded newline(s). After the Next command is executed, control is then passed to subsequent commands in the script.

```bash
 $ ifconfig lo0
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
        options=1203<RXCSUM,TXCSUM,TXSTATUS,SW_TIMESTAMP>
        inet 127.0.0.1 netmask 0xff000000
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1
        nd6 options=201<PERFORMNUD,DAD>

$ ifconfig lo0 | sed -e '/lo0/{/flags/d}'
        options=1203<RXCSUM,TXCSUM,TXSTATUS,SW_TIMESTAMP>
        inet 127.0.0.1 netmask 0xff000000
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1
        nd6 options=201<PERFORMNUD,DAD>

$ ifconfig lo0 | sed -e '/lo0/{n; /flags/d}'
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
        options=1203<RXCSUM,TXCSUM,TXSTATUS,SW_TIMESTAMP>
        inet 127.0.0.1 netmask 0xff000000
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1
        nd6 options=201<PERFORMNUD,DAD>

$ ifconfig lo0 | sed -e '/lo0/{N; /flags/d}'
        inet 127.0.0.1 netmask 0xff000000
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x1
        nd6 options=201<PERFORMNUD,DAD>
```

### `d` / `D`
`d` deletes the contents of the pattern space and causes a new line of input to be read, with editing resuming at the top of the script.   
`D` deletes a portion of the pattern space, up to the first embedded newline. It does not cause a new line of input to be read; instead, it returns to the top of the script, applying these instructions to what remains in the pattern space.   
```bash
$ cat test_text
This line is followed by 1 blank line.

This line is followed by 2 blank lines.


This line is followed by 3 blank lines.



This line is followed by 4 blank lines.




This is the end.


$ cat test_text | sed -e '/^$/{N;/\n$/d}'
This line is followed by 1 blank line.

This line is followed by 2 blank lines.
This line is followed by 3 blank lines.

This line is followed by 4 blank lines.
This is the end.


$ cat test_text | sed -e '/^$/{N;/\n$/D}'
This line is followed by 1 blank line.

This line is followed by 2 blank lines.

This line is followed by 3 blank lines.

This line is followed by 4 blank lines.

This is the end.
```

### `p` / `P`
`p` outputs whole pattern space. It does not clear the pattern space nor does it change the flow of control in the script.   
`P` outputs the first portion of a multiline pattern space, up to the first embedded newline.  
```bash
$ ifconfig lo0 | sed -ne '/lo0:/{N; p}'
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
        options=1203<RXCSUM,TXCSUM,TXSTATUS,SW_TIMESTAMP>

$ ifconfig lo0 | sed -ne '/lo0:/{N; P}'
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
```

## Advanced Commands related with `hold` space

### `h` / `H`
`h` copys contents of `pattern` space to `hold` space, `hold` space will be overwritten by copied contents.  
`H` appends contents of `pattern` space to `hold` space.  

### `g` / `G`
`g` copy contents of `hold` space to `pattern` space, `pattern` space will be overwritten by copied contents.  
`G` appends contents of `hold` space to `pattern` space.  

### `x`
`x` swaps contents of `hold` space and `pattern` space.

```bash
$ cat /tmp/test
1
2

$ cat number.sed
/1/ {
    h
    d
}
/2/ {
    G
}

$ sed -f number.sed /tmp/test
2
1
```

Explanation:
```bash
$ ./sedsed.py -d -f number.sed /tmp/test
PATT:1$
HOLD:$
COMM:/1/ {
COMM:h
PATT:1$
HOLD:1$
COMM:d
PATT:2$
HOLD:1$
COMM:/1/ {
COMM:/2/ {
COMM:G
PATT:2\n1$
HOLD:1$
COMM:}
PATT:2\n1$
HOLD:1$
2
1
```

## Branch Commands 
`b` refers to `branch` command, which transfers control unconditionally in a script to a line containing a specified label. If no label is specified, control passes to the end of the script  
`t` refers to `test` command, occurring only if a substitute command has changed the current line, conditionally transfer control in a script to a line containing a specified label. If no label is specified, control passes to the end of the script. 

```bash
 $ ifconfig
ens3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9000
        inet 10.0.0.4  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 fe80::17ff:fe00:59b6  prefixlen 64  scopeid 0x20<link>
        ether 02:00:17:00:59:b6  txqueuelen 1000  (Ethernet)
        RX packets 2232164  bytes 7140983864 (6.6 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1681954  bytes 905209876 (863.2 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 5065  bytes 985987 (962.8 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 5065  bytes 985987 (962.8 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


$ ifconfig | sed -e '/^[[:alpha:]]/{:a;N;s/\n\s\+/\n/;t a;q}'
ens3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9000
inet 10.0.0.4  netmask 255.255.255.0  broadcast 10.0.0.255
inet6 fe80::17ff:fe00:59b6  prefixlen 64  scopeid 0x20<link>
ether 02:00:17:00:59:b6  txqueuelen 1000  (Ethernet)
RX packets 2232185  bytes 7140985554 (6.6 GiB)
RX errors 0  dropped 0  overruns 0  frame 0
TX packets 1681967  bytes 905212914 (863.2 MiB)
TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


$ ifconfig | sed -ne '/^[[:alpha:]]/{:a;N;/\n$/!{ba};p;q}'
ens3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 9000
        inet 10.0.0.4  netmask 255.255.255.0  broadcast 10.0.0.255
        inet6 fe80::17ff:fe00:59b6  prefixlen 64  scopeid 0x20<link>
        ether 02:00:17:00:59:b6  txqueuelen 1000  (Ethernet)
        RX packets 2232219  bytes 7140993050 (6.6 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1681993  bytes 905255387 (863.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```

```bash
$ cat /tmp/python.txt
Python is a very popular language.
Python is easy to use. Python is easy to learn.
Python is a cross-platform language.
Python is easy to use. Python is easy to learn.

$ sed 's/Python/Go/2;t' /tmp/python.txt  | sed '/Go/d'
Python is a very popular language.
Python is a cross-platform language.
```

## Examples

### replace in a specific range

#### replace specific lines match pattern
```bash
$ sudo grep net /etc/sysctl.conf
net.ipv4.ip_forward = 1

$ sudo sed -ne '/^net/s/1/0/p' /etc/sysctl.conf
net.ipv4.ip_forward = 0
```

#### replace lines in a range
```bash
$ awk '{if(NR==12)print}' /etc/sysctl.conf
net.ipv4.ip_forward = 1

$ sed -ne '12s/1/0/p' /etc/sysctl.conf
net.ipv4.ip_forward = 0
```

#### replace the 2nd occurance
```bash
$ echo 'Python Python' | sed -e 's/Python/Go/2'
Python Go
```

#### get a specific block 
Show info of `eth0` via `ifconfig` 
```bash
$ ifconfig | sed -ne '/^eth0/{:a;N;/\s$/!{ba};p}'
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1460
        inet 10.0.0.2  netmask 255.255.255.255  broadcast 10.0.0.2
        inet6 fe80::4001:aff:febb:2  prefixlen 64  scopeid 0x20<link>
        ether 42:01:0a:aa:00:02  txqueuelen 1000  (Ethernet)
        RX packets 16363747  bytes 9653164453 (8.9 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 15504492  bytes 10165112383 (9.4 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```

#### print the last 5 lines of a file
similar as `tail -n 5`
```bash
$ cat /tmp/test
aa
bb
cc
dd
ee
ff
gg

$ cat /tmp/test | sed -ne '$p;:a;N;6,$D;$!{ba}'
cc
dd
ee
ff
gg
```

#### reverse order of lines
same as `tac`
```bash
$ cat /tmp/test1
aa
bb
cc

$ cat /tmp/test1 | sed '1!G;h;$!d'
cc
bb
aa
```

#### reverse all characters for a line
same as `rev`
```bash
$ echo 'max' | sed '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//'
xam

$ echo 'max' | ./sedsed.py -d -e '/\n/!G;s/\(.\)\(.*\n\)/&\2\1/;//D;s/.//'
Pattern Space: max$
Hold Space   : $
Command      : /\n/ !G
Pattern Space: max\n$
Hold Space   : $
Command      : s/\(.\)\(.*\n\)/&\2\1/
Pattern Space: max\nax\nm$
Hold Space   : $
Command      : // D
Pattern Space: ax\nm$
Hold Space   : $
Command      : /\n/ !G
Pattern Space: ax\nm$
Hold Space   : $
Command      : s/\(.\)\(.*\n\)/&\2\1/
Pattern Space: ax\nx\nam$
Hold Space   : $
Command      : // D
Pattern Space: x\nam$
Hold Space   : $
Command      : /\n/ !G
Pattern Space: x\nam$
Hold Space   : $
Command      : s/\(.\)\(.*\n\)/&\2\1/
Pattern Space: x\n\nxam$
Hold Space   : $
Command      : // D
Pattern Space: \nxam$
Hold Space   : $
Command      : /\n/ !G
Pattern Space: \nxam$
Hold Space   : $
Command      : s/\(.\)\(.*\n\)/&\2\1/
Pattern Space: \nxam$
Hold Space   : $
Command      : // D
Pattern Space: \nxam$
Hold Space   : $
Command      : s/.//
Pattern Space: xam$
Hold Space   : $
xam
```

{% include links.html %}
