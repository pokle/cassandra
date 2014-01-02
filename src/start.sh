#!/usr/bin/env bash

IP=`hostname --ip-address`
echo Configuring Cassandra to listen at $IP 

CONFIG=/etc/cassandra/conf/cassandra.yaml
sed -i -e "s/^listen_address.*/listen_address: $IP/"   $CONFIG
#sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/"   $CONFIG

echo Starting Cassandra...
cassandra -f
