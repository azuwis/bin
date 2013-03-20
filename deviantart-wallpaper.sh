#!/bin/bash

# author: Zhong Jianxin (azuwis)
# dep: xmlstarlet curl feh

# Popular Abstract in the last 1 day http://browse.deviantart.com/customization/wallpaper/abstract/
rss='http://backend.deviantart.com/rss.xml?q=boost%3Apopular+in%3Acustomization%2Fwallpaper%2Fabstract+max_age%3A24h&type=deviation'
mkdir -p ~/.wallpaper/archive
cd ~/.wallpaper || exit

if [ x"$1" == x"prev" ]; then
    feh --bg-fill previous
    exit 0
elif [ x"$1" == x"cur" ]; then
    feh --bg-fill current
    exit 0
elif [ x"$1" == x"next" ]; then
    echo -n >current
fi

index=0
max_width=0
for url in `xmlstarlet sel --net -T -t -m 'rss/channel/item/media:content[@medium="document"]' -v @url -n $rss`
do
    # work with the first 16 items
    if [ $index -gt 16 ]; then
        break
    fi
    file=`echo $url | perl -ne 'print $1 if m#([^/]+)/?$#'`
    if [ ! -e "archive/$file" ]; then
        curl -#L $url >"archive/$file"
    fi
    width=`feh -L %w "archive/$file" 2>/dev/null`
    if [ x"$width" = x"" ]; then
        width=0
    fi
    echo -n "NO.$index item width: $width"
    # if width > 1920, use it
    if [ $width -gt 1920 ]; then
        max_file="archive/$file"
        echo "(>1920)"
        break
    # else get the widest one
    elif [ $width -gt $max_width ]; then
        max_width=$width
        max_file="archive/$file"
        echo -n "(widest)"
    else
    # leave a placeholder
        echo -n > "archive/$file"
    fi
    echo
    # use the widest one in the first 5 items if width >= 1920
    if [ $index -lt 5 -a $max_width -ge 1920 ]; then
        break
    fi
    index=$((index+1))
done
if [ -e current ]; then
    echo "previous -> `readlink current`"
    ln -sf `readlink current` previous
fi
echo "current -> $max_file"
ln -sf "$max_file" current
feh --bg-fill current
