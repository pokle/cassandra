#!/usr/bin/env bash
#
# Removes all trace of the test containers you created with run.sh

HOW_MANY=${1}
PREFIX=${2-cass}

if [[ ${#@} = 0 ]]; then
  echo Stops and removes containers suffixed with a number
  echo
  echo usage: $0 NUMBER-OF-CONTAINERS [CONTAINER-PREFIX]
  echo
  echo Defaults: CONTAINER-PREFIX:$PREFIX
  echo Example: $0 3      # => Nukes 3 Cassandra containers called cass1, cass2 & cass3
  echo Example: $0 1 demo # => Nukes 1 Cassandra container called demo1
  exit 1
fi


for (( instance=$HOW_MANY; $instance > 0; instance=$instance - 1 )); do
	CONTAINERS="$CONTAINERS ${PREFIX}${instance}"
done


docker kill $CONTAINERS
docker rm $CONTAINERS
