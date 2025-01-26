# JP - AWS - Infrastructure as Code Repository

## About

Polylith-style repository for Japan AWS IaC.

## Documentation

[Read the docs](docs/index.md)!

## Requirements

 - terraform v1.4.6+
 - AWS `OWNER` or `CONTRIB` access to `AWS JP Automation` account(s)
 - IAM role in target AWS account that can be assumed by `OWNER` or `CONTRIB` (if running locally) or by: `arn:aws:iam::492449516969:role/jp-cicd-automation-infra` (if running from GitHub)

## Quick start - automation cluster (dev)

    cd projects/automation-cluster-dev
    make STACK=cluster-infra init # initialize terraform modules
    make STACK=cluster-infra plan # plan the deployment, compare with existing resources
    make STACK=cluster-infra apply # apply the deployment plan
