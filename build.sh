#!/usr/bin/env bash

docker build -t poklet/cassandra:`git describe --tags` .
