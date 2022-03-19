---
title: Markdown Syntax
tags: [misc]
keywords: markdown
last_updated: June 20, 2019
summary: "Markdown Cheatsheet"
sidebar: mydoc_sidebar
toc: false
permalink: misc_markdown_syntax.html
folder: Misc
---

<div id="toc" style="">
   <ul>
      <li><a href="#headings">Headings</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#headings" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li>
         <a href="#emphasis">Emphasis</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#emphasis" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a>
         <ul>
            <li><a href="#bold">Bold</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#bold" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#italic">Italic</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#italic" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#bold-and-italic">Bold and Italic</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#bold-and-italic" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#blockquotes">Blockquotes</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#blockquotes" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#blockquotes-with-multiple-paragraphs">Blockquotes with Multiple Paragraphs</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#blockquotes-with-multiple-paragraphs" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
         </ul>
      </li>
      <li>
         <a href="#lists">Lists</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#lists" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a>
         <ul>
            <li><a href="#ordered-lists">Ordered Lists</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#ordered-lists" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#unordered-lists">Unordered Lists</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#unordered-lists" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
         </ul>
      </li>
      <li>
         <a href="#code">Code</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#code" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a>
         <ul>
            <li><a href="#word-or-phase">Word or Phase</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#word-or-phase" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#block">Block</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#block" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
         </ul>
      </li>
      <li>
         <a href="#links">Links</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#links" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a>
         <ul>
            <li><a href="#adding-titles">Adding Titles</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#adding-titles" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#reference-style-links">Reference-style Links</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#reference-style-links" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#footnotes">Footnotes</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#footnotes" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
            <li><a href="#images">Images</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#images" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
         </ul>
      </li>
      <li><a href="#tables">Tables</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" href="#tables" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
   </ul>
</div>

# Markdown Syntax
=====

## Headings

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


## Emphasis 

### Bold

To bold text, add two asterisks or underscores before and after a word or phrase. To bold the middle of a word for emphasis, add two asterisks without spaces around the letters.    

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`I just love **bold text**.` | `I just love <strong>bold text</strong>.` | I just love <strong>bold text.</strong>  
`I just love __bold text__.` | `I just love <strong>bold text</strong>.` | I just love <strong>bold text.</strong>  
`Love**is**bold` | `Love<strong>is</strong>bold` | Love<strong>is</strong>bold  
{: .table-bordered }

### Italic

To italicize text, add one asterisk or underscore before and after a word or phrase. To italicize the middle of a word for emphasis, add one asterisk without spaces around the letters.  

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`Italicized text is the *cat's meow*.` | `Italicized text is the <em>cat's meow</em>.` | Italicized text is the <em>cat’s meow</em>.  
`Italicized text is the _cat's meow_.` | `Italicized text is the <em>cat's meow</em>.` | Italicized text is the <em>cat’s meow</em>.  
`A*cat*meow` | `A<em>cat</em>meow` | A<em>cat</em>meow  
{: .table-bordered }

### Bold and Italic

To emphasize text with bold and italics at the same time, add three asterisks or underscores before and after a word or phrase.  

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`This text is ***really important***.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.  
`This text is ___really important___.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.  
`This text is __*really important*__.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important.</em></strong>  
`This text is **_really important_**.` | `This text is <strong><em>really important</em></strong>.` | This text is <strong><em>really important</em></strong>.  
{: .table-bordered }

### Blockquotes

To create a blockquote, add a `>` in front of a paragraph.  

`> Dorothy followed her through many of the beautiful rooms in her castle.`

The rendered output looks like this:  

> Dorothy followed her through many of the beautiful rooms in her castle.

### Blockquotes with Multiple Paragraphs

Blockquotes can contain multiple paragraphs. Add a `>` on the blank lines between the paragraphs.  

`> Dorothy followed her through many of the beautiful rooms in her castle.`  
`>`  
`> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.`  

The rendered output looks like this:

> Dorothy followed her through many of the beautiful rooms in her castle.
>
> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.

## Lists

You can organize items into ordered and unordered lists.

### Ordered Lists

To create an ordered list, add line items with numbers followed by periods. The numbers don’t have to be in numerical order, but the list should start with the number one.

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`1. First item`<br>`2. Second item`<br>`3. Third item`<br>`4. Fourth item ` | `<ol>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<li>Fourth item</li>`<br>`</ol> ` | {::nomarkdown}<ol><li>First item</li><li>Second item</li><li>Third item</li><li>Fourth item</li></ol>{:/}
`1. First item`<br>`2. Second item`<br>`3. Third item`<br>`    1. Indented item`<br>`    2. Indented item`<br>`4. Fourth item ` | `<ol>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<ol>`<br>`<li>Indented item</li>`<br>`<li>Indented item</li>`<br>`</ol>`<br>`<li>Fourth item</li>`<br>`</ol> ` | {::nomarkdown}<ol><li>First item</li><li>Second item</li><li>Third item</li><ol><li>Indented item</li><li>Indented item</li></ol><li>Fourth item</li></ol>{:/}
{: .table-bordered }

### Unordered Lists

To create an unordered list, add dashes (`-`), asterisks (`*`), or plus signs (`+`) in front of line items. Indent one or more items to create a nested list.

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
`- First item`<br>`- Second item`<br>`- Third item`<br>`- Fourth item` | `<ul>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<li>Fourth item</li>`<br>`</ul>` | {::nomarkdown}<ul><li>First item</li><li>Second item</li><li>Third item</li><li>Fourth item</li></ul>{:/}
`* First item`<br>`* Second item`<br>`* Third item`<br>`* Fourth item` | `<ul>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<li>Fourth item</li>`<br>`</ul>` | {::nomarkdown}<ul><li>First item</li><li>Second item</li><li>Third item</li><li>Fourth item</li></ul>{:/}
`+ First item`<br>`+ Second item`<br>`+ Third item`<br>`+ Fourth item` | `<ul>`<br>`<li>First item</li>`<br>`<li>Second item</li>`<br>`<li>Third item</li>`<br>`<li>Fourth item</li>`<br>`</ul>` | {::nomarkdown}<ul><li>First item</li><li>Second item</li><li>Third item</li><li>Fourth item</li></ul>{:/}
{: .table-bordered }

## Code

### Word or Phase

To denote a word or phrase as code, enclose it in tick marks (`` ` ``).

**Markdown** | **HTML** | **Rendered Output**  
------------- | ------------- | -----   
``At the command prompt, type `nano`.`` | `At the command prompt, type <code>nano</code>.` | {::nomarkdown}At the command prompt, type <code>nano</code>.{:/}
{: .table-bordered }

### Block

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
```
    <html>
      <head>
      </head>
    </html>
```

## Links

To create a link, enclose the link text in brackets (e.g., [Duck Duck Go]) and then follow it immediately with the URL in parentheses (e.g., (https://duckduckgo.com)).

`My own site is [Matrix Garden](https://matrixzj.github.io).`

The rendered output looks like this:

My own site is [Matrix Garden](https://matrixzj.github.io).

### Adding Titles

You can optionally add a title for a link. This will appear as a tooltip when the user hovers over the link. To add a title, enclose it in parentheses after the URL.

`My own site is [Matrix Garden](https://matrixzj.github.io "best site").`

The rendered output looks like this:

My own site is [Matrix Garden](https://matrixzj.github.io "best site").

### Reference-style Links

Reference-style links are constructed in two parts: the part you keep inline with your text and the part you store somewhere else in the file to keep the text easy to read.

1. The first part of a reference-style link is formatted with two sets of brackets. 
    1. The first set of brackets surrounds the text that should appear linked. 
    2. The second set of brackets displays a label used to point to the link you’re storing elsewhere in your document.

2. The second part of a reference-style link is formatted with the following attributes:
    1. The label, in brackets, followed immediately by a colon and at least one space (e.g., `[label]:` ).
    2. The URL for the link, which you can optionally enclose in angle brackets.
    3. The optional title for the link, which you can enclose in double quotes, single quotes, or parentheses.

```
[Matrix Keycap Garden][1] is maintained by [Matrix Zou][2], and based on [Markdown][3]

[1]: <https://matrixzj.github.io> "Keycaps Garden"
[2]: <https://matrixzj.github.io/resume> "about Matrix"
[3]: <https://matrixzj.github.io/documentations> "Markdown Syntax"
```

The rendered output looks like this:

[Matrix Keycap Garden][1] is maintained by [Matrix Zou][2], and based on [Markdown][3]

[1]: <https://matrixzj.github.io> "Keycaps Garden"
[2]: <https://matrixzj.github.io/resume> "about Matrix"
[3]: <https://matrixzj.github.io/documentations> "Markdown Syntax"

### Footnotes

Footnotes are built with 2 parts: 
    1 label, enclose with brackets and label text must be lead by `^'
    2 footnotes content, can be anywhere in the doc, lead by `label` defined above + `: ` + real footnote content

```
Footnotes[^1] have a label[^label] 

[^1]: This is a footnote
[^label]: A footnote on "label"
```

Footnotes[^1] have a label[^label]  
Note: footnote will be shown in the end of page. 

[^1]: This is a footnote
[^label]: A footnote on "label"

### Images

To add an image, add an exclamation mark (!), followed by alt text in brackets, and the path or URL to the image asset in parentheses. You can optionally add a title after the URL in the parentheses.

`![Matrix](/images/misc/markdown/Portrait.JPG)`

Rendered output:

![Matrix](images/misc/markdown/Portrait.JPG)

#### Linking Images

To add a link to an image, enclose the Markdown for the image in brackets, and then add the link in parentheses.

`[![Matrix](images/misc/markdown/Portrait.JPG)](https://matrixzj.github.io/resume)`

Rendered output

[![Matrix](images/misc/markdown/Portrait.JPG)](https://matrixzj.github.io/resume)

## Tables

Tables aren't part of the core Markdown spec, but they are part of GFM and Markdown Here supports them. 

```
| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |
```

Rendered output:

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

There must be at least 3 dashes separating each header cell. The outer pipes (`|`) are optional, and you don't need to make the 
raw Markdown line up prettily. You can also use inline Markdown.

```
Markdown | Less | Pretty
--- | --- | ---
*Still* | `renders` | **nicely**
1 | 2 | 3
```

Rendered output:

Markdown | Less | Pretty
--- | --- | ---
*Still* | `renders` | **nicely**
1 | 2 | 3


{% include links.html %}
