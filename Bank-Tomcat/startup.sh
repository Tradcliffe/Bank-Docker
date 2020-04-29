#!/bin/bash

# Uncomment and expose port 8888 to enable JMX remote monitoring
#export JMX_OPTS="-Dcom.sun.management.jmxremote.port=8888  -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

# Specialize container behavior based on ROLE env var
# Uses https://github.com/jwilder/dockerize to check service dependencies
# Binaries and Gradle scripts are sourced from ${PROJECT} docker shared volume
case ${ROLE} in
rest)
  dockerize -wait tcp://bankdb:3306 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  #change this to location of gradle installation on shared volume
  #has to run before the other containers can start
  cd ${PROJECT}/AD-Capital; gradle createDB

  cp ${PROJECT}/AD-Capital/Rest/build/libs/Rest.war ${CATALINA_HOME}/webapps;
  cd ${CATALINA_HOME}/bin;
  java -javaagent:/monitoring/newrelic/newrelic.jar ${JMX_OPTS} -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar org.apache.catalina.startup.Bootstrap
  ;;
portal)
  dockerize -wait tcp://rabbitmq:5672 \
            -wait tcp://rest:8080 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  cp /${PROJECT}/AD-Capital/Portal/build/libs/portal.war ${CATALINA_HOME}/webapps;
  cd ${CATALINA_HOME}/bin;
  java -javaagent:/monitoring/newrelic/newrelic.jar ${JMX_OPTS} -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar org.apache.catalina.startup.Bootstrap
  ;;
processor)
  dockerize -wait tcp://bankdb:3306 \
            -wait tcp://rabbitmq:5672 \
            -wait tcp://rest:8080 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  cp /${PROJECT}/AD-Capital/Processor/build/libs/processor.war ${CATALINA_HOME}/webapps;
  cd ${CATALINA_HOME}/bin;
  java -javaagent:/monitoring/newrelic/newrelic.jar ${JMX_OPTS} -cp ${CATALINA_HOME}/bin/bootstrap.jar:${CATALINA_HOME}/bin/tomcat-juli.jar org.apache.catalina.startup.Bootstrap
  ;;
approval)
  dockerize -wait tcp://rabbitmq:5672 \
            -wait tcp://rest:8080 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  cd ${CATALINA_HOME}/bin;
  java -javaagent:/monitoring/newrelic/newrelic.jar  ${JMX_OPTS} -jar ${PROJECT}/AD-Capital/QueueReader/build/libs/QueueReader.jar
  ;;
verification)
  dockerize -wait tcp://bankdb:3306 \
            -wait tcp://rabbitmq:5672 \
            -wait tcp://rest:8080 \
            -wait-retry-interval ${RETRY} -timeout ${TIMEOUT} || exit $?

  cd ${CATALINA_HOME}/bin;
  java -javaagent:/monitoring/newrelic/newrelic.jar  ${JMX_OPTS} -jar ${PROJECT}/AD-Capital/Verification/build/libs/Verification.jar
  ;;
*)
  echo "ROLE missing: container will exit"; exit 1
  ;;
esac
