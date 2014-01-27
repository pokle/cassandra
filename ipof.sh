#!/usr/bin/env bash
CONTAINER=$1
sudo docker inspect -format '{{ .NetworkSettings.IPAddress }}' $CONTAINER
