#!/usr/bin/env bash
# Open a cqlsh session against an existing Cassandra container.
set -euo pipefail

IMAGE=${IMAGE:-cassandra:5}
CONTAINER=${1:-cass1}

docker run -it --rm --net "container:$CONTAINER" "$IMAGE" cqlsh
