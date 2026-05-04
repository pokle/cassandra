#!/usr/bin/env bash
# Run nodetool inside the network namespace of an existing Cassandra container.
set -euo pipefail

IMAGE=${IMAGE:-cassandra:5}
CONTAINER=${1:-}
shift || true

if [[ -z $CONTAINER ]]; then
  cat <<EOF
usage: $0 CONTAINER ARGS...
  ARGS are passed to nodetool, executed inside CONTAINER's network namespace.

example:
  $0 cass1 status
EOF
  exit 1
fi

docker run --rm --net "container:$CONTAINER" "$IMAGE" nodetool "$@"
