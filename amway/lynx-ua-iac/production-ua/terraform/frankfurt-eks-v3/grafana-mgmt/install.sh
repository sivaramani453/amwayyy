#!/bin/bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install mgmt-grafana grafana/grafana -f values.yml

