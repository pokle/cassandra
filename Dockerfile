# Following instructions at http://www.datastax.com/documentation/cassandra/2.0/webhelp/index.html#cassandra/install/installDeb_t.html

# Base operating system image
FROM centos

# Install HotSpot JDK 7u51
RUN wget -O - --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.rpm" > /tmp/jdk-7u51-linux-x64.rpm
RUN rpm -ivh /tmp/jdk-7u51-linux-x64.rpm
RUN alternatives --install /usr/bin/java java /usr/java/default/bin/java 20000
RUN rm /tmp/jdk-7u51-linux-x64.rpm

# Install datastax Cassandra
ADD src/datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum install -y dsc20

# Create cassandra user home 
RUN mkdir -p /home/cassandra && chown cassandra: /home/cassandra
RUN usermod -d /home/cassandra cassandra
ENV HOME /home/cassandra

ADD src/start.sh /usr/local/bin/start.sh

EXPOSE 9160 7000 7001 9042 7199
USER cassandra
CMD start.sh
