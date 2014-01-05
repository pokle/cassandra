# Following instructions at http://www.datastax.com/documentation/cassandra/2.0/webhelp/index.html#cassandra/install/installDeb_t.html

# Base operating system image
FROM centos

# Plus some packages
RUN yum install -y java-1.7.0-openjdk-devel.x86_64 which


# Install datastax Cassandra
ADD src/datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum install -y dsc20

# Create a home directory for cassandra so you can run the client apps
RUN mkdir -p /home/cassandra
RUN chown cassandra:cassandra /home/cassandra
RUN usermod --home /home/cassandra cassandra
ENV HOME /home/cassandra

ADD src/start.sh /usr/local/bin/start.sh

EXPOSE 9160 7000 7001 9042 7199
USER cassandra
CMD start.sh
