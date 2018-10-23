FROM ubuntu:16.04

ARG ambari_repo=http://public-repo-1.hortonworks.com/ambari/ubuntu16/2.x/updates/2.7.1.0/ambari.list
ARG ambari_os_user=root
ARG ambari_server_hostname=ambari-server-ubuntu

# add ambari ubuntu repository
RUN apt-get update
RUN apt-get install -y wget sudo
RUN wget -O /etc/apt/sources.list.d/ambari.list $ambari_repo
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update

RUN apt-get install -y ambari-agent

RUN sed -i "s/^hostname=.*/hostname=$ambari_server_hostname/g" /etc/ambari-agent/conf/ambari-agent.ini

ADD scripts/start.sh /root/start.sh
RUN chmod +x /root/start.sh

EXPOSE 9091
ENTRYPOINT  ["/root/start.sh"]
