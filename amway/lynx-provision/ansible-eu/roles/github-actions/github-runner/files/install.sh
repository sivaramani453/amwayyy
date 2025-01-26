#!/bin/sh

#I experienced problems with AWSCLI written in python3 but using python2 as an interpreter
#If you know how to solve it cleanr, please do!
export PYTHON=$(which python3)
export AWS=$(which aws)

NOTIMEOUT_LABEL='notimeout'

INSTANCE_ID=$(curl -Ss http://169.254.169.254/latest/meta-data/instance-id)
#INSTANCE_TYPE=$(curl -Ss http://169.254.169.254/latest/meta-data/instance-type)
#We declare what we get from SSM
#Cos' we might provide higher option than requested due to insufficient capacity
INSTANCE_IP_ADDR=$(curl -Ss http://169.254.169.254/latest/meta-data/local-ipv4)

SSM_PARAM_TOKEN="actions-token-$INSTANCE_ID"
SSM_PARAM_REPO="actions-repo-$INSTANCE_ID"
SSM_PARAM_TYPE="actions-type-$INSTANCE_ID"

# Fetch git data
n=0
until [ "$n" -ge 12 ]
do
    RUNNER_TOKEN=$($PYTHON $AWS ssm get-parameter --name $SSM_PARAM_TOKEN --with-decryption --query 'Parameter.Value' --output text --region eu-central-1) 2>&1 >/dev/null
    if [ "$?" -ne 0 ]; then
        echo "Unsuccessfull attempt to obtain token, retrying..."
        n=$((n+1))
        sleep 10
    else
        echo "$RUNNER_TOKEN" > ./token
        break
    fi
done
RUNNER_TOKEN=$(cat ./token)

until [ "$n" -ge 12 ]
do
    RUNNER_REPO=$($PYTHON $AWS ssm get-parameter --name $SSM_PARAM_REPO --with-decryption --query 'Parameter.Value' --output text --region eu-central-1) 2>&1 >/dev/null
    if [ "$?" -ne 0 ]; then
        echo "Unsuccessfull attempt to obtain repo, retrying..."
        n=$((n+1))
        sleep 10
    else
        echo "$RUNNER_REPO" > ./repo
        break
    fi
done
RUNNER_REPO=$(cat ./repo)

until [ "$n" -ge 12 ]
do
    RUNNER_LABELS=$($PYTHON $AWS ssm get-parameter --name $SSM_PARAM_TYPE --with-decryption --query 'Parameter.Value' --output text --region eu-central-1) 2>&1 >/dev/null
    if [ "$?" -ne 0 ]; then
        echo "Unsuccessfull attempt to obtain type, retrying..."
        n=$((n+1))
        sleep 10
    else
        echo "$RUNNER_LABELS" > ./labels
        break
    fi
done
RUNNER_LABELS=$(cat ./labels)

# Register agent
./config.sh --labels $RUNNER_LABELS,$INSTANCE_IP_ADDR --name $INSTANCE_ID --token $RUNNER_TOKEN --url "https://github.com/$RUNNER_REPO" --work _work --unattended --replace --ephemeral

case $RUNNER_LABELS in
  *"$NOTIMEOUT_LABEL"*)
      ./bin/runsvc.sh
      ;;
  *)
      # run self hosted runner for no longer than 4h
      timeout 4h ./bin/runsvc.sh
      ;;
esac

#When all this stuff is over - simply kill this machine
#We place here 3mins grace period, if you need to debug just stop this service during grace period
sleep 180
sudo shutdown -h now