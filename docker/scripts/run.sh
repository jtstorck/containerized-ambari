#!/usr/bin/env bash

DATABASE=''
CLUSTER=''
AMBARI_SERVER_HOSTNAME=ambari-server
AMBARI_AGENT_HOSTNAME=ambari-node
DATABASE_HOSTNAME=postgres
NUM_AGENT_NODES=1

printUsageAndExit() {
  echo "usage: $0 -d -c [-n #] [-h]"
  echo "       -h or --help                    print this message and exit"
  echo "       -d or --database                starts the database container"
  echo "       -c or --cluster                 starts the cluster containers"
  echo "       -n or --agent-node-count        specifies the number of ambari-agent containers"
  exit 1
}

if [[ $# -lt 1 ]]; then
  echo "Expected at least one argument"
  printUsageAndExit
fi

# see https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/14203146#14203146
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
    printUsageAndExit
    ;;
    -d|--database)
    DATABASE="DATABASE"
    ;;
    -c|--cluster)
    CLUSTER="CLUSTER"
    ;;
    -n|--agent-node-count)
    if [[ $2 -ge 1 ]]; then
      shift
      NUM_AGENT_NODES=$1
    else
      echo "-n,--agent-node-count argument must be a positive integer"
      echo
      printUsageAndExit
      exit 1
    fi
    ;;
    *)
    echo "Unknown option: $key"
    echo
    printUsageAndExit
    ;;
  esac
  shift
done

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-which-directory-it-is-stored-in#answer-246128
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NETWORK="ambari-bridge"
if [ -z "`docker network ls | awk '{print $2}' | grep \"^$NETWORK$\"`" ]; then
  echo "Creating $NETWORK network"
  docker network create --driver bridge $NETWORK
else
  echo "$NETWORK network already exists, not creating"
fi

if [ "$DATABASE" == "DATABASE" ]; then
  echo "Starting database container"
  docker run -d \
    --hostname $DATABASE_HOSTNAME.$NETWORK \
    --name $DATABASE_HOSTNAME \
    --network $NETWORK \
    -p 5432:5432 \
    postgres:9.6.8
fi

if [ "$CLUSTER" == "CLUSTER" ]; then
  echo "Starting traefik container"
  docker run -d \
    --hostname traefik.$NETWORK \
    --name traefik \
    --network $NETWORK \
    -p 80:80 \
    -p 8080:8080 \
    -v $SCRIPT_DIR/../traefik/conf/traefik.toml:/traefik.toml \
    -v /var/run/docker.sock:/var/run/docker.sock \
    traefik

  echo "Starting ambari-server container"
  docker run -d \
    --hostname $AMBARI_SERVER_HOSTNAME.$NETWORK \
    --name $AMBARI_SERVER_HOSTNAME \
    --network $NETWORK \
    --label traefik.frontend.rule=Host:ambari.traefik.localhost \
    --label traefik.port=8080 \
    --label traefik.enable=true \
    ambari-server-ubuntu
    
  echo "Starting $NUM_AGENT_NODES ambari-agent containers"
  for ((n=1; n <= $NUM_AGENT_NODES; n++)) do
    docker run -d \
      --hostname $AMBARI_AGENT_HOSTNAME-$n.$NETWORK \
      --name $AMBARI_AGENT_HOSTNAME-$n \
      --network $NETWORK \
      ambari-agent-ubuntu
  done
fi
