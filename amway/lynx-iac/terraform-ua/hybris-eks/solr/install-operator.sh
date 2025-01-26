#!/bin/bash

helm repo add apache-solr https://solr.apache.org/charts

kubectl create -f https://solr.apache.org/operator/downloads/crds/v0.4.0/all-with-dependencies.yaml
helm install solr-operator apache-solr/solr-operator --version 0.4.0

