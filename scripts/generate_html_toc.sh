#!/bin/bash

file=$1

echo '<div id="toc" style=""> 
   <ul>'

cat "${file}" | while read -r line; do 
    TITLE=$(echo "${line}" | sed -nE 's/\#\#\#\# //p')
    LINK=$(echo "${line}" | sed -E -n -e 's/\#\#\#\# //' -e 's#[`/]##g' -e 's/.*/\L&/' -e 's/ /-/g' -e 'p')
    sed -n -E "s#LINK#\"${LINK}\"#g; s#TITLE#\"${TITLE}\"#g; p" ~/git/documentations/scripts/template-l1
done

echo '   </ul>
</div>'
