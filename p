#!/bin/sh
if [ -z "$1" ]; then
    ps auxf
else
    ps aux | grep -v grep | grep "$@"
fi
