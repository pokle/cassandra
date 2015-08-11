Cassandra on Docker
===================

This is a collection of images and scripts to help you run Cassandra in Docker containers.
These images are great to provision ephemeral Cassandra topologies for testing and development purpose.

- Currently supported:
    - A single Cassandra node
    - A client container to run tools such as cqlsh, nodetool, etc.
    - A multi-node cluster - running on a single Docker host
    - Monitored cluster using OpsCenter

If you'd like to help, please get in touch with me, and/or send me pull requests.


Prerequisites
-------------

- A recent version of Docker - See [https://www.docker.com](https://www.docker.com)
- Verify that the docker command works. Try running 'docker ps' for example.
- Build the cassandra and opscenter images (optional)

        ./cassandra/build.sh
        ./opscenter/build.sh

The last step is optional because Docker will automatically pull the images from [index.docker.io](https://index.docker.io) if you don't already have them. The build process needs an Internet connection, but it is executed only once and then cached on Docker. If you modify the scripts, this is also how you can re-build the images with your changes.


Single Cassandra node
-----------------------------------
Here's how to start a Cassandra cluster with a single node, and run some CQL on it. These instructions use the docker command directly to demonstrate what's happening behind the scenes. 


1. Launch a container running Cassandra called cassone:

        docker run --detach --name cassone poklet/cassandra

2. Connect to it using cqlsh

        docker run -it --rm --net container:cassone poklet/cassandra cqlsh

    You should see something like:

        [cqlsh 5.0.1 | Cassandra 2.2.0 | CQL spec 3.3.0 | Native protocol v4]
		Use HELP for help.
		cqlsh> quit

	If not, then try it again in a few seconds - cassandra might still be starting up.


3. Lets try some CQL

	Paste the following into your cqlsh prompt to create a test keyspace, and a test table:

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


	If that worked, you should see:
	
		 id | test_value
		----+------------
		  3 |      three
		  2 |        two
		  1 |        one
		
		(3 rows)


3-node Cassandra cluster
------------------------

1. Launch three containers (one seed plus two more)

        docker run -d --name cass1 poklet/cassandra start
        docker run -d --name cass2 --link cass1:seed poklet/cassandra start seed
        docker run -d --name cass3 --link cass1:seed poklet/cassandra start seed


    Note: The poklet/cassandra docker image contains a shell script called `start` that takes an optional seed host. We use `--link cass1:seed` to name the cass1 host as our seed host.

2. Run `nodetool status` on cass1 to check the cluster status:

        docker run -it --rm --net container:cass1 poklet/cassandra nodetool status

3. Create some data on the first container:

    Launch `cqlsh`:

        docker run -it --rm --net container:cass1 poklet/cassandra cqlsh

    Paste this in:

        create keyspace demo with replication = {'class':'SimpleStrategy', 'replication_factor':2};
        use demo;
        create table names ( id int primary key, name text );
        insert into names (id,name) values (1, 'gibberish');
        quit;
        

4. Connect to the second container, and check if it can see your data:

    Start up `cqlsh` (on cass2 this time):

        docker run -it --rm --net container:cass2 poklet/cassandra cqlsh

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

        docker run -d --name cass1 -e SNITCH=GossipingPropertyFileSnitch -e DC=SFO -e RACK=RAC3 poklet/cassandra

This will set the snitch type and set the datacenter to **SFO** and the rack to **RAC3**

Auto-detect seeds
-----------------

Any containers linked in the run command will also be added to the seed list.  The 3-node cluster example above may also be written as:

        docker run -d --name cass1 poklet/cassandra
        docker run -d --name cass2 --link cass1:cass1 poklet/cassandra
        docker run -d --name cass3 --link cass1:cass1 poklet/cassandra
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

        docker run -d --name opscenter poklet/opscenter

    You can also add the `-p 8888:8888` option to bind container's 8888 port to host's 8888 port

3. Connect and configure OpsCenter:

    - Open a browser and connect to [http://replace.me:8888](http://replace.me:8888) - replace the host by the result returned by `./scripts/ipof.sh opscenter`.
    - Click on the "Use Existing Cluster" button and put at least the IP of one node in the cluster in the host text box. The result of `./scripts/ipof.sh cass1` is a good candidate. Click "Save Cluster" button. OpsCenter start gathering data from the cluster but you do not get full-set metrics yet.
    - You should see a "0 of 3 agents connected" message on the top of the GUI. Click the "Fix" link aside.
    - In the popup, click "Enter Credentials" link and fill form with username `opscenter` and password `opscenter`. Click "Done".
    - Click "Install on all nodes" and then "Accept Fingerprints". OpsCenter installs agent on cluster'snodes remotly.
    - Once done, you should see the "All agents connected" message.
