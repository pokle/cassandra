Cassandra on Docker
===================

This is a collection of scripts to help you run Cassandra in Docker containers.

These are the deployment scenarios currently supported:

- A single server container for development
- A single client container to run client tools such as cqlsh, nodetool, etc.

And these are scenarios I'm still working on. If you'd like to help, send me a pull request!

- A small cluster for development - running on a single Docker host
	- The missing puzzle piece here is telling cassandra how to find its peers (seeds). Docker assigns dynamic IP addresses.
- A small cluster for production - running on multiple Docker hosts
	- The missing puzzle piece here is how to expose Cassandra on the real outside network so that peers running on different hosts can connect.

What you'll need before you begin
---------------------------------

- A host running Docker 0.7.2+
	- I test on either CoreOS or Docker's Ubuntu on EC2 / Vagrant
	- But really, any Linux distribution should do
- Git

First step: Build the poklet/cassandra docker image (optional)

	./build.sh

This step is optional, because Docker will pull the image from https://index.docker.io if you don't already have it.


Begin: Launch a single Cassandra server container for development
-----------------------------------------------------------------

Launch a server:

	CASSANDRA_CONTAINER=$(docker run -d poklet/cassandra)
	IP=$(docker inspect -format '{{ .NetworkSettings.IPAddress }}' $CASSANDRA_CONTAINER)

Connect to it:

	docker run -i -t poklet/cassandra bash -c "HOME=/tmp cqlsh $IP"
	

You should see something like:

	Connected to Test Cluster at 172.17.0.25:9160.
	[cqlsh 4.1.0 | Cassandra 2.0.3 | CQL spec 3.1.1 | Thrift protocol 19.38.0]
	Use HELP for help.
	cqlsh> 



