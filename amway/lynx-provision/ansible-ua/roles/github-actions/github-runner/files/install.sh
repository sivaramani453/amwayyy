#!/bin/sh

INSTANCE_ID=$(curl -Ss http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -Ss http://169.254.169.254/latest/meta-data/instance-type)
INSTANCE_IP_ADDR=$(curl -Ss http://169.254.169.254/latest/meta-data/local-ipv4)

SSM_PARAM_TOKEN="actions-token-$INSTANCE_ID"
SSM_PARAM_REPO="actions-repo-$INSTANCE_ID"

# Fetch git data
RUNNER_TOKEN=$(aws ssm get-parameter --name $SSM_PARAM_TOKEN --with-decryption --query 'Parameter.Value' --output text)
RUNNER_REPO=$(aws ssm get-parameter --name $SSM_PARAM_REPO --with-decryption --query 'Parameter.Value' --output text)

# Register agent
./config.sh --labels $INSTANCE_TYPE,$INSTANCE_IP_ADDR --name $INSTANCE_ID --token $RUNNER_TOKEN --url "https://github.com/$RUNNER_REPO" --work _work --unattended --replace

# run self hosted runner
./bin/runsvc.sh
