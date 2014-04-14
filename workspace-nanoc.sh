#!/bin/bash

# firefox
firefox -no-remote -P dev http://localhost:3000 >&/dev/null &

# tmux
tmux new-session -d -s nanoc "nanoc view"
sleep 1
tmux split-window "guard"

# move/resize firefox
sleep 2
i3-msg move left
i3-msg resize grow width 10 px or 10 ppt

# vim
i3-msg focus right
i3-msg split v
gvim Rules &
sleep 1
i3-msg resize grow height 10 px or 30 ppt

tmux attach
