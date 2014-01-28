#!/usr/bin/env bash
#
# Removes all trace of the test containers you created with run.sh

HOW_MANY=${1-1}

PREFIX=cass

for (( instance=$HOW_MANY; $instance > 0; instance=$instance - 1 )); do
	CONTAINERS="$CONTAINERS ${PREFIX}${instance}"
done


docker kill $CONTAINERS
docker rm $CONTAINERS
