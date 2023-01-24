#!/bin/bash

disable() {
	systemctl restart systemd-resolved
	echo "Shecan is disable now"
}

enable() {
	if [ -f "$(which resolvectl)" ]; then
		echo "Working with $(which resolvectl)"
		if [ "$1" == "tls" ]; then
			echo "with tls"
			sudo resolvectl dns $IFACE "$IP1#$DOMAIN" 
			sudo resolvectl dnsovertls $IFACE yes
			resolvectl flush-caches
		else
			sudo resolvectl dns $IFACE $IP2 $IP1
			sudo resolvectl dnsovertls $IFACE no
			resolvectl flush-caches
		fi
		echo "Shecan is enable. Enjoy"
	else
		echo "Sorry can't find the dns service"
	fi
}

get_status() {
	if [ -f "$(which resolvectl)" ]; then
		if [ "$(resolvectl status | grep $IP1$)" != "" ]; then
			echo "Shecan is ON"
		else
			echo "Shecan is OFF"
		fi
	else
		echo "Sorry can't find the dns service"
	fi
}

IP1="178.22.122.100" 
IP2="185.51.200.2"
DOMAIN="free.shecan.ir"
IFACE=$(ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | cut -f1 -d ' ')

if [ "$1"  == "off" ]; then
	disable
elif [ "$1" == "tls" ]; then
	enable tls
elif [ "$1" == "on" ]; then
	enable 
elif [ "$1" == "status" ]; then
	get_status
else	
	echo "$0 off   -- to diable shecan"
	echo "$0 on    -- to enable shecan"
	echo "$0 tls   -- to enable with DNS-overTLS" 
fi

