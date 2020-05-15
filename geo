#!/bin/sh

usage() {
    cmd=$(basename "$0")
    cat <<EOF >&2
USAGE: $cmd -h|--help
       $cmd <ip> ...
       $cmd mtr [options ...] <ip>            => mtr -z -n -r [options ...] <ip> | $cmd
       $cmd tr|traceroute [options ...] <ip>  => traceroute -n [options ...] <ip> | $cmd
       tail access.log | geo
EOF
    exit 1
}

geoip() {
    while read -r line
    do
        printf '%s' "$line"
        if [ -n "${line##*traceroute*}" ]
        then
            ip=$(echo "$line" | grep -Eo '\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b' | head -1 | grep -Ev '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)')
            if [ -n "$ip" ]
            then
                printf " | "
                geoiplookup "$ip" | sed 's/^GeoIP ASNum Edition: [^ ]\+ /@@, /' | awk -F', ' -vORS=', ' '/^GeoIP Country Edition/ {print $2} /^GeoIP City Edition/ {print $4, $5} /^@@/ {$1=""; printf substr($0,2)}'
            fi
        fi
        echo
    done
}

if [ -t 0 ];
then
    case "$1" in
        mtr)
            shift
            mtr -z -n -r "$@" | geoip
            ;;
        tr|traceroute)
            shift
            traceroute -n "$@" | geoip
            ;;
        '')
            cat <<EOF >&2
Input IP, Ctrl-C to exit:
EOF
            geoip
            ;;
        -h|--help)
            usage
            ;;
        *)
            IFS='
'
            echo "$*" | geoip
            ;;
    esac
else
    geoip
fi
