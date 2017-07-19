#!/bin/bash
pattern="$1"
if [ -z "$1" ]; then
    ps auxf
else
    ps aux | grep "[${pattern:0:1}]${pattern:1}"
fi
