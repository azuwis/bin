#!/bin/bash
for i in {3..1}
do
    echo -n "${i}."
    sleep 1
done
echo
ffmpeg \
-f alsa -i pulse -ac 2 \
-f x11grab -r 25 -s 1280x720 -i :0.0+0,24 \
-acodec flac \
-vcodec libx264 -preset ultrafast -threads 2 \
-y "$@"
