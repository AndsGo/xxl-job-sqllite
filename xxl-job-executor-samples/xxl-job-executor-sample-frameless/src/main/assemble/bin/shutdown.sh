#!/bin/sh

#check JAVA_HOME & java
if [ -z "$JAVA_HOME" ] ; then
    JAVA_HOME=/opt/jdk
fi


#==============================================================================
#set JAVA_OPTS
JAVA_OPTS="-Xss256k"
#==============================================================================

#stop Server
#$(ps -ef | grep oms-motan | awk '{print $2}' | xargs kill -9 )

#stop Server
#Loop check the process id and kill it more times
flag=1
while [ $flag -gt 0 ]
do
`ps -ef | grep FramelessApplication | grep -v grep | awk '{print $2}' | xargs kill -9`
sleep 1
flag=`ps -ef | grep FramelessApplication | grep -v grep | wc -l`
done

echo "Shutdown oms-taskscheduler is done....."
#==============================================================================