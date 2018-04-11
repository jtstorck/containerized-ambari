#!/usr/bin/env bash

startedFile="/root/container-was-started"
if [ ! -e "$startedFile" ] ; then
  # container hasn't been started yet, additional setup steps should run
  :
fi
ambari-server start
if [ ! -e "$startedFile" ] ; then
  # ambari successfully started, create startedFile to prevent ambari db setup steps above from running
  touch $startedFile
fi

tail -f /var/log/ambari-server/ambari-server.log
