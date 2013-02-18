#!/bin/bash
: ${DISPLAY:=":0"}
export DISPLAY
xset -dpms
xset s noblank
xset s of
