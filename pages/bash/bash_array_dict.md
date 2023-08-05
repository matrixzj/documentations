---
title: Bash Array and Dict
tags: [bash]
keywords: bash, array, list, dict
last_updated: Aug 5, 2023
summary: "Bash Array(List) and Dict"
sidebar: mydoc_sidebar
permalink: bash_array_dict.html
folder: bash
---

# Bash Array and Dict
=====

## Arrays
### Defining Array
```bash
$ Fruits=('Apple' 'Banana' 'Orange')

$ echo "${Fruits[0]}"
Apple

$ echo "${Fruits[1]}"
Banana

$ echo "${Fruits[2]}"
Orange

$ for i in "${Fruits[@]}"; do echo "${i}"; done
Apple
Banana
Orange
```

### Array Operations

<div id="toc" style="">
   <ul>
      <li><a href="#push-an-element">Push an element</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#remove-element">Remove element</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#duplicate--concatenate-array">Duplicate / Concatenate array</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#read-from-file">Read from file</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#number-of-elements">Number of elements</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#length-of-an-element">Length of an element</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#slicing-of-an-array">Slicing of an array</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
   </ul>
</div>

#### Push an Element
```bash
$ Fruits=("${Fruits[@]}" "Waterlemon")

$ echo ${Fruits[@]}
Apple Banana Orange Waterlemon

$ Fruits+=('Cherry')

$ echo "${Fruits[@]}"
Apple Banana Orange Waterlemon Cherry
```

#### Remove an Element
```bash
$ echo "${Fruits[@]}"
Apple Banana Orange Waterlemon Cherry

$ unset Fruits[1]

$ echo "${Fruits[@]}"
Apple Orange Waterlemon Cherry

$ Fruits=(${Fruits[@]/App*/})

$ echo "${Fruits[@]}"
Orange Waterlemon Cherry
```

#### Duplicate / Concatenate array
```bash
$ echo "${Fruits[@]}"
Orange Waterlemon Cherry

$ AnotherFruits=("${Fruits[@]}")

$ echo "${AnotherFruits[@]}"
Orange Waterlemon Cherry

$ Fruits=("${Fruits[@]}" "${AnotherFruits[@]}")

$ echo "${Fruits[@]}"
Orange Waterlemon Cherry Orange Waterlemon Cherry
```

#### Read from file
```bash
$ cat /tmp/test
Apple
Orange
Cherry
Lemon

$ Fruits=($(cat /tmp/test))

$ echo "${Fruits[@]}"
Apple Orange Cherry Lemon

$ echo "${Fruits[1]}"
Orange
```

### Length of Array
```bash
$ echo "${Fruits[@]}"
Apple Orange Cherry Lemon

$ echo "${#Fruits[@]}"
4
```

### Length of an Element
```bash
$ echo "${Fruits[1]}"
Orange

$ echo "${#Fruits[1]}"
6
```

### Slicing Array
```bash
$ echo "${Fruits[@]}"
Apple Orange Cherry Lemon

$ echo "${Fruits[@]:1:2}"
Orange Cherry
```

## Dictionary
### Defining Dictionary
```bash
$ declare -A sounds

$ sounds[dog]="bark"

$ sounds[cow]="moo"

$ sounds[wolf]="howl"
```

### Working with Dict

<div id="toc" style="">
   <ul>
      <li><a href="#number-of-elements">Number of elements</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#add--remove-element">Add / Remove element</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
      <li><a href="#iteration">Iteration</a><a class="anchorjs-link " aria-label="Anchor" data-anchorjs-icon="" style="font: 1em / 1 anchorjs-icons; padding-left: 0.375em;"></a></li>
   </ul>
</div>

#### Lenght of Dict
```bash
$ echo "${#sounds[@]}"
3
```

#### Add / Remove Element
```bash
$ sounds[bird]="tweet"

$ echo "${#sounds[@]}"
4

$ echo "${sounds[@]}"
bark howl moo tweet

$ unset sounds[bird]

$ echo "${#sounds[@]}"
3

$ echo "${!sounds[@]}"
dog wolf cow
```

#### Iteration 
* Over key
   ```bash
   $ for i in  "${!sounds[@]}"; do echo "${i}"; done
   dog
   wolf
   cow
   ```

* Over value 
   ```bash
   $ for i in  "${sounds[@]}"; do echo "${i}"; done
   bark
   howl
   moo
   ```


{% include links.html %}
