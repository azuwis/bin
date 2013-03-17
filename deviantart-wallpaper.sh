#!/bin/bash

# author: Zhong Jianxin (azuwis)
# dep: xmlstarlet curl feh

if [ x"$1" == x"prev" ]; then
    feh --bg-fill ~/.wallpaper/previous
    exit 0
fi

# Popular Abstract in the last 1 day http://browse.deviantart.com/customization/wallpaper/abstract/
rss='http://backend.deviantart.com/rss.xml?q=boost%3Apopular+in%3Acustomization%2Fwallpaper%2Fabstract+max_age%3A24h&type=deviation'
mkdir -p ~/.wallpaper/archive
cd ~/.wallpaper || exit
index=0
max_index=0
max_width=0
for url in `xmlstarlet sel --net -T -t -m 'rss/channel/item/media:content[@medium="document"]' -v @url -n $rss`
do
    # work with the first 24 items
    if [ $index -gt 16 ]; then
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
        echo "(>1920)"
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
DATE=`date +%Y%m%d%H%M%S`
mv ${max_index}.jpg archive/$DATE.jpg
echo "previous -> `readlink current`"
ln -sf `readlink current` previous
echo "current -> archive/$DATE.jpg"
ln -sf archive/$DATE.jpg current
feh --bg-fill current
rm -f *.jpg
