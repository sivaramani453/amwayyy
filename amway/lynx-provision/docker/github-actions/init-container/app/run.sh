#!/bin/bash

# git_org and git repo should be passed as env vars
GIT_REGISTER_URL="https://api.github.com/repos/$GIT_ORG/$GIT_REPO/actions/runners/registration-token"

# Get join token for self hosted runner 
payload=$(curl -sX POST -H "Authorization: token $GIT_TOKEN" $GIT_REGISTER_URL)
RUNNER_TOKEN=$(echo $payload | jq .token --raw-output)
if [ $RUNNER_TOKEN  == "null" ]; then
    echo "Could not get git token to attach self hosted runner"
    exit 1
fi

# Fetch task info for parameter name 
CLUSTER=$(curl -Ss $ECS_CONTAINER_METADATA_URI_V4 | jq '.Labels["com.amazonaws.ecs.cluster"]' | tr -d \")
TASK_DEF=$(curl -Ss $ECS_CONTAINER_METADATA_URI_V4 | jq '.Labels["com.amazonaws.ecs.task-definition-family"]' | tr -d \")
TASK_ARN=$(curl -Ss $ECS_CONTAINER_METADATA_URI_V4 | jq '.Labels["com.amazonaws.ecs.task-arn"]' | tr -d \")
# Gen unique name
SSM_PARAM="$CLUSTER-$TASK_DEF-${TASK_ARN##*/}"

# Put join token to ssm parameter store
aws ssm put-parameter --name $SSM_PARAM --type SecureString --value $RUNNER_TOKEN --overwrite

