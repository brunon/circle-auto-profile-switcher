#!/bin/bash
#
# To install: sudo launchctl load -w /path/to/script
#

CIRCLE_IP=10.0.1.21
TOKEN="8CE2DAF22C32-9RxD7dr5XTgg6DTb-20180829.225314"

MAC_ADDRESS=$(ifconfig en0 | awk '/ether/{print $2}' | tr '[:upper:]' '[:lower:]')

MAPPING_FILE=$(dirname $0)/user-mapping.properties

if [[ ! -e $MAPPING_FILE ]]; then
	echo "Mapping file $MAPPING_FILE does not exist!"
	exit 1
fi

PREVIOUS_PID=""
while :
do
	CURRENT_USER=$(stat -f%Su /dev/console)
	USER_PID=$(grep $CURRENT_USER $MAPPING_FILE | sed 's/.*=//')
	if [[ -n $USER_PID && $PREVIOUS_PID != $USER_PID ]]; then
		echo "----- $(date) -----"
		echo "Detected new user active: $CURRENT_USER"
		echo "Switching to Circle Profile #$USER_PID"
		curl -ks "https://${CIRCLE_IP}:4567/api/ADD/users/user/relatedDevices/relatedDevice?user.pid=${USER_PID}&mac=${MAC_ADDRESS}&token=${TOKEN}"
		echo ; echo
		PREVIOUS_PID=$USER_PID
	fi
	sleep 10
done

