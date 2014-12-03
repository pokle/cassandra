# Cassandra
#
# VERSION               1.0

FROM centos:centos7

# Add source repositories
ADD src/epel7.repo /etc/yum.repos.d/epel7.repo
ADD src/datastax.repo /etc/yum.repos.d/datastax.repo

# Install Java, Install packages (sshd + supervisord + monitoring tools + cassandra)
RUN yum install -y wget tar openssh-server openssh-clients supervisor dsc21 sysstat sudo which openssl hostname && \
	yum clean all && \
	wget --progress=dot:giga -O /tmp/jdk.rpm --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.rpm" && \
	rpm -ivh /tmp/jdk.rpm && rm /tmp/jdk.rpm && \
	alternatives --install /usr/bin/java java /usr/java/default/bin/java 20000

# Configure SSH server
# Create OpsCenter account
RUN mkdir -p /var/run/sshd && chmod -rx /var/run/sshd && \
	ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key && \
	sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
	sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
	sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
	useradd -m -G users,root -p $(openssl passwd -1 "opscenter") opscenter && \
	echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configure supervisord
ADD src/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisor

# Deploy startup script
ADD src/start.sh /usr/local/bin/start

# Necessary since cassandra is trying to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf

# Work around a nasty Cassandra packaging error
RUN sed -i s/jamm-0.2.6.jar/jamm-0.2.8.jar/ /usr/share/cassandra/cassandra.in.sh

EXPOSE 7199 7000 7001 9160 9042
EXPOSE 22 8012 61621
USER root
CMD start
