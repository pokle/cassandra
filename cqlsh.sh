#!/usr/bin/env bash

CONTAINER=${1-cass1}
HOST=$(./ipof.sh $CONTAINER)
docker run -rm -i -t poklet/cassandra cqlsh $HOST