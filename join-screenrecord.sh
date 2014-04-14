#!/bin/bash

denoise() {
    mkv=$1
    base="denoise-$mkv"
    mkdir -p $base
    if [ ! -e $base/noise.wav ]; then
        ffmpeg -i $mkv -vn -y $base/noise.wav
        if echo $mkv | grep -q -v nosound; then
            normalize-audio $base/noise.wav
        fi
    fi
    if [ ! -e $base/clean.wav ]; then
        sox $base/noise.wav -n noiseprof $base/noise.prof
        sox $base/noise.wav $base/clean.wav noisered $base/noise.prof 0.05
    fi
    if [ ! -e $base/tmp.ts ]; then
        ffmpeg -i $mkv -i $base/clean.wav -c:v copy -bsf h264_mp4toannexb -c:a aac -strict experimental -map 0:0 -map 1:0 -y $base/tmp.ts
    fi
}

concat='concat:'

for i in "$@"
do
    concat="${concat}denoise-${i}/tmp.ts|"
    denoise $i
done

ffmpeg -i "${concat%?}" -c copy -bsf:a aac_adtstoasc output.mp4
