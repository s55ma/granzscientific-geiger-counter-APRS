#!/bin/bash

#APRS radiation script, S55MA (https://s55ma.radioamater.si) July 2017,
#Tested on Raspbian OS.
#Ncat is a part of the nmap, install nmap to use ncat.
#You also need bc tool for calculations.

#Create a temporary RAM disk (we don't want to write on a SD card too often).
#You need to run this script as sudo (root) or create a temporary ramdisk at boot as root
#and run this script as a normal user.
if [ ! -d "/mnt/ramdisk/" ]; then
   mkdir -p /mnt/ramdisk; mount -t tmpfs tmpfs /mnt/ramdisk -o size=10m
fi

#APRS protocol needs to pass a sequence number in a format Txxx, where xxx is the 3 digit number, each time
#you pass the data this number has to change.

#Check if file exist
if [ ! -f "/mnt/ramdisk/sequence_number.txt" ]; then
   touch /mnt/ramdisk/sequence_number.txt
fi

#Read sequence number
read num < /mnt/ramdisk/sequence_number.txt
num=$((num + 1))
if (( num == 1000 )); then
    num=0
fi

#Define variables
#APRS server
server=poland.aprs2.net

#APRS port
port=14580

#station coordinates
lat=4539.94N
lon=01417.67E_ #_ is a symbol for WX station

#User SSID of the station should be 10, 15 or 8
#Example: S55MA-10
user=yourHAMcallsign-SSID

#Your radioamateur callpass (https://www.george-smart.co.uk/aprs/aprs_callpass/)
password=yourcallpass

#Geiger counter counts per minute file. This file is generated by pyGIconsole.py
radiationfile=/home/pi/PiZeroGeigerCounter/pi-software/radiation.txt

#counts per minute value
CPM="$(cat $radiationfile)"

#Conversion factors are tube dependent, check specs of your tube for a proper conversion factor
#This tube is STS-5 type

#Different conversions if you decide later to select other units.
#nanosieverts per hour conversion.
nSv="$(echo "$CPM * 2.33" | bc | awk '{printf "%1.f", $0}')"

#Microsieverts per hour conversion.
uSv="$(echo "$CPM * 0.00233" | bc | awk '{printf "%.3f", $0}')"

#Micro roentgen per hour conversion.
uR="$(echo "$uSv * 100" | bc)"

#Generate authentication data.
aprsauth="user $user pass $password"

#Generate Weather string, required string if this is your only station. It has an empty weather data values but
#it's needed to generate the station on the APRS network.
wx="$user>APRS,TCPIP*:!$lat/$lon.../...g...t... /Digi-iGate Geiger counter"

#Weather data string example. This is how a non empty weather data should look like. You don't need this.
wxs="$user>APRS,TCPIP*:=$lat/$lon"247/002g...t082r000P000p000h36b09354Digi-iGate-APRS-Geiger-counter""

#Telemetry data, more info at http://www.aprs.net/vm/DOS/TELEMTRY.HTM
#Value is in nSv, since the format support is from 0-999 you can't use floating point values.
printf -v t1 "%s>APRS,TCPIP*:T#%03d,$nSv,000,000,000,000,00000000" "$user" "$num"
t2="$user>APRS,TCPIP*::$user :PARM.Radiation"
t3="$user>APRS,TCPIP*::$user :UNIT.uSv/h"

#Add coeficient in EQNS field to convert to uSv 0.001.
t4="$user>APRS,TCPIP*::$user :EQNS.0,0.001,0,0,0,0,0,0,0,0,0,0,0,0,0"
t5="$user>APRS,TCPIP*::$user :BITS.00000000,APRS Geiger Counter"

##############################################
######## Send data to the APRS server.########
##############################################

#Check if file exist
if [ ! -f "/mnt/ramdisk/date.txt" ]; then
   echo 0 > /mnt/ramdisk/date.txt
fi

#calculate time difference
read olddate < /mnt/ramdisk/date.txt
date="$(date +%s)"
diff="$(echo "$date - $olddate" | bc)"


#Use this if this is your primary station.
#Send PARAMS, UNITS, EQNS and BITS every 2 hours, this is separate from the actual radiation value.
#if [ "$diff" -gt 7200 ]; then
#   printf "%s\n" "$aprsauth" "wx" "$t1" "$t2" "$t3" "$t4" "$t5" | ncat --send-only $server $port
#     else
#   printf "%s\n" "$aprsauth" "$t1" | ncat --send-only $server $port
#fi

#Use this if you're sending extra data to your existing station, wx is removed.
#only telemtry is being sent.
#Send PARAMS, UNITS, EQNS and BITS every 2 hours, this is separate from the actual radiation value.

if [ "$diff" -gt 7200 ]; then
   printf "%s\n" "$aprsauth" "$t1" "$t2" "$t3" "$t4" "$t5" | ncat --send-only $server $port
     else
   printf "%s\n" "$aprsauth" "$t1" | ncat --send-only $server $port
fi

#Output control, uncomment for debugging
#printf "%s\n" "$aprsauth" "$wx" "$t1" "$t2" "$t3" "$t4" "$t5"
#printf "%s\n" "$aprsauth" "$t1" "$t2" "$t3" "$t4" "$t5"
#printf "%s\n" "$aprsauth" "$wxs"

#Write the last sequence number.
echo "$num" > /mnt/ramdisk/sequence_number.txt

#Write the last date
if [ "$diff" -gt 7200 ]; then
    echo "$date" > /mnt/ramdisk/date.txt
fi
