#!/usr/bin/env bash
# Build poklet/cassandra locally for the host architecture.
# Pass --push to build & publish a multi-arch (amd64 + arm64) image to Docker Hub.
set -euo pipefail
cd "$(dirname "$0")"

IMAGE=${IMAGE:-poklet/cassandra}

if [[ "${1-}" == "--push" ]]; then
  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag "$IMAGE:5" \
    --tag "$IMAGE:latest" \
    --push \
    .
else
  docker build --tag "$IMAGE" .
fi
