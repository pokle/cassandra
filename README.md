Cassandra on Docker
===================

A small set of helper scripts (and an optional thin Docker image) for spinning
up ephemeral Apache Cassandra topologies on a single Docker host. Handy for
local testing, demos, and learning CQL.

The walkthroughs below use the [official `cassandra` image][offimg] directly,
so no build step is required to follow along.

[offimg]: https://hub.docker.com/_/cassandra


Prerequisites
-------------

- A recent Docker (28+ recommended). See [docker.com](https://www.docker.com).
- Verify with `docker ps`.


Single Cassandra node
---------------------

1. Start a node:

        docker run -d --name cassone cassandra:5

2. Connect with `cqlsh` (give it a few seconds to come up if it errors):

        docker run -it --rm --net container:cassone cassandra:5 cqlsh

   You should see something like:

        Connected to Test Cluster at 127.0.0.1:9042
        [cqlsh 6.x.x | Cassandra 5.x.x | CQL spec 3.x.x | Native Protocol v5]
        Use HELP for help.
        cqlsh>

3. Try some CQL — paste this into the cqlsh prompt:

        CREATE KEYSPACE test_keyspace WITH REPLICATION =
          {'class': 'SimpleStrategy', 'replication_factor': 1};

        USE test_keyspace;

        CREATE TABLE test_table (
          id text,
          test_value text,
          PRIMARY KEY (id)
        );

        INSERT INTO test_table (id, test_value) VALUES ('1', 'one');
        INSERT INTO test_table (id, test_value) VALUES ('2', 'two');
        INSERT INTO test_table (id, test_value) VALUES ('3', 'three');

        SELECT * FROM test_table;

   You should see:

         id | test_value
        ----+------------
          3 |      three
          2 |        two
          1 |        one

        (3 rows)

4. Tear it down:

        docker rm -f cassone


3-node Cassandra cluster
------------------------

Multi-node Cassandra needs the nodes to find each other by name, so put them
on a user-defined Docker network — Docker's embedded DNS resolves container
names to IPs automatically.

1. Create a network and launch the seed node:

        docker network create cassandra
        HEAP="-e MAX_HEAP_SIZE=1G -e HEAP_NEWSIZE=256M"
        docker run -d --name cass1 --network cassandra $HEAP cassandra:5

2. Wait for cass1 to finish coming up before adding more nodes — Cassandra
   4+ uses only 16 vnode tokens by default, so simultaneous bootstraps can
   pick colliding tokens and stall:

        until docker exec cass1 nodetool info 2>/dev/null \
              | grep -q "Native Transport active: true"; do sleep 3; done

3. Add cass2, wait for it, then cass3:

        docker run -d --name cass2 --network cassandra $HEAP -e CASSANDRA_SEEDS=cass1 cassandra:5
        until docker exec cass2 nodetool info 2>/dev/null \
              | grep -q "Native Transport active: true"; do sleep 3; done
        docker run -d --name cass3 --network cassandra $HEAP -e CASSANDRA_SEEDS=cass1 cassandra:5

   `CASSANDRA_SEEDS` is read by the official image's entrypoint and written
   into `cassandra.yaml`. `MAX_HEAP_SIZE`/`HEAP_NEWSIZE` keep three JVMs
   from blowing through your laptop's RAM — Cassandra's default sizing
   assumes a dedicated host.

4. Check status — all three nodes should be `UN` (Up / Normal):

        docker run -it --rm --net container:cass1 cassandra:5 nodetool status

5. Write some data on cass1:

        docker run -it --rm --net container:cass1 cassandra:5 cqlsh

   In the prompt:

        CREATE KEYSPACE demo WITH REPLICATION =
          {'class': 'SimpleStrategy', 'replication_factor': 2};
        USE demo;
        CREATE TABLE names (id int PRIMARY KEY, name text);
        INSERT INTO names (id, name) VALUES (1, 'gibberish');
        QUIT;

6. Read it back from cass2:

        docker run -it --rm --net container:cass2 cassandra:5 cqlsh -e 'SELECT * FROM demo.names;'

7. Tear it all down:

        docker rm -f cass1 cass2 cass3
        docker network rm cassandra


3-node cluster, with docker compose
-----------------------------------

Same thing, declaratively:

        docker compose up -d
        docker compose exec cass1 nodetool status
        docker compose down


N-node cluster (scripted)
-------------------------

For larger clusters use the helpers in `scripts/`:

        ./scripts/run.sh 10              # 10 nodes called cass1..cass10
        ./scripts/ips.sh                 # list IPs on the cassandra network
        ./scripts/nodetool.sh cass1 status
        ./scripts/cqlsh.sh cass1
        ./scripts/nuke.sh 10             # stop, remove, drop network

All scripts default to the upstream `cassandra:5` image. To use a custom build
(see below) set `IMAGE=poklet/cassandra` in the environment.


Configuring snitch / DC / rack
------------------------------

The official image accepts these env vars (passed straight into
`cassandra.yaml`):

- `CASSANDRA_ENDPOINT_SNITCH` — e.g. `GossipingPropertyFileSnitch`
- `CASSANDRA_DC` — datacenter name (only used by the gossiping snitch)
- `CASSANDRA_RACK` — rack name (ditto)
- `CASSANDRA_SEEDS` — comma-separated seed hosts
- `CASSANDRA_LISTEN_ADDRESS` — defaults to `auto` (the container's IP)
- `CASSANDRA_BROADCAST_ADDRESS`, `CASSANDRA_RPC_ADDRESS`,
  `CASSANDRA_BROADCAST_RPC_ADDRESS`, `CASSANDRA_CLUSTER_NAME`, ...

Example:

        docker run -d --name cass1 --network cassandra \
          -e CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch \
          -e CASSANDRA_DC=SFO -e CASSANDRA_RACK=RAC3 \
          cassandra:5

See the [image docs][offimg] for the full list.


Building a custom image (optional)
----------------------------------

The `cassandra/` directory contains a thin `Dockerfile` (`FROM cassandra:5`)
and a `build.sh` that publishes it as `poklet/cassandra`. It exists as a
hook for layering on local tweaks (extra packages, JVM opts, etc.). You don't
need to build anything to follow the walkthroughs above.

        ./cassandra/build.sh             # native build, tagged poklet/cassandra
        ./cassandra/build.sh --push      # multi-arch (amd64+arm64) buildx push
