#!/bin/sh

export AWS_DEFAULT_REGION="eu-central-1"
INSTANCE_ID=$(curl -Ss http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -Ss http://169.254.169.254/latest/meta-data/instance-type)
INSTANCE_IP_ADDR=$(curl -Ss http://169.254.169.254/latest/meta-data/local-ipv4)

SSM_PARAM_TOKEN="actions-token-$INSTANCE_ID"
SSM_PARAM_REPO="actions-repo-$INSTANCE_ID"

# Fetch git data
n=0
until [ "$n" -ge 42 ]
do
    RUNNER_TOKEN=$(aws ssm get-parameter --name $SSM_PARAM_TOKEN --with-decryption --query 'Parameter.Value' --output text) 2>&1 >/dev/null
    if [ "$?" -ne 0 ]; then
        echo "Unsuccessfull attempt to obtain token, retrying..."
        n=$((n+1))
        sleep 10
    else
        echo "$RUNNER_TOKEN" > token
        break
    fi
done
RUNNER_TOKEN=$(cat ./token)
rm -f ./token

until [ "$n" -ge 42 ]
do
    RUNNER_REPO=$(aws ssm get-parameter --name $SSM_PARAM_REPO --with-decryption --query 'Parameter.Value' --output text) 2>&1 >/dev/null
    if [ "$?" -ne 0 ]; then
        echo "Unsuccessfull attempt to obtain repo, retrying..."
        n=$((n+1))
        sleep 10
    else
        echo "$RUNNER_REPO" > repo
        break
    fi
done
RUNNER_REPO=$(cat ./repo)
rm -f ./repo

# Register agent
./config.sh --labels $INSTANCE_TYPE,$INSTANCE_IP_ADDR --name $INSTANCE_ID --token $RUNNER_TOKEN --url "https://github.com/$RUNNER_REPO" --work _work --unattended --replace

# run self hosted runner
./bin/runsvc.sh
