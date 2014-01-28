#!/usr/bin/env bash
#
# Helps you run multiple instances of Cassandra.
# 
# usage: ./run.sh NUMBER

HOW_MANY=${1-1}
IMAGE=${2-poklet/cassandra}

PREFIX=cass

docker run -d -name ${PREFIX}1 $IMAGE
SEED=$(./ipof.sh ${PREFIX}1)

for (( instance=$HOW_MANY; $instance > 1; instance=$instance - 1 )); do
	docker run -d -name ${PREFIX}${instance} $IMAGE start.sh $SEED
done

