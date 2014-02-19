#!/usr/bin/env bash

IP=`hostname --ip-address`
if [ $# == 1 ]; then SEEDS="$1,$IP"; 
else SEEDS="$IP"; fi

echo Configuring Cassandra to listen at $IP with seeds $SEEDS

# Setup Cassandra
DEFAULT=/etc/cassandra/default.conf
CONFIG=/etc/cassandra/conf

rm -rf $CONFIG && cp -r $DEFAULT $CONFIG
sed -i -e "s/^listen_address.*/listen_address: $IP/"            $CONFIG/cassandra.yaml
sed -i -e "s/^rpc_address.*/rpc_address: 0.0.0.0/"              $CONFIG/cassandra.yaml
sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$SEEDS\"/"       $CONFIG/cassandra.yaml
sed -i -e "s/# JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=<public name>\"/ JVM_OPTS=\"$JVM_OPTS -Djava.rmi.server.hostname=$IP\"/" $CONFIG/cassandra-env.sh

# Start process
echo Starting Cassandra on $IP...
/usr/bin/supervisord 
