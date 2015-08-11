#!/usr/bin/env bash

cd $(dirname $0)

CONTAINER=${1-cass1}
docker run -it --rm --link $CONTAINER:$CONTAINER poklet/cassandra cqlsh $CONTAINER
