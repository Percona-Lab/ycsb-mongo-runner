#!/bin/bash

set -e

BASEDIR=$(readlink -f $(dirname $0))

[ -z $MONGO_URL_PREFIX ] && MONGO_URL_PREFIX=mongodb://localhost:27017

WORKLOAD_A_LOAD_THREADS=2
WORKLOAD_A_LOAD_QPS=1000
WORKLOAD_A_RUN_THREADS=2
WORKLOAD_A_RUN_QPS=1000
WORKLOAD_A_DB_NAME=ycsb_a
WORKLOAD_A_DB_URL="${MONGO_URL_PREFIX}/${WORKLOAD_A_DB_NAME}?readPreference=secondaryPreferred&maxPoolSize=25"
WORKLOAD_A_FLAGS="-p recordcount=100000 \
        -p operationcount=1000000 \
        -p readproportion=0.5 \
        -p updateproportion=0.3 \
        -p scanproportion=0.1 \
        -p insertproportion=0.1 \
        -P $BASEDIR/ycsb/workloads/workloada"

WORKLOAD_B_LOAD_THREADS=2
WORKLOAD_B_LOAD_QPS=500
WORKLOAD_B_RUN_THREADS=2
WORKLOAD_B_RUN_QPS=500
WORKLOAD_B_DB_NAME=ycsb_b
WORKLOAD_B_DB_URL="${MONGO_URL_PREFIX}/${WORKLOAD_B_DB_NAME}?readPreference=secondaryPreferred&maxPoolSize=25"
WORKLOAD_B_FLAGS="-p recordcount=100000 \
        -p operationcount=500000 \
        -p readproportion=0.8 \
        -p updateproportion=0.1 \
        -p scanproportion=0 \
        -p insertproportion=0.1 \
        -P $BASEDIR/ycsb/workloads/workloadb"

trap "cat $BASEDIR/tmp/*.pid | xargs kill 2>/dev/null; rm -f $BASEDIR/tmp/*.pid" SIGINT SIGTERM

echo "# Launching workloada"
$BASEDIR/bench-workload.sh $WORKLOAD_A_DB_NAME $WORKLOAD_A_DB_URL \
  $WORKLOAD_A_LOAD_THREADS $WORKLOAD_A_LOAD_QPS \
  $WORKLOAD_A_RUN_THREADS $WORKLOAD_A_RUN_QPS \
  $WORKLOAD_A_FLAGS >$BASEDIR/log/workloada.log 2>&1 & echo $! >$BASEDIR/tmp/workloada.pid

echo "# Launching workloadb"
$BASEDIR/bench-workload.sh $WORKLOAD_B_DB_NAME $WORKLOAD_B_DB_URL \
  $WORKLOAD_B_LOAD_THREADS $WORKLOAD_B_LOAD_QPS \
  $WORKLOAD_B_RUN_THREADS $WORKLOAD_B_RUN_QPS \
  $WORKLOAD_B_FLAGS >$BASEDIR/log/workloadb.log 2>&1 & echo $! >$BASEDIR/tmp/workloadb.pid

wait
