#!/usr/bin/env bash

MODE=cluster
AMBARI_SERVER_HOSTNAME=ambari-server
AMBARI_AGENT_HOSTNAME=ambari-node
DATABASE_HOSTNAME=postgres

printUsageAndExit() {
  echo "usage: $0 -d | -c [-h]"
  echo "       -h or --help                    print this message and exit"
  echo "       -d or --database                starts the database container"
  echo "       -c or --cluster                 starts the cluster containers"
  exit 1
}

if [[ $# -gt 1 ]]; then
  echo "Expected a single argument"
  printUsageAndExit
fi

# see https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/14203146#14203146
while [[ $# -eq 1 ]]; do
  key="$1"
  case $key in
    -h|--help)
    printUsageAndExit
    ;;
    -d|--database)
    MODE="database"
    shift
    ;;
    -c|--cluster)
    MODE="cluster"
    shift
    ;;
    *)
    echo "Unknown option: $key"
    echo
    printUsageAndExit
    ;;
  esac
  shift
done

NETWORK="ambari-bridge"
if [ -z "`docker network ls | awk '{print $2}' | grep \"^$NETWORK$\"`" ]; then
  echo "Creating $NETWORK network"
  docker network create --driver bridge $NETWORK
else
  echo "$NETWORK network already exists, not creating"
fi

if [ $MODE == "database" ]; then
  echo "Starting database container"
  docker run -d --hostname $DATABASE_HOSTNAME.$NETWORK --name $DATABASE_HOSTNAME --net $NETWORK -p 5432:5432 postgres:9.6.8
else
  echo "Starting cluster containers"
  docker run -d --hostname $AMBARI_SERVER_HOSTNAME.$NETWORK --name $AMBARI_SERVER_HOSTNAME --net $NETWORK -p 8080:8080 ambari-server-ubuntu
  docker run -d --hostname $AMBARI_AGENT_HOSTNAME-1.$NETWORK --name $AMBARI_AGENT_HOSTNAME-1 --net $NETWORK -p 9091:9091 ambari-agent-ubuntu
fi
