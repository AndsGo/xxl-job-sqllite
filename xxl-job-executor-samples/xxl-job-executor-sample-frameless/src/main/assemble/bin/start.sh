#!/bin/sh

#check JAVA_HOME & java
if [ -z "$JAVA_HOME" ] ; then
    JAVA_HOME=/opt/jdk
fi

#COMPRESS_FOLDER="/usr/shells/"
#if [ ! -d "$COMPRESS_FOLDER" ]; then
#  mkdir $COMPRESS_FOLDER
#fi

#/usr/shells/compress.sh
#COMPRESS_SHELL_FILE=$COMPRESS_FOLDER"compress.sh"
#cp ./compress.sh $COMPRESS_FOLDER
#chmod +x $COMPRESS_SHELL_FILE

#set LOCAL_IP
#LOCAL_IP=`ifconfig | grep 'inet addr' | grep -v '127.0.0.1' | head -1 | sed 's/^.*addr://g' |sed 's/  Bcast:.*$//g'`

BASE_HOME=/opt/xxljob/etl-job

#==============================================================================
#set JAVA_OPTS
JAVA_OPTS="-server -Xms128m -Xmx512m -Xmn128m -Xss1024k"

#performance Options
JAVA_OPTS="$JAVA_OPTS -XX:+AggressiveOpts"
JAVA_OPTS="$JAVA_OPTS -XX:+UseBiasedLocking"
JAVA_OPTS="$JAVA_OPTS -XX:+UseFastAccessorMethods"
JAVA_OPTS="$JAVA_OPTS -XX:+DisableExplicitGC"
JAVA_OPTS="$JAVA_OPTS -XX:+UseParNewGC"
JAVA_OPTS="$JAVA_OPTS -XX:+UseConcMarkSweepGC"
JAVA_OPTS="$JAVA_OPTS -XX:+CMSParallelRemarkEnabled"
JAVA_OPTS="$JAVA_OPTS -XX:+UseCMSCompactAtFullCollection"
JAVA_OPTS="$JAVA_OPTS -XX:+UseCMSInitiatingOccupancyOnly"
JAVA_OPTS="$JAVA_OPTS -XX:CMSInitiatingOccupancyFraction=75"

#GC Log Options
#JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCApplicationStoppedTime"
#JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCTimeStamps"
#JAVA_OPTS="$JAVA_OPTS -XX:+PrintGCDetails"

#debug Options
#JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=8065,server=y,suspend=n"

#if [ -n "$APPNAME" ] ; then
#    sed -i "s/APPNAME/$APPNAME/g" /plugin/sky-agent/agent/config/agent.config
#    sed -i "s/BACKEND_SERVER/$BACKEND_SERVER/g" /plugin/sky-agent/agent/config/agent.config
#    JAVA_OPTS="$JAVA_OPTS -javaagent:/plugin/sky-agent/agent/skywalking-agent.jar -Dskywalking.agent.service_name=$APPNAME -Dskywalking.collector.backend_service=$BACKEND_SERVER"
#fi
#==============================================================================

TEMP_CLASSPATH="$BASE_HOME/conf"
for i in "$BASE_HOME"/lib/*.jar
do
    TEMP_CLASSPATH="$TEMP_CLASSPATH:$i"
done

#==============================================================================
#startup server
RUN_CMD="$JAVA_HOME/bin/java"
RUN_CMD="$RUN_CMD -classpath $TEMP_CLASSPATH"
RUN_CMD="$RUN_CMD $JAVA_OPTS"
RUN_CMD="$RUN_CMD -DserviceIp=$LOCAL_IP"
RUN_CMD="$RUN_CMD com.xuxueli.executor.sample.frameless.FramelessApplication >>/dev/null 2>&1 &"

echo $RUN_CMD

eval $RUN_CMD

echo "recommend-statistics start !"
#==============================================================================