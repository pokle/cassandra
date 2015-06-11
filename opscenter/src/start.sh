#!/usr/bin/env bash

IP=`hostname --ip-address`

sed -i -e "s/^interface.*/interface = $IP/" /etc/opscenter/opscenterd.conf

echo Starting OpsCenter on $IP...
/usr/bin/supervisord
