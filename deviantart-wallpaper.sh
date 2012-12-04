#!/bin/bash

# author: Zhong Jianxin (azuwis)
# dep: xmlstarlet curl feh

# Popular  Abstract in the last 1 day http://browse.deviantart.com/customization/wallpaper/abstract/
rss='http://backend.deviantart.com/rss.xml?q=boost%3Apopular+in%3Acustomization%2Fwallpaper%2Fabstract+max_age%3A24h&type=deviation'
mkdir -p ~/.wallpaper
cd ~/.wallpaper
index=0
max_index=0
max_width=0
for url in `xmlstarlet sel --net -T -t -m 'rss/channel/item/media:content[@medium="document"]' -v @url -n $rss`
do
    # work with the first 24 items
    if [ $index -gt 24 ]; then
        break
    fi
    echo -n "downloading #$index item..."
    curl -sL $url >${index}.jpg
    width=`feh -L %w ${index}.jpg 2>/dev/null`
    if [ x"$width" = x"" ]; then
        width=0
    fi
    echo -n "width $width"
    # if width > 1920, use it
    if [ $width -gt 1920 ]; then
        max_index=$index
        echo -n "(>1920)"
        break
    # else get the widest one
    elif [ $width -gt $max_width ]; then
        max_width=$width
        max_index=$index
        echo -n "(widest)"
    fi
    echo
    index=$((index+1))
done
mv current previous
mv ${max_index}.jpg current
feh --bg-fill current
rm *.jpg
