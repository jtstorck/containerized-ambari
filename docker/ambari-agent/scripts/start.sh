#!/usr/bin/env bash

ambari-agent start

tail -f /var/log/ambari-agent/ambari-agent.log