#!/usr/bin/env bash
# Spin up an N-node Cassandra cluster on a user-defined Docker network.
set -euo pipefail
cd "$(dirname "$0")"

HOW_MANY=${1:-}
PREFIX=${2:-cass}
NETWORK=${NETWORK:-cassandra}
IMAGE=${IMAGE:-cassandra:5}
MAX_HEAP_SIZE=${MAX_HEAP_SIZE:-1G}
HEAP_NEWSIZE=${HEAP_NEWSIZE:-256M}

if [[ -z $HOW_MANY ]]; then
  cat <<EOF
Runs a multi-node Cassandra cluster on a user-defined Docker network.

usage: $0 NUMBER-OF-NODES [HOSTNAME-PREFIX]

env:
  NETWORK         Docker network name (default: $NETWORK)
  IMAGE           Container image     (default: $IMAGE)
  MAX_HEAP_SIZE   JVM heap per node   (default: $MAX_HEAP_SIZE)
  HEAP_NEWSIZE    Young gen per node  (default: $HEAP_NEWSIZE)

examples:
  $0 3              # cass1, cass2, cass3 on the 'cassandra' network
  $0 1 demo         # one node called demo1
  IMAGE=poklet/cassandra $0 5
EOF
  exit 1
fi

docker network inspect "$NETWORK" >/dev/null 2>&1 || docker network create "$NETWORK"

# Serialise joins — Cassandra 4+ uses only 16 vnode tokens by default, so
# simultaneous bootstraps can pick colliding tokens and stall.
wait_for_ring() {
  local container=$1
  echo "Waiting for $container to be ready..."
  until docker exec "$container" nodetool info 2>/dev/null \
        | grep -q "Native Transport active: true"; do
    sleep 3
  done
}

SEED="${PREFIX}1"
HEAP_OPTS=(-e "MAX_HEAP_SIZE=$MAX_HEAP_SIZE" -e "HEAP_NEWSIZE=$HEAP_NEWSIZE")

docker run -d --name "$SEED" --network "$NETWORK" "${HEAP_OPTS[@]}" "$IMAGE"
wait_for_ring "$SEED"

for (( i=2; i <= HOW_MANY; i++ )); do
  docker run -d --name "${PREFIX}${i}" --network "$NETWORK" \
    "${HEAP_OPTS[@]}" -e CASSANDRA_SEEDS="$SEED" "$IMAGE"
  wait_for_ring "${PREFIX}${i}"
done
