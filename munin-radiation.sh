#!/bin/bash

case $1 in
   config)
        cat <<'EOM'
graph_title 1 Counts per minute and nanosieverts per hour
graph_category radiation
cpm.label counts per minute
cpm.colour COLOUR24
nSv.label nanosieverts per hour
nSv.colour COLOUR1

EOM
        exit 0;;
esac

#edit radiationfile location
radiationfile=/path/to/PiZeroGeigerCounter/pi-software/radiation.txt

#Counts per minute
CPM="$(cat $radiationfile)"
printf "cpm.value "
echo $CPM

#Nanosieverts per hour conversion factor
#nSv = CPM * 2.33
printf "nSv.value "
echo "$CPM * 2.33" | bc | awk '{printf "%1.f", $0}'
echo

