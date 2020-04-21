#!/bin/sh
# borrowed from: https://www.cyberciti.biz/faq/flush-iptables-ubuntu-linux/
#
# search: iptables flush rules open box

# set -x
set -e

# flush rules
iptables -F

iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# set +x
set +e

