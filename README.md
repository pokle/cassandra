Cassandra on Docker
===================

This is a collection of scripts to help you run Cassandra in Docker containers.

- Currently supported:
	- A single server container for development
	- A single client container to run client tools such as cqlsh, nodetool, etc.
	- A small cluster for development - running on a single Docker host

- Work in progress:
	- A small cluster for production - running on multiple Docker hosts
		- The missing puzzle piece here is how to expose Cassandra on the real outside network so that peers running on different hosts can connect.

If you'd like to help, please get in touch with me, and/or send me pull requests.

Prerequisites
-------------

A host running Docker 0.7.2+

- I test on either CoreOS or Docker's Ubuntu on EC2 / Vagrant
- But really, any Linux distribution should do

Build the poklet/cassandra docker image (optional)

	./build.sh

This step is optional, because Docker will pull the image from https://index.docker.io if you don't already have it. If you modify the scripts, this is how you can re-build the image with your changes.


Single container
----------------

1. Launch a server called cass1:

		docker run -d -name cass1 poklet/cassandra

2. Connect to it:

		CASS1_IP=$(./ipof.sh cass1)
		docker run -i -t poklet/cassandra cqlsh $CASS1_IP
	

You should see something like:

	Connected to Test Cluster at 172.17.0.25:9160.
	[cqlsh 4.1.0 | Cassandra 2.0.3 | CQL spec 3.1.1 | Thrift protocol 19.38.0]
	Use HELP for help.
	cqlsh> 



Cluster on the same docker host
-------------------------------

1. Launch two containers

		docker run -d -name cass1 poklet/cassandra start.sh
		docker run -d -name cass2 poklet/cassandra start.sh $(./ipof.sh cass1)

	start.sh is passed the list of seeds - in this case, just cass1

2. Create some data on the first container

	Start up cqlsh

		docker run -i -t poklet/cassandra cqlsh $(./ipof.sh cass1)

	Paste this in:

		create keyspace demo with replication = {'class':'SimpleStrategy', 'replication_factor':2};
		use demo;
		create table names ( id int primary key, name text );
		insert into names (id,name) values (1, 'gibberish');
		quit

3. Connect to the second container, and check if it can see your data

	Start up cqlsh (on cass2 this time)

		docker run -i -t poklet/cassandra cqlsh $(./ipof.sh cass2)

	Paste in:

		select * from demo.names

	You should see:

		cqlsh> select * from demo.names;

		 id | name
		----+-----------
		  1 | gibberish

		(1 rows)