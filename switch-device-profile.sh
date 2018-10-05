#!/bin/bash
#
# To install: sudo launchctl load -w /path/to/script
#
MAPPING_FILE=$(dirname $0)/user-mapping.properties
CONFIG_FILE=$(dirname $0)/circle.cfg

if [[ ! -e $MAPPING_FILE ]]; then
	echo "Mapping file $MAPPING_FILE does not exist!"
	exit 1
fi

if [[ ! -e $CONFIG_FILE ]]; then
	echo "Config file $CONFIG_FILE does not exist!"
	exit 2
else
	. $CONFIG_FILE
fi

if [[ -z $CIRCLE_IP ]]; then
	echo "Missing CIRCLE_IP config in $CONFIG_FILE!"
	exit 3
elif [[ -z $TOKEN ]]; then
	echo "Missing TOKEN config in $CONFIG_FILE!"
	exit 4
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

		for i in $(ifconfig -l -u)
		do
			status=$(ifconfig $i | awk '/status: /{print $2}')
			if [[ $status == "active" ]]; then
				mac=$(ifconfig $i | awk '/ether/{print $2}' | tr '[:upper:]' '[:lower:]')
				curl -ks "https://${CIRCLE_IP}:4567/api/ADD/users/user/relatedDevices/relatedDevice?user.pid=${USER_PID}&mac=${mac}&token=${TOKEN}"
			fi
		done
		echo ; echo
		PREVIOUS_PID=$USER_PID
	fi
	sleep 10
done

