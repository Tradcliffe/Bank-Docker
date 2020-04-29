FROM centos:centos6
#FROM store/appdynamics/java:4.3.7.1_tomcat9-jre8

RUN yum -y install unzip

ARG APPD_AGENT_ZIP
ENV AGENT_ZIP AppServerAgent.zip
ENV APPD_TMP /tmp

COPY ${APPD_AGENT_ZIP} /${AGENT_ZIP}

COPY newrelic.yml /newrelic.yml

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD "/startup.sh"
