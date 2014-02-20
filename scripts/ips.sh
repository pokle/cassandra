#!/usr/bin/env bash

docker ps -q | xargs -n 1 docker inspect -format '{{ .NetworkSettings.IPAddress }}'
