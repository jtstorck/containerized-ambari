FROM ubuntu:16.04

ARG ambari_repo=http://public-repo-1.hortonworks.com/ambari/ubuntu16/2.x/updates/2.6.1.5/ambari.list
ARG ambari_os_user=root
ARG ambari_db_name=ambari
ARG ambari_db_user=ambari
ARG ambari_db_schema=ambari
ARG ambari_db_password=bigdata
ARG database_hostname

RUN if [ -z "$database_hostname" ]; then echo "Expected a database hostname"; exit 1; fi

VOLUME /resources

# add ambari ubuntu repository
RUN apt-get update
RUN apt-get install -y wget sudo
RUN wget -O /etc/apt/sources.list.d/ambari.list $ambari_repo
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update

RUN apt-get install -y ambari-server

ADD scripts/ambari-setup.sh /root/ambari-setup.sh
RUN chmod +x /root/ambari-setup.sh

ADD scripts/init_postgres.sql /root/init_postgres.sql
ADD scripts/init_ambari_database.sql /root/init_ambari_database.sql
ADD scripts/database-setup.sh /root/database-setup.sh
RUN chmod +x /root/database-setup.sh

ADD scripts/start.sh /root/start.sh
RUN chmod +x /root/start.sh

RUN /root/ambari-setup.sh --os-user $ambari_os_user --ambari-db-user $ambari_db_user --ambari-db-name $ambari_db_name --ambari-db-schema $ambari_db_schema --ambari-db-password $ambari_db_password --database-hostname $database_hostname
RUN /root/database-setup.sh --ambari-db-user $ambari_db_user --ambari-db-name $ambari_db_name --ambari-db-schema $ambari_db_schema --ambari-db-password $ambari_db_password --database-hostname $database_hostname

EXPOSE 8080
ENTRYPOINT  ["/root/start.sh"]
