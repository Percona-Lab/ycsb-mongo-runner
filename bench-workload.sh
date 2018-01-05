#!/bin/bash

set -e
set -x 

DB_NAME=$1
MONGO_URL=$2
LOAD_THREADS=$3
LOAD_QPS=$4
RUN_THREADS=$5
RUN_QPS=$6
FLAGS="-p mongodb.url=$MONGO_URL ${@:7}"
BASEDIR=$(readlink -f $(dirname $0))

cat <<EOF >$BASEDIR/tmp/${DB_NAME}-init.js
db.usertable.createIndex({ _id: 1 });
sh.enableSharding("${DB_NAME}");
sh.shardCollection("${DB_NAME}.usertable", { _id: 1 });
EOF

runDeleter() {
  URL=$1
  BASEDIR=$2
  WORKERS=${3:-2}
  WORKER_COUNT=0
  while [ $WORKER_COUNT -lt 2 ]; do
    mongo --quiet $URL $BASEDIR/deleter.js &
    WORKER_COUNT=$(($WORKER_COUNT + 1))
  done
  wait
}

trap "exit" INT
while true; do
  runDeleter $MONGO_URL $BASEDIR 
  mongo --quiet $MONGO_URL $BASEDIR/tmp/${DB_NAME}-init.js
  $BASEDIR/ycsb/bin/ycsb load mongodb-async -threads $LOAD_THREADS -target $LOAD_QPS $FLAGS
  $BASEDIR/ycsb/bin/ycsb run mongodb-async -threads $RUN_THREADS -target $RUN_QPS $FLAGS
  sleep 10
done
