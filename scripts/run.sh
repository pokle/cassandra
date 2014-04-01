#!/usr/bin/env bash
#
cd $(dirname $0)

HOW_MANY=${1}
PREFIX=${2-cass}
IMAGE=${3-poklet/cassandra}

if [[ ${#@} = 0 ]]; then
  echo Runs multiple Cassandra containers
  echo usage: $0 NUMBER-OF-CONTAINERS [HOSTNAME-PREFIX] [IMAGE-NAME]
  echo
  echo Defaults: HOSTNAME-PREFIX:$PREFIX, IMAGE-NAME:$IMAGE
  echo Example: $0 3      # => Runs 3 Cassandra container called cass1, cass2 & cass3
  echo Example: $0 1 demo # => Runs 1 Cassandra container called demo1
  exit 1
fi

docker run -d --name ${PREFIX}1 $IMAGE
SEED=$(./ipof.sh ${PREFIX}1)

for (( instance=$HOW_MANY; $instance > 1; instance=$instance - 1 )); do
	docker run -d --name ${PREFIX}${instance} $IMAGE start $SEED
done

