#!/bin/bash

helm repo add splunk https://splunk.github.io/splunk-connect-for-kubernetes/
helm show values splunk/splunk-connect-for-kubernetes > values.yaml
echo "Please prepare values.yaml file as my_values.yaml and rerun script"
if [ -f my_values.yaml ]; then
echo helm install splunk-connect -f my_values.yaml -n kube-system splunk/splunk-connect-for-kubernetes
fi

