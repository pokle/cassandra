#!/usr/bin/env bash

IP=`hostname --ip-address`
echo Configuring Cassandra to listen at $IP 

DEFAULT=/etc/cassandra/default.conf
CONFIG=/etc/cassandra/conf

rm -rf $CONFIG
mkdir -p $CONFIG
cp $DEFAULT/cassandra.yaml $DEFAULT/log4j-server.properties $CONFIG

sed -i -e "s/^listen_address.*/listen_address: $IP/"   $CONFIG/cassandra.yaml
sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/"   $CONFIG/cassandra.yaml
sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$IP\"/" $CONFIG/cassandra.yaml

echo Starting Cassandra... 
cassandra -f
