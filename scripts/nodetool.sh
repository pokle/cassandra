#!/usr/bin/env bash

cd $(dirname $0)

CONTAINER=$1
shift

if [ -z "$CONTAINER" ]; then
	echo usage: $0 CONTAINER ARGS...
	echo   ARGS are passed to nodetool on CONTAINER
	echo
	echo   example: ./nodetool.sh cass3 status
	exit 1
fi

HOST=$(./ipof.sh $CONTAINER)

docker run --rm -i -t poklet/cassandra nodetool --host $HOST $@
