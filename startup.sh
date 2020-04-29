#! /bin/bash

# Copy AppDynamics Agent to shared volume
echo "Copying App Server Agent to volume: ${APPD_DIR}"
unzip -o -q ${AGENT_ZIP} -d ${APPD_DIR}

# Copy AppDynamics configuration script to shared volume
# echo "Copying AppDynamics configuration script to ${APPD_DIR}"
 /bin/cp -f newrelic.yml ${APPD_DIR}/newrelic/newrelic.yml
