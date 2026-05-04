#!/usr/bin/env bash
# List "<ip> <name>" for every container attached to the cassandra network.
set -euo pipefail

NETWORK=${NETWORK:-cassandra}

docker network inspect "$NETWORK" \
  --format '{{range .Containers}}{{.IPv4Address}} {{.Name}}{{"\n"}}{{end}}' \
  | sed 's|/[0-9]*||'
