#!/bin/bash
set -ex
PATH_TO_CONFIG=/home/bamboo/bamboo-agent-home/bamboo-agent.cfg.xml
TMP=/home/bamboo/bamboo-agent-home/tmp_
echo """
import docker,socket
name = docker.from_env().containers.get(socket.gethostname()).attrs['Name']
number = name.split('_')[-1]
print(number)
""" > get_number.py
NUMBER_NAME=$(sudo python3 get_number.py)
PREFIX=/docker_agents/$HOST_HOSTNAME
PARAMETER_NAME=${PREFIX}_docker_agent_${NUMBER_NAME}
IDS=$(aws --region eu-central-1 ssm get-parameter --name ${PARAMETER_NAME} --query "Parameter.[Value]" 2>/dev/null --output text)
AGENT_ID=${IDS%%,*}
AGENT_UID=${IDS##*,}

sed "/<id>/c <id>$AGENT_ID</id>" $PATH_TO_CONFIG | sed "/<agentUuid>/c <agentUuid>$AGENT_UID</agentUuid>" > $TMP

mv -f $TMP $PATH_TO_CONFIG
chown bamboo:bamboo $PATH_TO_CONFIG

bash $SCRIPT_WRAPPER $@
