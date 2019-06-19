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

| **Markdown** | **Alternate** | **HTML** | **Rendered Output** |   
| ------------- | ------------- | ------------- | ------------- | 
| `# Heading level 1` | `Heading level 1`<br>`---------------` | `<h1>Heading level 1</h1>` | {::nomarkdown}<h1>Heading level 1</h1>{:/}  
| `## Heading level 2` | `Heading level 2`<br>`===============` | `<h2>Heading level 2</h2>` | {::nomarkdown}<h2>Heading level 2</h2>{:/} 
| `### Heading level 3` | | `<h3>Heading level 3</h3>` | {::nomarkdown}<h3>Heading level 3</h3>{:/}
| `#### Heading level 4` | | `<h4>Heading level 4</h4>` | {::nomarkdown}<h4>Heading level 4</h4>{:/}
| `##### Heading level 5` | | `<h5>Heading level 5</h5>` | {::nomarkdown}<h5>Heading level 5</h5>{:/}
| `###### Heading level 6` | | `<h6>Heading level 6</h6>` | {::nomarkdown}<h6>Heading level 6</h6>{:/}
{: .table-bordered }

### Emphasis 

#### Bold

To bold text, add two asterisks or underscores before and after a word or phrase. To bold the middle of a word for emphasis, add two asterisks without spaces around the letters.    

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`I just love **bold text**.` | `I just love <strong>bold text</strong>.` | I just love <strong>bold text.</strong>  
`I just love __bold text__.` | `I just love <strong>bold text</strong>.` | I just love <strong>bold text.</strong>  
`Love**is**bold` | `Love<strong>is</strong>bold` | Love<strong>is</strong>bold  
{: .table-bordered }

#### Italic

To italicize text, add one asterisk or underscore before and after a word or phrase. To italicize the middle of a word for emphasis, add one asterisk without spaces around the letters.  

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`Italicized text is the *cat's meow*.` | `Italicized text is the <em>cat's meow</em>.` | Italicized text is the <em>cat’s meow</em>.  
`Italicized text is the _cat's meow_.` | `Italicized text is the <em>cat's meow</em>.` | Italicized text is the <em>cat’s meow</em>.  
`A*cat*meow` | `A<em>cat</em>meow` | A<em>cat</em>meow  
{: .table-bordered }

#### Bold and Italic

To emphasize text with bold and italics at the same time, add three asterisks or underscores before and after a word or phrase.  

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`This text is ***really important***.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.  
`This text is ___really important___.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.  
`This text is __*really important*__.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important.</em></strong>  
`This text is **_really important_**.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.  
{: .table-bordered }

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

### Lists

You can organize items into ordered and unordered lists.

#### Ordered Lists

To create an ordered list, add line items with numbers followed by periods. The numbers don’t have to be in numerical order, but the list should start with the number one.

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`1. First item`<br>`2. Second item`<br>`3. Third item`<br>`4. Fourth item ` | `<ol>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<li>Fourth item</li>`<br>`</ol> ` | {::nomarkdown}<ol><li>First item</li><li>Second item</li><li>Third item</li><li>Fourth item</li></ol>{:/}
`1. First item`<br>`2. Second item`<br>`3. Third item`<br>`    1. Indented item`<br>`    2. Indented item`<br>`4. Fourth item ` | `<ol>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<ol>`<br>`<li>Indented item</li>`<br>`<li>Indented item</li>`<br>`</ol>`<br>`<li>Fourth item</li>`<br>`</ol> ` | {::nomarkdown}<ol><li>First item</li><li>Second item</li><li>Third item</li><ol><li>Indented item</li><li>Indented item</li></ol><li>Fourth item</li></ol>{:/}
{: .table-bordered }

#### Unordered Lists

To create an unordered list, add dashes (`-`), asterisks (`*`), or plus signs (`+`) in front of line items. Indent one or more items to create a nested list.

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`- First item`<br>`- Second item`<br>`- Third item`<br>`- Fourth item` | `<ul>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<li>Fourth item</li>`<br>`</ul>` | {::nomarkdown}<ul><li>First item</li><li>Second item</li><li>Third item</li><li>Fourth item</li></ul>{:/}
`* First item`<br>`* Second item`<br>`* Third item`<br>`* Fourth item` | `<ul>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<li>Fourth item</li>`<br>`</ul>` | {::nomarkdown}<ul><li>First item</li><li>Second item</li><li>Third item</li><li>Fourth item</li></ul>{:/}
`+ First item`<br>`+ Second item`<br>`+ Third item`<br>`+ Fourth item` | `<ul>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<li>Fourth item</li>`<br>`</ul>` | {::nomarkdown}<ul><li>First item</li><li>Second item</li><li>Third item</li><li>Fourth item</li></ul>{:/}
{: .table-bordered }

### Code

#### Word or Phase

To denote a word or phrase as code, enclose it in tick marks (`` ` ``).

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
``At the command prompt, type `nano`.`` | `At the command prompt, type <code>nano</code>.` | {::nomarkdown}At the command prompt, type <code>nano</code>.{:/}
{: .table-bordered }

#### Block

To create code blocks, indent every line of the block by at least four spaces or one tab, or put three tick marks (```` ``` ````) or three tildes (`~~~`) on the lines before and after the code block.  
````
```
    <html>  
      <head>  
      </head>  
    </html>  
```
````

````
~~~
    <html>  
      <head>  
      </head>  
    </html>  
~~~
````  
Rendered Output:  
    <html>
      <head>
      </head>
    </html>

{% include links.html %}
