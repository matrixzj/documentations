---
title: sed
tags: [bash]
keywords: sed
last_updated: Nov 14, 2020
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

### `&` Replaced by the string matched by the regular expression
```bash
$ echo 'test test' | sed -e 's/[[:alpha:]]\+/(&)/'
(test) test
```

### `\` Matches the nth substring (n is a single digit) previously specified in the pattern using “\(” and “\)”.
```bash
$ echo 'test test' | sed -e 's/\([[:alpha:]]\+\)/(\1)/'
(test) test

$ echo 'test1 test2' | sed -re 's/([[:alpha:]]+[0-9]) ([[:alpha:]]+[0-9])/(\2) (\1)/'
(test2) (test1)
```

### `\L` / `\U` Replaced processing string to lower/upper case
```bash
$ echo 'test1 test2' | sed -E 's/([[:alpha:]])/\U\1/'
Test1 test2

$ echo 'test1 test2' | sed -E 's/[[:alpha:]]+/\U&/'
TEST1 test2

$ echo 'tEST1 test2' | sed -E 's/(....)/\L\1/'
test1 test2
```

## commands in `sed`

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

### `n` / `N`
`n` outputs the contents of the pattern space and then reads the next line of input without returning to the top of the script. In effect, the next command causes the next line of input to replace the current line in the pattern space. Subsequent commands in the script are applied to the replacement line, not the current line. If the default output has not been suppressed, the current line is printed before the replacement takes place.
`N` creates a multiline pattern space by reading a new line of input and appending it to the contents of the pattern space. The original contents of pattern space and the new input line are separated by a newline. The embedded newline character can be matched  in patterns by the escape sequence "\n". In a multiline pattern space, the metacharacter "^" matches the very first character of the pattern space, and not the character(s) following any embedded newline(s). Similarly, "$: matches only the final newline in the pattern space, and not any embedded newline(s). After the Next command is executed, control is then passed to subsequent commands in the script.

```bash
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
`d` deletes the contents of the pattern space and causes a new line of input to be read with editing resuming at the top of the script. 
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

### `l` displays the contents of the pattern space, showing non-printing characters as two-digit ASCII codes
```bash
$ cat /tmp/test  | sed -n -e  'l'
The Great \033 is a movie starring Steve McQueen.$
\033$
```

### `y` transforms each character by position in string `abc` to its equivalent in string `xyz`
```bash
$ echo 'test'  | sed -e 'y/tes/abc/'
abca
```

### `=` prints the line number of the matched line
```bash
$ echo 'test'  | sed -e '='
1
test
```


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

### get a specific block 

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

{% include links.html %}
