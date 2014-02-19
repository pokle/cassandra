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

- A host running Docker 0.7.2+
- You need to be able to run the docker command successfully as the currently logged in user. For example:

		$ docker version
		Client version: 0.7.4
		Go version (client): go1.2
		Git commit (client): 010d74e
		Server version: 0.7.6
		Git commit (server): bc3b2ec
		Go version (server): go1.2
		Last stable version: 0.7.6, please update docker

- If you're running as a user that can't run docker, add yourself to the docker group, or checkout out the project as root before you proceed. sudo might work too.

Build the poklet/cassandra docker image (optional):

	pushd cassandra && docker build -t poklet/cassandra . && popd

Build the poklet/opscenter docker image (optional):

	pushd opscenter && docker build -t poklet/opscenter . && popd

These 2 last steps are optional because Docker will automatically pull the image from [index.docker.io](https://index.docker.io) if you don't already have it. The build process needs an internet connexion but it is executed only once and then cached on Docker. If you modify the scripts, this is how you can re-build the image with your changes.


Single Cassandra node
---------------------

1. Launch a server called cass1:

		docker run -d -name cass1 poklet/cassandra

	You can also add the `-p 9042:9042` option to bind container's 9042 port (CQL / native transport port) to host's 9042 port.

2. Connect to it using `cqlsh`:

		docker run -i -t poklet/cassandra cqlsh $(./scripts/ipof.sh cass1) 

You should see something like:

	Connected to Test Cluster at 172.17.0.25:9160.
	[cqlsh 4.1.0 | Cassandra 2.0.3 | CQL spec 3.1.1 | Thrift protocol 19.38.0]
	Use HELP for help.
	cqlsh> 


3-node Cassandra cluster
------------------------

1. Launch three containers:

		docker run -d -name cass1 poklet/cassandra start
		docker run -d -name cass2 poklet/cassandra start $(./scripts/ipof.sh cass1)
		docker run -d -name cass3 poklet/cassandra start $(./scripts/ipof.sh cass1)
		# and so on...

	`start` script is passed the list of seeds - in this case, just the cass1's IP

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


Cassandra cluster + OpsCenter monitoring
----------------------------------------

1. Start the Cassandra cluster:

		docker run -d -name cass1 poklet/cassandra
		docker run -d -name cass2 poklet/cassandra start $(./scripts/ipof.sh cass1)
		docker run -d -name cass3 poklet/cassandra start $(./scripts/ipof.sh cass1)
		
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

