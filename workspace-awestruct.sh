#!/bin/bash

# start firefox
i3-msg split h
firefox -no-remote -P dev http://localhost:4242 >&/dev/null &

# move/resize firefox
sleep 2
i3-msg resize grow width 10 px or 10 ppt

# vim
i3-msg focus left
i3-msg split v
gvim . &
sleep 1
i3-msg resize grow height 10 px or 30 ppt
awestruct -d --livereload
