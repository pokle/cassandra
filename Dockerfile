# Following instructions at http://www.datastax.com/documentation/cassandra/2.0/webhelp/index.html#cassandra/install/installDeb_t.html

# Base operating system image
FROM centos

# Plus some packages
RUN yum install -y java-1.7.0-openjdk-devel.x86_64 which


# Install datastax Cassandra
ADD src/datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum install -y dsc20

ADD src/start.sh /usr/local/bin/start.sh

EXPOSE 9160 7000 7001
USER cassandra
CMD /usr/local/bin/start.sh
