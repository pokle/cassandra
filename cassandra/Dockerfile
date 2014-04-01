# Cassandra 
#
# VERSION               1.0

FROM centos

# Install HotSpot JDK 7u51
RUN wget -q -O - --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8-b132/jdk-8-linux-x64.rpm" > /tmp/jdk.rpm
RUN rpm -ivh /tmp/jdk.rpm && rm /tmp/jdk.rpm
RUN alternatives --install /usr/bin/java java /usr/java/default/bin/java 20000

# Install packges (sshd + supervisord + monitoring tools + cassandra)
ADD src/epel6.repo /etc/yum.repos.d/epel6.repo
ADD src/datastax.repo /etc/yum.repos.d/datastax.repo
RUN yum install -y openssh-server openssh-clients 
RUN yum install -y supervisor 
RUN yum install -y dsc20
RUN yum install -y sysstat sudo which 

# Configure SSH server
RUN mkdir -p /var/run/sshd && chmod -rx /var/run/sshd
RUN ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key
RUN sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config

# Create OpsCenter account
RUN useradd -m -G users,root -p $(openssl passwd -1 "opscenter") opscenter
RUN echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configure supervisord
ADD src/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisor

# Deploy startup script
ADD src/start.sh /usr/local/bin/start

# Necessary since cassandra try to override the system limitations
# See https://groups.google.com/forum/#!msg/docker-dev/8TM_jLGpRKU/dewIQhcs7oAJ
RUN rm -f /etc/security/limits.d/cassandra.conf
# Necassary to make df tool run correctly
# See https://groups.google.com/d/msg/docker-user/zC_wX1Uyl_U/Q5Ex5kg1VQ0J
RUN ln -s /proc/mounts /etc/mtab

EXPOSE 7199 7000 7001 9160 9042
EXPOSE 22 8012 61621
USER root 
CMD start
