FROM openjdk:8-jre-slim AS builder

# Install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y unzip && \
    apt-get clean

# Actual file paths passed via docker-compose.yml
ARG MACHINE_AGENT_ZIP
ARG MACHINE_AGENT_SHA256

# Canonical filenames used in startup script
ENV MA_ZIP MachineAgentBundle.zip
ENV MA_SHA256 MachineAgentBundle.checksum

COPY ${MACHINE_AGENT_ZIP} /${MA_ZIP}
RUN echo "${MACHINE_AGENT_SHA256} *${MA_ZIP}" >> /${MA_SHA256}

#COPIED OUT
RUN sha256sum -c ${MA_SHA256}

# Install AppDynamics Machine Agent
ENV MACHINE_AGENT_HOME /opt/appdynamics/machine-agent/
RUN mkdir -p ${MACHINE_AGENT_HOME} && \
    unzip -oq /${MA_ZIP} -d ${MACHINE_AGENT_HOME} && \
    rm /${MA_ZIP}

# Include start script to configure and start MA at runtime
ADD start-appdynamics ${MACHINE_AGENT_HOME}
RUN chmod 744 ${MACHINE_AGENT_HOME}/start-appdynamics

# Configure and Run AppDynamics Machine Agent
CMD "${MACHINE_AGENT_HOME}/start-appdynamics"

# Analytics Agent listener
EXPOSE 9090
