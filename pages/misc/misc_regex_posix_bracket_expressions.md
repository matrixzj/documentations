---
title: Regex POSIX Bracket Expressions
tags: [misc]
keywords: mac, regular expressions
last_updated: Nov 28, 2020
summary: "POSIX bracket regular expressions"
sidebar: mydoc_sidebar
permalink: misc_regex_posix_bracket_repressions.html
folder: Misc
---

# Regex POSIX Bracket Expressions
=====


|POSIX|Description|ASCII
|:------|:------|:-----
|[:alnum:]|Alphanumeric characters|[a-zA-Z0-9]
|[:alpha:]|Alphabetic characters|[a-zA-Z]
|[:ascii:]|ASCII characters|[\x00-\x7F]
|[:blank:]|Space and tab|[ \t]
|[:cntrl:]|Control characters|[\x00-\x1F\x7F]
|[:digit:]|Digits|[0-9]
|[:graph:]|Visible characters (anything except spaces and control characters)|[\x21-\x7E]
|[:lower:]|Lowercase letters|[a-z]
|[:print:]|Visible characters and spaces (anything except control characters)|[\x20-\x7E]
|[:punct:]|Punctuation (and symbols)|[!"\#$%&'()*+,\-./:;<=>?\@\[\\\]^_‘{\|}~]
|[:space:]|All whitespace characters, including line breaks|[ \t\r\n\v\f]
|[:upper:]|Uppercase letters|[A-Z]
|[:word:]|Word characters (letters, numbers and underscores)|[A-Za-z0-9_]
|[:xdigit:]|Hexadecimal digits|[A-Fa-f0-9]
{: .table-bordered }


{% include links.html %}
