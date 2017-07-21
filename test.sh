#!/bin/bash

#Check if file exist
if [ ! -f "/mnt/ramdisk/date.txt" ]; then
   touch /mnt/ramdisk/date.txt
fi

read olddate < /mnt/ramdisk/date.txt
date="$(date +%s)"
diff="$(echo "$date - $olddate" | bc)"

#if (( num == 1000 )); then
#    num=0
#fi

#date="$(date +%s > /mnt/ramdisk/date.txt)"
#typeset -i datefile="$(cat /mnt/ramdisk/date.txt)"


printf "$diff"
#echo "$date" > /mnt/ramdisk/date.txt
