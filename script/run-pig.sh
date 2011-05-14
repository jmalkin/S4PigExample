#!/bin/bash

PROJECT_JAR=speech01-0.3-SNAPSHOT.jar

PROJECT_HOME=`pwd`/..
S4JARDIR=${PROJECT_HOME}/lib
APPDIR=${PROJECT_HOME}/applib

HDFS_HOME=/user/`whoami`
DATAPATH=$HDFS_HOME/S4PigExample

LOCAL_MODE=1
if [ "x$LOCAL_MODE" != "x" ]; then
    LOCAL_CMD="-x local"
    DATAPATH=${PROJECT_HOME}
fi

if [ "x$HADOOP_QUEUE" == "x" ]; then
    HADOOP_QUEUE=default
fi

CLASSPATH="${S4JARDIR}/s4-core-0.3-SNAPSHOT.jar:${S4JARDIR}/spring-2.5.6.jar:${S4JARDIR}/kryo-1.01.jar:${S4JARDIR}/bcel-5.2.jar:${S4JARDIR}/minlog-1.2.jar:${APPDIR}/${PROJECT_JAR}";

#HADOOP_OPTS="-Dpig.usenewlogicalplan=false -t PruneColumns -Dmapred.child.ulimit=4194304 -Dmapred.job.map.memory.mb=1024 -Dmapred.job.reduce.memory.mb=1024 -Dmapred.job.queue.name=$HADOOP_QUEUE"
HADOOP_OPTS="-Dpig.usenewlogicalplan=false -t PruneColumns -Dmapred.job.map.memory.mb=1250 -Dmapred.job.reduce.memory.mb=1250 -Dmapred.job.queue.name=$HADOOP_QUEUE"

PIG_CMD="pig -useversion current $LOCAL_CMD -cp $CLASSPATH $HADOOP_OPTS -param APPPATH=$APPDIR -param S4JARPATH=$S4JARDIR -param DATAPATH=$DATAPATH $1"

echo $PIG_CMD
$PIG_CMD > ${1}.log 2>&1 &
