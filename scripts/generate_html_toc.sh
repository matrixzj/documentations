#!/bin/bash

file=$1

cat "${file}" | while read -r line; do 
    TITLE=$(echo "${line}" | sed -nE 's/.*\[(.*)\].*/\1/p')
    LINK=$(echo "${line}" | sed -nE 's/.*\(#(.*)\).*/\1/p')
    sed -n -E "s/LINK/${LINK}/g; s/TITLE/${TITLE}/g; p" template
done

