#!/usr/bin/env bash

AMBARI_REPO="http://public-repo-1.hortonworks.com/ambari/ubuntu16/2.x/updates/2.7.1.0/ambari.list"
AMBARI_DB_PASSWORD="bigdata"
AMBARI_DB_NAME="ambari"
AMBARI_DB_SCHEMA="ambari"
AMBARI_DB_USER="ambari"
AMBARI_OS_USER="root"
AMBARI_SERVER_HOSTNAME=ambari-server
AMBARI_AGENT_HOSTNAME=ambari-node
DATABASE_HOSTNAME=postgres
NETWORK="ambari-bridge"

printUsageAndExit() {
  echo "usage: $0 [-d password] [-n database_name] [-o osusername] [-r repourl] [-s database_schema] [-u database_user] [-h]"
  echo "       -h or --help                    print this message and exit"
  echo "       -d or --ambari-db-user          user to use for ambari database user      (default: $AMBARI_DB_USER)"
  echo "       -n or --ambari-db-name          name to use for ambari database name      (default: $AMBARI_DB_NAME)"
  echo "       -p or --ambari-db-password      password to use for ambari database       (default: $AMBARI_DB_PASSWORD)"
  echo "       -s or --ambari-db-schema        schema to use for ambari database schema  (default: $AMBARI_DB_SCHEMA)"
  echo "       -r or --ambari-repo             repository used to install ambari         (default: $AMBARI_REPO)"
  echo "       -u or --os-user                 username used in ambari setup"
  exit 1
}

# see https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/14203146#14203146
while [[ $# -ge 1 ]]; do
  key="$1"
  case $key in
    -h|--help)
    printUsageAndExit
    ;;
    -d|--ambari-db-user)
    AMBARI_DB_USER="$2"
    shift
    ;;
    -n|--ambari-db-name)
    AMBARI_DB_NAME="$2"
    shift
    ;;
    -p|--ambari-db-password)
    AMBARI_DB_PASSWORD="$2"
    shift
    ;;
    -r|--ambari-repo)
    AMBARI_REPO="$2"
    shift
    ;;
    -s|--ambari-db-schema)
    AMBARI_DB_SCHEMA="$2"
    shift
    ;;
    -u|--os-user)
    AMBARI_OS_USER="$2"
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

# http://stackoverflow.com/questions/59895/can-a-bash-script-tell-which-directory-it-is-stored-in#answer-246128
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$SCRIPT_DIR/../ambari-server"
echo "Building ambari-server from $(pwd)"
docker build --build-arg ambari_repo="$AMBARI_REPO" \
  --build-arg ambari-os-user="$AMBARI_OS_USER" \
  --build-arg ambari-db-user="$AMBARI_DB_USER" \
  --build-arg ambari-db-name="$AMBARI_DB_NAME" \
  --build-arg ambari-db-schema="$AMBARI_DB_SCHEMA" \
  --build-arg ambari-db-password="$AMBARI_DB_PASSWORD" \
  --build-arg database_hostname="$DATABASE_HOSTNAME" \
  --network $NETWORK \
  -t ambari-server-ubuntu .
if [ $? -ne 0 ]; then
    echo "Build of ambari-server failed, exiting..."
    exit 1
fi

cd "$SCRIPT_DIR/../ambari-agent"
docker build --build-arg ambari_repo="$AMBARI_REPO" \
  --build-arg ambari_server_hostname="$AMBARI_SERVER_HOSTNAME.$NETWORK" \
  -t ambari-agent-ubuntu .
