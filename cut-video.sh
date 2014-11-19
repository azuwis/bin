#!/bin/bash
if [ $# -lt 3 ]; then
    echo "$0 INPUT OUTPUT START DURATION"
    exit
fi
input=$1
output=$2
if [ $# -eq 3 ]; then
    start="00:00:00"
    duration=$3
else
    start=$3
    duration=$4
fi
ffmpeg -i $input -c:v copy -c:a copy -ss $start -t $duration $output
