---
title: Markdown Syntax
tags: [misc]
keywords: markdown
last_updated: June 18, 2019
summary: "Markdown Cheatsheet"
sidebar: mydoc_sidebar
permalink: misc_markdown_syntax.html
folder: Misc
---

Markdown Syntax
=====

### Headings

To create a heading, add number signs (`#`) in front of a word or phrase. The number of number signs you use should correspond to the heading level. For example, to create a heading level three (`<h3>`), use three number signs (e.g., `### My Header`).
**Markdown** | **HTML** | **Rendered Output**
------------- | ------------- | ----- 
`# Heading level 1` | `<h1>Heading level 1</h1>` | <h1>Heading level 1</h1>
`## Heading level 2` | `<h2>Heading level 2</h2>` | <h2>Heading level 2</h2>
`### Heading level 3` | `<h3>Heading level 3</h3>` | <h3>Heading level 3</h3>
`#### Heading level 4` | `<h4>Heading level 4</h4>` | <h4>Heading level 4</h4>
`##### Heading level 5` | `<h5>Heading level 5</h5>` | <h5>Heading level 5</h5>
`###### Heading level 6` | `<h6>Heading level 6</h6>` | <h6>Heading level 6</h6>

#### Alternate Syntax

Alternatively, on the line below the text, add any number of `==` characters for heading level 1 or `--` characters for heading level 2.
**Markdown** | **HTML** | **Rendered Output**
------------- | ------------- | ----- 
`Heading level 1`<br>`---------------` | `<h1>Heading level 1</h1>` | <h1>Heading level 1</h1>
`Heading level 2`<br>`===============` | `<h2>Heading level 2</h2>` | <h2>Heading level 2</h2>

### Emphasis 

#### Bold

To bold text, add two asterisks or underscores before and after a word or phrase. To bold the middle of a word for emphasis, add two asterisks without spaces around the letters.
**Markdown** | **HTML** | **Rendered Output**
------------- | ------------- | ----- 
`I just love **bold text**.` | `I just love <strong>bold text</strong>.` | I just love <strong>bold text.</strong>
`I just love __bold text__.` | `I just love <strong>bold text</strong>.` | I just love <strong>bold text.</strong>
`Love**is**bold` | `Love<strong>is</strong>bold` | Love<strong>is</strong>bold

#### Italic

To italicize text, add one asterisk or underscore before and after a word or phrase. To italicize the middle of a word for emphasis, add one asterisk without spaces around the letters.
**Markdown** | **HTML** | **Rendered Output**
------------- | ------------- | ----- 
`Italicized text is the *cat's meow*.` | `Italicized text is the <em>cat's meow</em>.` | Italicized text is the <em>cat’s meow</em>.
`Italicized text is the _cat's meow_.` | `Italicized text is the <em>cat's meow</em>.` | Italicized text is the <em>cat’s meow</em>.
`A*cat*meow` | `A<em>cat</em>meow` | A<em>cat</em>meow

#### Bold and Italic

To emphasize text with bold and italics at the same time, add three asterisks or underscores before and after a word or phrase.
**Markdown** | **HTML** | **Rendered Output**
------------- | ------------- | ----- 
`This text is ***really important***.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.
`This text is ___really important___.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.
`This text is __*really important*__.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important.</em></strong>
`This text is **_really important_**.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.

#### Blockquotes

To create a blockquote, add a `>` in front of a paragraph.

`> Dorothy followed her through many of the beautiful rooms in her castle.`

The rendered output looks like this:

> Dorothy followed her through many of the beautiful rooms in her castle.

#### Blockquotes with Multiple Paragraphs

Blockquotes can contain multiple paragraphs. Add a `>` on the blank lines between the paragraphs.

`> Dorothy followed her through many of the beautiful rooms in her castle.`
`>`
`> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.`

The rendered output looks like this:

> Dorothy followed her through many of the beautiful rooms in her castle.
>
> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.



{% include links.html %}
