#!/usr/bin/env bash
CONTAINER=$1
docker inspect -format '{{ .NetworkSettings.IPAddress }}' $CONTAINER
