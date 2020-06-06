---
title: Python Sed Debug
tags: [python]
keywords: python, sed
last_updated: June 6, 2020
summary: "Sed Debug Tool to show pattern/hold space"
sidebar: mydoc_sidebar
permalink: python_sed_debug.html
folder: python
---


# Python Sed Debug
=====

## Script
[sedsed](images/python/sed_debug/sedsed.py)

## Usage
```bash
$ ./sedsed.py -h

Usage: sedsed OPTION [-e sedscript] [-f sedscriptfile] [inputfile]

OPTIONS:

     -f, --file          add file contents to the commands to be parsed
     -e, --expression    add the script to the commands to be parsed
     -n, --quiet         suppress automatic printing of pattern space
         --silent        alias to --quiet

     -d, --debug         debug the sed script
         --hide          hide some debug info (options: PATT,HOLD,COMM)
         --color         shows debug output in colors (default: ON)
         --nocolor       no colors on debug output
         --dump-debug    dumps to screen the debugged sed script

         --emu           emulates GNU sed (INCOMPLETE)
         --emudebug      emulates GNU sed debugging the sed script (INCOMPLETE)

     -i, --indent        script beautifier, prints indented and
                         one-command-per-line output do STDOUT
         --prefix        indent prefix string (default: 4 spaces)

     -t, --tokenize      script tokenizer, prints extensive
                         command by command information
     -H, --htmlize       converts sed script to a colorful HTML page

     -V, --version       prints the program version and exit
     -h, --help          prints this help message and exit


NOTE: The --emu and --emudebug options are still INCOMPLETE and must
      be used with care. Mainly regexes and address $ (last line)
      are not handled right by the emulator.

Website: http://aurelio.net/projects/sedsed/
```

## Example
```bash
$ cat report
ok: [test01.example.net] => {
    "msg": "3"
    test
}

$ sed -ne '/ok/{:a;N;/\}/!{ba};s/\n/\t/g;p}' /tmp/report
ok: [test01.example.net] => {      "msg": "3"      test        }

$ ./sedsed.py -d -ne '/ok/{:a;N;/\}/!{ba};s/\n/\t/g;p}' /tmp/report
PATT:ok: [test01.example.net] => {$
HOLD:$
COMM:/ok/ {
COMM::a
COMM:N
PATT:ok: [test01.example.net] => {\n    "msg": "3"$
HOLD:$
COMM:/\}/ !{
COMM:b a
COMM:N
PATT:ok: [test01.example.net] => {\n    "msg": "3"\n    test$
HOLD:$
COMM:/\}/ !{
COMM:b a
COMM:N
PATT:ok: [test01.example.net] => {\n    "msg": "3"\n    test\n}$
HOLD:$
COMM:/\}/ !{
COMM:s/\n/\t/g
PATT:ok: [test01.example.net] => {\t    "msg": "3"\t    test\t}$
HOLD:$
COMM:p
ok: [test01.example.net] => {      "msg": "3"      test        }
PATT:ok: [test01.example.net] => {\t    "msg": "3"\t    test\t}$
HOLD:$
COMM:}
PATT:ok: [test01.example.net] => {\t    "msg": "3"\t    test\t}$
HOLD:$
```

{% include links.html %}
