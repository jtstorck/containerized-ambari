#!/usr/bin/env bash

AMBARI_DB_PASSWORD="bigdata"
AMBARI_DB_NAME="ambari"
AMBARI_DB_SCHEMA="ambari"
AMBARI_DB_USER="ambari"
AMBARI_OS_USER="root"
DATABASE_HOSTNAME=""

# see https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash/14203146#14203146
while [[ $# -ge 1 ]]; do
  key="$1"
  case $key in
    -h|--help)
    printUsageAndExit
    ;;
    -u|--os-user)
    AMBARI_OS_USER="$2"
    shift
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
    -s|--ambari-db-schema)
    AMBARI_DB_SCHEMA="$2"
    shift
    ;;
    --database-hostname)
    DATABASE_HOSTNAME="$2"
    shift
    ;;
    *)
    echo "Unknown option: $key"
    exit 1
    ;;
  esac
  shift
done

if [ -z "$DATABASE_HOSTNAME" ]; then
  echo "Expected a database hostname"
  exit 1
fi


echo -ne "y\n$AMBARI_OS_USER\n1\ny\nn\ny\n4\n$DATABASE_HOSTNAME\n\n$AMBARI_DB_NAME\n$AMBARI_DB_SCHEMA\n$AMBARI_DB_USER\n$AMBARI_DB_PASSWORD\n\n" | ambari-server setup
