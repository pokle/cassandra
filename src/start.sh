#!/usr/bin/env bash

IP=`hostname --ip-address`
SEEDS="$1,$IP"

echo Configuring Cassandra to listen at $IP, with seeds: $SEEDS

DEFAULT=/etc/cassandra/default.conf
CONFIG=/etc/cassandra/conf

rm -rf $CONFIG
mkdir -p $CONFIG
cp $DEFAULT/cassandra.yaml $DEFAULT/log4j-server.properties $DEFAULT/cassandra-env.sh $CONFIG

sed -i -e "s/^listen_address.*/listen_address: $IP/"   $CONFIG/cassandra.yaml
sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/"   $CONFIG/cassandra.yaml
sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$SEEDS\"/" $CONFIG/cassandra.yaml
sed -i -e "s/# JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=<public name>\"/ JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=$IP\"/" $CONFIG/cassandra-env.sh

echo Starting Cassandra... 
cassandra -f
