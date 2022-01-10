#!/usr/bin/env bash
############################################################################################
#
# Author: Martin Hermosilla
# mhermosi@gmail.com
#
# This script assume that kafka is installed under the root folder
# of the project. we set KAFKA_HOME pointing to the base install folder
# of kafka so we can reference the scripts and configuration files.
#
# This script can start/stop/status Kafka and Zookeeper
# also it creates the topics and modify its retention policy
# the script has a bootstrap command that will start zookeeper
# then kafka, and finally create and alter the topics
# topics creation can be verified running the script with the command
# verify which will list the existing topics.
# the zookeeper server and port also the kafka server and port can be
# defined in this script
# this script has been created using functions to provide modularity and
# readability.


KAFKA_HOME="${PWD}/kafka"
export KAFKA_HOME

ZOOKEEPER_START="${KAFKA_HOME}/bin/zookeeper-server-start.sh"
ZOOKEEPER_STOP="${KAFKA_HOME}/bin/zookeeper-server-stop.sh"
ZOOKEEPER_CONFIG="${KAFKA_HOME}/config/zookeeper.properties"
ZOOKEEPER_SERVER="localhost:2181"

KAFKA_START="${KAFKA_HOME}/bin/kafka-server-start.sh"
KAFKA_STOP="${KAFKA_HOME}/bin/kafka-server-stop.sh"
KAFKA_CONFIG="${KAFKA_HOME}/config/server.properties"

KAFKA_TOPIC="${KAFKA_HOME}/bin/kafka-topics.sh"
KAFKA_CONFIGS="${KAFKA_HOME}/bin/kafka-configs.sh"
KAFKA_SERVER="localhost:9092"


status() {
  PROCESS_NAME=$1
  PROCESS_STR=$2
  PIDS=$(ps ax | grep java | grep -i ${PROCESS_STR} | grep -v grep | awk '{print $1}')

  if [ -z "$PIDS" ]; then
    echo "${PROCESS_NAME} not running"
  else
    echo "${PROCESS_NAME} running on PID ${PIDS}"
  fi
}

start_zookeeper() {
  echo "Starting Zookeeper server..."
  stop_zookeeper
  ${ZOOKEEPER_START} -daemon ${ZOOKEEPER_CONFIG}
}

stop_zookeeper() {
  echo "Stopping Zookeeper"
  ${ZOOKEEPER_STOP}
  echo "done"
}


start_kafka() {
  echo "Starting Kafka server..."
  stop_kafka
  $KAFKA_START -daemon $KAFKA_CONFIG
}

stop_kafka() {
  echo "Stopping Kafka"
  ${KAFKA_STOP}
  echo "done"
}

create_schemas() {
  echo "Creating kafka create_schemas"
}

create_topic() {
  TOPIC_NAME=$1
  ${KAFKA_TOPIC} --create \
                  --partitions 1 \
                  --replication-factor 1 \
                  --topic ${TOPIC_NAME} \
                  --bootstrap-server ${KAFKA_SERVER}
}

alter_topic_retention() {
  TOPIC_NAME=$1
  RETENTION=$2
  ${KAFKA_CONFIGS} --alter \
                    --topic ${TOPIC_NAME} \
                    --add-config retention.ms=${RETENTION} \
                    --bootstrap-server ${KAFKA_SERVER}
}


create_topics() {
  create_topic order-received-event
  create_topic order-confirmed-event
  create_topic order-ready-to-ship-event
  create_topic notification-event
  create_topic error-event
  alter_topics
}

alter_topics() {
  # Retention 3 days in ms
  RETENTION=25920000

  alter_topic_retention order-received-event ${RETENTION}
  alter_topic_retention order-confirmed-event ${RETENTION}
  alter_topic_retention order-ready-to-ship-event ${RETENTION}
  alter_topic_retention notification-event ${RETENTION}
  alter_topic_retention error-event ${RETENTION}
}

usage() {
  cat << EOF
  Usage: $0 [start|stop|status|bootstrap|create_topics|alter_topics]

  options:
    start|stop <all|kafka|zookeeper> starts/stop zookeeper and/or kafka.
          if sub-command is ommited all is assumed
    bootstrap: executes "start all", "create_topics" and "alter_topics" with 3 days retention
    create_topics: create the topics
    alter_topics: alter existing topics (with 3 days retention)
    status <all|kafka|zookeeper> show if zookeeper and/or kafka is running.
          if sub-command is ommited all is assumed
EOF
}

process_start() {
  case "$1" in
    "" | all)
      start_zookeeper
      sleep 5
      start_kafka
      ;;
    kafka)
      start_kafka
      ;;
    zookeeper)
      start_zookeeper
      ;;
    *)
      cat << EOF
      Missing argument:

      Usage:
      $0 start <all|kafka|zookeeper>

      or short cut to "start all"

      $0 stop

EOF
      ;;
  esac
}

process_stop() {
  case "$1" in
    "" | all)
      stop_zookeeper
      stop_kafka
      ;;
    kafka)
      stop_kafka
      ;;
    zookeeper)
      stop_zookeeper
      ;;
    *)
      cat << EOF
      Unknown argument:

      Usage:
      $0 stop <all|kafka|zookeeper>

      or short cut to "stop all"

      $0 stop

EOF
      ;;
  esac
}

process_status() {
  case "$1" in
    "" | all)
      status "Zookeeper" "QuorumPeerMain"
      status "Kafka" "kafka\.Kafka"
      ;;
    kafka)
      status "Kafka" "kafka\.Kafka"
      ;;
    zookeeper)
      status "Zookeeper" "QuorumPeerMain"
      ;;
    *)
      cat << EOF
      Unknown argument:

      Usage:
      $0 status <all|kafka|zookeeper>

      or short cut to "status all"

      $0 status

EOF
      ;;
  esac
}

verify() {
  echo "Event topics created:"
  ${KAFKA_TOPIC} --list --bootstrap-server ${KAFKA_SERVER}
}

RETVAL=0

case "$1" in
  "")
    usage
    RETVAL=1
    ;;
  start)
    process_start $2
    ;;
  stop)
    process_stop $2
    ;;
  bootstrap)
    process_start "all"
    sleep 3
    create_topics
    ;;
  create_topics)
    create_topics
    ;;
  alter_topics)
    alter_topics
    ;;
  status)
    process_status $2
    ;;
  verify)
    verify
    ;;
esac

exit $RETVAL