Cassandra on Docker
===================

This is a collection of images and scripts to help you run Cassandra in Docker containers.
These images are great to provision ephemeral Cassandra topologies for testing and development purpose.

- Currently supported:
    - A single Cassandra node
    - A client container to run tools such as cqlsh, nodetool, etc.
    - A multi-node cluster - running on a single Docker host
    - Monitored cluster using OpsCenter

- Work in progress:
    - A small cluster for production - running on multiple Docker hosts
        - The missing puzzle piece here is how to expose Cassandra on the real outside network so that peers running on different hosts can connect.

If you'd like to help, please get in touch with me, and/or send me pull requests.


Prerequisites
-------------

- A host running Docker - See https://www.docker.io/gettingstarted/#h_installation
- You need to be able to run the docker command successfully as the currently logged in user. For example:

        $ docker version
        Client version: 0.7.4
    ...

- If you're running as a user that can't run docker, add yourself to the docker group, or checkout out the project as root before you proceed. sudo might work too.

- Build the cassandra and opscenter images (optional)

        ./cassandra/build.sh
        ./opscenter/build.sh

The last step is optional because Docker will automatically pull the images from [index.docker.io](https://index.docker.io) if you don't already have them. The build process needs an Internet connection, but it is executed only once and then cached on Docker. If you modify the scripts, this is how you can re-build the images with your changes.


Single Cassandra node
---------------------

1. Launch a server called cass1:

        docker run -d -name cass1 poklet/cassandra

    You can also add the `-p 9042:9042` option to bind container's 9042 port (CQL / native transport port) to host's 9042 port.

2. Connect to it using `cqlsh` 
        
        docker run -it --rm --link cass1:cass poklet/cassandra cqlsh cass
        

    You should see something like:

        Connected to Test Cluster at 172.17.0.25:9160.
        [cqlsh 4.1.0 | Cassandra 2.0.3 | CQL spec 3.1.1 | Thrift protocol 19.38.0]
        Use HELP for help.
        cqlsh>

3. __Pre-populate Cassandra with a script__

    First we write a script that, for example, creates a table an inserts some data

        mkdir -p /data/cassandra/scripts
        vi /data/cassandra/scripts/init.cql

    In this script, we will define a `Keyspace`, create a table and add some data:

        CREATE KEYSPACE test_keyspace WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};
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

    Then, we run our docker container mounting a volume where our script is saved and called it through `cqlsh`

        docker run -it --rm --link cass1:cass1 -v /data/cassandra/scripts:/data poklet/cassandra bash -c 'cqlsh $CASS1_PORT_9160_TCP_ADDR -f /data/init.cql'

    You should see the result table:


        -> % docker run -it --rm --link cass1:cass1 -v /data/cassandra/scripts:/data poklet/cassandra bash -c 'cqlsh $CASS1_PORT_9160_TCP_ADDR -f /data/init.cql'

        system  test_keyspace  system_traces


         id | test_value
        ----+------------
          3 |      three
          2 |        two
          1 |        one

        (3 rows)


3-node Cassandra cluster
------------------------

1. Launch three containers:

        docker run -d -name cass1 poklet/cassandra start
        docker run -d -name cass2 poklet/cassandra start $(./scripts/ipof.sh cass1)
        docker run -d -name cass3 poklet/cassandra start $(./scripts/ipof.sh cass1)
        # and so on...

    The `start` script is passed the list of seeds - in this case, just the cass1's IP

2. Connect to it using `nodetool`:

        docker run -i -t poklet/cassandra nodetool -h $(./scripts/ipof.sh cass1) status

3. Create some data on the first container:

    Launch `cqlsh`:

        docker run -i -t poklet/cassandra cqlsh $(./scripts/ipof.sh cass1)

    Paste this in:

        create keyspace demo with replication = {'class':'SimpleStrategy', 'replication_factor':2};
        use demo;
        create table names ( id int primary key, name text );
        insert into names (id,name) values (1, 'gibberish');
        quit

4. Connect to the second container, and check if it can see your data:

    Start up `cqlsh` (on cass2 this time):

        docker run -i -t poklet/cassandra cqlsh $(./scripts/ipof.sh cass2)

    Paste in:

        select * from demo.names;

    You should see:

        cqlsh> select * from demo.names;

         id | name
        ----+-----------
          1 | gibberish

        (1 rows)


10-node Cassandra cluster (scripted!)
-------------------------------------

1. Right, lets dive right in with some shell scripts in the scripts directory to help us:

        ./scripts/run.sh 10

2. That will start 10 nodes. Lets see what they're called:

        ./scripts/ips.sh

        172.17.0.10 cass6
        172.17.0.12 cass4
        172.17.0.11 cass5
        172.17.0.6 cass10
        172.17.0.7 cass9
        172.17.0.9 cass7
        172.17.0.8 cass8
        172.17.0.4 cass2
        172.17.0.3 cass3
        172.17.0.2 cass1

3. Same, but with the nodetool:

        ./scripts/nodetool.sh cass1 status

        Datacenter: datacenter1
        =======================
        Status=Up/Down
        |/ State=Normal/Leaving/Joining/Moving
        --  Address      Load       Tokens  Owns (effective)  Host ID                               Rack
        UN  172.17.0.11  74.19 KB   256     21.4%             dfd44ca5-bf73-4487-bcb2-db882d0a9231  rack1
        UN  172.17.0.10  74.21 KB   256     19.6%             f479a4e6-55ac-4533-8ce5-d137a93f2cc4  rack1
        UN  172.17.0.9   74.34 KB   256     20.4%             0bb389a0-f111-459c-9620-0faccc75cbc0  rack1
        UN  172.17.0.8   74.19 KB   256     20.1%             2eb4a4dd-2bbc-46a3-9f64-4e761509307d  rack1
        UN  172.17.0.12  74.14 KB   256     20.2%             a2547289-0c6a-458f-b982-823711c5293e  rack1
        UN  172.17.0.3   74.19 KB   256     20.3%             3667cc1a-1f63-4cd1-bebc-841f428a0f4d  rack1
        UN  172.17.0.2   74.24 KB   256     20.3%             2b48c8ac-ad68-48a0-9c41-c8f2fb7f38e6  rack1
        UN  172.17.0.7   67.7 KB    256     19.2%             e361f6d8-28ef-4cf8-baa1-88c2d1fec094  rack1
        UN  172.17.0.6   74.15 KB   256     19.6%             230f13b1-a27b-44e8-9b51-5ebdb1c4cb13  rack1
        UN  172.17.0.4   74.18 KB   256     18.8%             6c90cbaa-e5b3-41de-a160-3ecaf59b8856  rack1

4. When you're tired of your cluster, nuke it with:

        ./scripts/nuke.sh 10

Set snitch and node location
----------------------------

The snitch type and node location information can be configured with environment variables.
The datacenter and rack configuration is only valid if using the GossipingPropertyFileSnitch type snitch.
For example:

        docker run -d -name cass1 -e SNITCH=GossipingPropertyFileSnitch -e DC=SFO -e RACK=RAC3 poklet/cassandra

This will set the snitch type and set the datacenter to **SFO** and the rack to **RAC3**

Auto-detect seeds
-----------------

Any containers linked in the run command will also be added to the seed list.  The 3-node cluster example above may also be written as:

        docker run -d -name cass1 poklet/cassandra
        docker run -d -name cass2 --link cass1:cass1 poklet/cassandra
        docker run -d -name cass3 --link cass1:cass1 poklet/cassandra
        # and so on...

Specifying clustering parameters
--------------------------------

When starting a container, you can pass the SEEDS, LISTEN_ADDRESS environment variables to override the defaults:

    docker run -e SEEDS=a,b,c... -e LISTEN_ADDRESS=10.2.1.4 poklet/cassandra

Note that listen_address will also be used for broadcast_address

Cassandra cluster + OpsCenter monitoring
----------------------------------------

1. Start a Cassandra cluster with 3 nodes:

        ./scripts/run.sh 3

2. Start the OpsCenter container:

        docker run -d -name opscenter poklet/opscenter

    You can also add the `-p 8888:8888` option to bind container's 8888 port to host's 8888 port

3. Connect and configure OpsCenter:

    - Open a browser and connect to [http://replace.me:8888](http://replace.me:8888) - replace the host by the result returned by `./scripts/ipof.sh opscenter`.
    - Click on the "Use Existing Cluster" button and put at least the IP of one node in the cluster in the host text box. The result of `./scripts/ipof.sh cass1` is a good candidate. Click "Save Cluster" button. OpsCenter start gathering data from the cluster but you do not get full-set metrics yet.
    - You should see a "0 of 3 agents connected" message on the top of the GUI. Click the "Fix" link aside.
    - In the popup, click "Enter Credentials" link and fill form with username `opscenter` and password `opscenter`. Click "Done".
    - Click "Install on all nodes" and then "Accept Fingerprints". OpsCenter installs agent on cluster'snodes remotly.
    - Once done, you should see the "All agents connected" message.
