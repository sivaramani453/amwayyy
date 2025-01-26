# Automation Cluster Prod

## About

This project helps deploy a complete CICD/automation cluster in `AWS JP Automation PROD`.

## Requirements

The process to create this infra is a manual one, as the automation infra needs to be bootstrapped before we can make use of self-hosted runners and all the other goodies.

- OWNER access to `AWS JP Automation PROD`
- configured AWS credentials on local machine (e.g. with https://github.com/AmwayCommon/clj-get-aws-credentials.git)
- setup the `AWS_PROFILE` env var pointing to the aws profile configured above
- setup `addons.tfvars` as per `addons-example.tfvars`
- setup the s3 backend (see `projects/s3-backend-setup-prod`)
- setup the GHA runner controller docker image and ECR repo (see `projects/gha-runner-container`)
  - use that terraform config to create the ECR repo
  - use the workflow `Prod GHA runner container image build and push` to push the image to ECR
- GNU make, terraform 1.5+
  
Once these steps are done, this cluster can be deployed!

## Deployment

Install the 3 stacks in order, using `make`

    make all

## Deletion

Before deleting, the EKS cluster needs to have termination protection disabled. Either change the `TerminationProtection` tag directly in the AWS console, or change it in `vars.tfvars` then re-deploy the `cluster-infra` stack:

    make STACK=cluster-infra plan apply

Once termination protection is disabled, destroy each stack:

    make STACK=cluster-addons destroy apply
    make STACK=cluster-network destroy apply
    make STACK=cluster-infra destroy apply
    
    
NOTE 2023/12/28: `cluster-addons` will encounter issues deleting the self-hosted runners. In this case, delete every resource in the `actions-runner-system` namespace manually with `kubectl delete`, and force their deletion by patching each resource to remove the finalizers.

Alternatively, BEFORE deleting the `cluster-addons` stack, uninstall the self-hosted runners like this:

    helm uninstall -n actions-runner-system jpn-automation
    helm uninstall -n actions-runner-system actions-runner-controller
  
There may be more resources left behind preventing the deletion of the `actions-runner-system` namespace. In this case they should be individually deleted. SEe https://amwaycloud.atlassian.net/wiki/spaces/AITB/pages/137989065/Pat+s+Unorganized+Knowledge+and+Facts#Kubernetes/EKS 
