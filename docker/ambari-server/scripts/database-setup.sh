#!/usr/bin/env bash

AMBARI_DB_PASSWORD="bigdata"
AMBARI_DB_NAME="ambari"
AMBARI_DB_SCHEMA="ambari"
AMBARI_DB_USER="ambari"
DATABASE_HOSTNAME=""

while [[ $# -ge 1 ]]; do
  key="$1"
  case $key in
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

# initialize postgres for ambari
psql \
    -X \
    -U postgres \
    -h $DATABASE_HOSTNAME \
    -f /root/init_postgres.sql \
    --echo-all \
    --set AUTOCOMMIT=on \
    --set ON_ERROR_STOP=on \
    --set AMBARI_DB_NAME=$AMBARI_DB_NAME \
    --set AMBARI_DB_USER=$AMBARI_DB_USER \
    --set AMBARI_DB_PASSWORD=$AMBARI_DB_PASSWORD \
    --set AMBARI_DB_SCHEMA=$AMBARI_DB_SCHEMA

#initialize ambari database
psql \
    -X \
    -U ambari \
    -h $DATABASE_HOSTNAME \
    -f /root/init_ambari_database.sql \
    --echo-all \
    --set AUTOCOMMIT=on \
    --set ON_ERROR_STOP=on \
    --set AMBARI_DB_NAME=$AMBARI_DB_NAME
