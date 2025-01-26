# IAM Roles and Setup

In order for these projects to work, we have come up with  a standardized way of setting up IAM roles. This allows sharing a single source of truth for Terraform states (stored in the JP Automation AWS accounts); it allows a single "ingress" point from GitHub ACtions into our AWS infrastructure; and it allows jumping off this point into assuming roles granting more access or access to different AWS accounts.

This document will explain how this works.

## High-Level

At a high-level, we want:

 - OIDC connection between GitHub Actions and the AWS Account(s) (this means no IAM keys are used)
 - One centralized entry point into our AWS infrastructure, rather than one OIDC connection per AWS account
 - One centralized location for all AWS accounts' and projects' Terraform s tate
 - One main IAM role to use for accessing Terraform state
 - And finally, one IAM role per project, so that specific permissions to deploy can be granted on a per-project basis

 To do this we leverage OIDC and cross-account "AssumeRole" relationships.

 ### GitHub OIDC

 The GitHub OIDC is configured in the `AWS JP Automation` accounts, and has one IAM role allowing this connection from any repository in the `AmwayCommon` organization (we might whitelist them in the future?).

 This IAM role has permissions to access the Terraform State file in S3 and state locking in DynamoDB.

 Moreover, this IAM role has a permission allowing to to `AssumeRole` to any role in the `JP Shared` or `Automation` accounts.

 Effectively, this provides one entry point from GitHub Actions, which allows `terraform` tasks to access and store state. Being able to assume other roles allows our Terraform configs to define these roles in the `provider.tf` files of each project and stack.

## Terminology

Let's define a few terms:

 - `automation account`: This account houses the Auotmation EKS cluster (which runs, among other things, self-hosted GitHub Actions Runners); it's the main entrypoint for pipelines/terraform configs, usually via the automation IAM role
 - `automation IAM role`: this IAM role has permissions to access the Terraform State, and to assume other IAM roles, and little else; it is used as a jumping board from GitHub actions into other AWS accounts
 - `target account`: these are AWS accounts where the new/updated infrastructure is desired; it is a `target` because it's the account where we want to actually apply changes, separate from the account where Terraform state is stored


## GitHub Actions and AWS Account Connection

Straightforward one. We use the GitHub OIDC to connect to our AWS account.

https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services

## Automation IAM role


This IAM role should be assumed from GitHub, using the `aws-actions/configure-aws-credentials` action:

In POC phase:
    arn:aws:iam::492449516969:role/jp-cicd-automation-infra

For PreProd and Prod actions:
    Coming soon!

This IAM role has permissions to access the Terraform state, and to assume roles in the AWS JP Shared accounts, and in the AWS JP Automation accounts.

## Trust Relationship

Now, in the `target account`, we need to create one IAM role for every project. This IAM role:

 - has the exact permissions required to create/modify/delete the resources
 - has a trust relationship allowing the `Automation IAM role` above to `AssumeRole`
 - *does not need* access to the Terraform State

## Target IAM Roles

Finally, the target IAM role will have, as explained just above, the required permissions to deploy the resources required by the project.

There will be *one* `target IAM role` for every deployment project.
