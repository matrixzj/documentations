#! /bin/bash 

path=$1

# resize rendering pictures
for i in $(find $path -size +100k -print); do
    fileName=$(echo $i | awk -F'/' '{print $NF}')
    echo $fileName
    /home/jzou/documentations/scripts/resize_pic.py $path $fileName
    mv -f "$path/resized_$fileName" "$path/$fileName"
done
