#!/bin/bash

set -e 

IFACE=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')
DNS_SERVERS=(\
    "178.22.122.100" \
    "185.51.200.2" \
    "10.202.10.202" \
    "10.202.10.102" \
)

if [ "$1"  == "off" ]; then
    systemctl restart systemd-resolved.service
	echo "Shecan is diativated"
elif [ "$1" == "install" ]; then
    SCRIPT_PATH="$(realpath "$0")"
    cp $SCRIPT_PATH "/usr/bin/$(basename "$SCRIPT_PATH")"
elif [ "$1" == "on" ]; then
    FASTEST_SERVER=""
    FASTEST_SPEED=0

    for server in "${DNS_SERVERS[@]}"; do
        CURL_DNS_SERVERS="$server"
        speed=$(curl -o /dev/null -s -w "%{speed_download}\n" http://speed.hetzner.de/10MB.bin)
        if (( $(echo "$speed > $FASTEST_SPEED" | bc -l) )); then
            FASTEST_SPEED=$speed
            FASTEST_SERVER=$server
        fi
        echo "Server: $server, Speed: $speed bytes/sec"
    done

    echo "Selected server: $FASTEST_SERVER with speed: $FASTEST_SPEED bytes/sec"

	if [ -f "$(which resolvectl)" ]; then
        resolvectl dns $IFACE $FASTEST_SERVER
        resolvectl dnsovertls $IFACE no
        resolvectl flush-caches
		echo "Shecan is active"
	else
		echo "Sorry can't find the dns service"
	fi
else	
	echo "$0 off     -- to diable"
	echo "$0 on      -- to enable"
    echo "$0 install -- to install"
fi

