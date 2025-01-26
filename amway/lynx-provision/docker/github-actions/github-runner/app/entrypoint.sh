#!/bin/sh

# Fetch task info for parameter name
CLUSTER=$(curl -Ss $ECS_CONTAINER_METADATA_URI_V4 | jq '.Labels["com.amazonaws.ecs.cluster"]' | tr -d \")
TASK_DEF=$(curl -Ss $ECS_CONTAINER_METADATA_URI_V4 | jq '.Labels["com.amazonaws.ecs.task-definition-family"]' | tr -d \")
TASK_ARN=$(curl -Ss $ECS_CONTAINER_METADATA_URI_V4 | jq '.Labels["com.amazonaws.ecs.task-arn"]' | tr -d \")

# Gen unique name
SSM_PARAM="$CLUSTER-$TASK_DEF-${TASK_ARN##*/}"

# Fetch join token from parametr store
RUNNER_TOKEN=$(aws ssm get-parameter --name $SSM_PARAM --with-decryption --query 'Parameter.Value' --output text)
echo $RUNNER_TOKEN

# config runner with labels if provided
if [ -n $LABELS ]; then
    ./config.sh --labels $LABELS --name $(hostname) --token ${RUNNER_TOKEN} --url https://github.com/$GIT_ORG/$GIT_REPO --work _work --unattended --replace
else
    ./config.sh --name $(hostname) --token ${RUNNER_TOKEN} --url https://github.com/$GIT_ORG/$GIT_REPO --work _work --unattended --replace
fi

# func to remove runner from github on stop
remove() {
    ./config.sh remove --unattended --token "${RUNNER_TOKEN}"
}

# lister for signals
trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

# run self hosted runner
./bin/runsvc.sh "$*" &

# wait to reap process
wait $!
