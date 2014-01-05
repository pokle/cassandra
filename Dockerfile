# Following instructions at http://www.datastax.com/documentation/cassandra/2.0/webhelp/index.html#cassandra/install/installDeb_t.html

# Base operating system image
FROM centos

# Plus some packages
RUN yum install -y java-1.7.0-openjdk-devel.x86_64 which

# ADD busts the cache, so lets just resort to this pain
# to speed up the build until this bug is fixed and available on CoreOS
#  https://github.com/dotcloud/docker/issues/880
RUN echo '[datastax]' > /etc/yum.repos.d/datastax.repo
RUN echo 'name = DataStax Repo for Apache Cassandra' >> /etc/yum.repos.d/datastax.repo
RUN echo 'baseurl = http://rpm.datastax.com/community' >> /etc/yum.repos.d/datastax.repo
RUN echo 'enabled = 1' >> /etc/yum.repos.d/datastax.repo
RUN echo 'gpgcheck = 0' >> /etc/yum.repos.d/datastax.repo

RUN yum install -y dsc20

ADD src/start.sh /usr/local/bin/start.sh

EXPOSE 9160 7000 7001
USER cassandra
CMD /usr/local/bin/start.sh
