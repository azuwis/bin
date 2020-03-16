#!/bin/sh
trap 'exit' INT TERM
trap 'kill 0' EXIT

cat <<EOF
Tips:

ssh -R1080:127.0.0.1:1080 -R8123:127.0.0.1:8123
export all_proxy=socks5://127.0.0.1:1080 http_proxy=http://127.0.0.1:8123 https_proxy=http://127.0.0.1:8123

EOF

[ -x /usr/bin/tinyproxy ] && tinyproxy -d -c ~/.config/tinyproxy.conf &
ss-local -v -c /etc/shadowsocks-libev/redir.json -l 1080 -b 127.0.0.1
