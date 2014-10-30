# OpsCenter
#
# VERSION		1.0

FROM centos:centos7

# Install datastax OpsCenter
ADD src/datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum install -y openssh-clients
RUN yum install -y opscenter 
RUN yum install -y which
RUN yum install -y hostname
ADD src/start.sh /usr/local/bin/start

# See http://www.datastax.com/documentation/opscenter/4.0/opsc/reference/opscPorts_r.html
EXPOSE 8888 61620 50031
USER root 
CMD start 
