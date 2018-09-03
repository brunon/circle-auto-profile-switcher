#!/bin/bash

CIRCLE_IP=10.0.1.21
TOKEN="8CE2DAF22C32-9RxD7dr5XTgg6DTb-20180829.225314"

curl -ks "https://${CIRCLE_IP}:4567/api/QUERY/users?token=${TOKEN}" | python -mjson.tool

