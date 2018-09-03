#!/bin/bash

if (( $# < 1 )); then
	echo "Usage: $0 passcode"
	exit 1
else
	PASSCODE=$1
fi

CIRCLE_IP=10.0.1.21
APP_ID="AutoProfileSwitcherZ"
HASH=$(echo -n "${APP_ID}${PASSCODE}" | sha1sum | cut -d' ' -f1)

curl -sk "https://${CIRCLE_IP}:4567/api/TOKEN?appid=${APP_ID}&hash=${HASH}"

