#!/usr/bin/env bash
# Stop and remove containers created by run.sh, and drop the shared network.
set -euo pipefail

HOW_MANY=${1:-}
PREFIX=${2:-cass}
NETWORK=${NETWORK:-cassandra}

if [[ -z $HOW_MANY ]]; then
  cat <<EOF
Nukes containers created by run.sh and removes the shared network.

usage: $0 NUMBER-OF-NODES [HOSTNAME-PREFIX]

env:
  NETWORK  Docker network name (default: $NETWORK)

examples:
  $0 3              # nuke cass1..cass3 and the 'cassandra' network
  $0 1 demo         # nuke demo1
EOF
  exit 1
fi

CONTAINERS=()
for (( i=1; i <= HOW_MANY; i++ )); do
  CONTAINERS+=("${PREFIX}${i}")
done

docker rm -f "${CONTAINERS[@]}" 2>/dev/null || true
docker network rm "$NETWORK" 2>/dev/null || true
