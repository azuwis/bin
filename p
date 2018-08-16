#!/bin/bash
pattern="$1"
if [ -z "$1" ]; then
    exec ps auxf
else
    exec ps aux | grep -v "$(readlink -f "$0")" | grep "[${pattern:0:1}]${pattern:1}"
fi
