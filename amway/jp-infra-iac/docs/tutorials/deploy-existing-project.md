# Tutorial: Deploy An Existing Project

## About

In this tutorial, we will consider an existing project, and 2 cases: (1) deployment from GitHub Actions (the preferred method to deploy IaC) and (2) deployment from local machine (useful when developing/testing)

## Project

In this tutorial, we will deploy a sandbox microservices cluster: `demo-cluster`, from the folder: `projects/demo`

# Method 1: Deploy With GitHub Actions (Recommended)

## Requirements

 - Access to this repository in GitHub
 - `CONTRIB` or `OWNER` access to the `AWS JP Shared PREPROD` AWS account for validation
 - The GitHub Actions Runners must be available, for running the workflow on-premises

## Check the workflow

The workflow is located in this GitHub repository at: https://github.com/AmwayCommon/jp-infra-iac/actions/workflows/demo.yml

## Trigger the workflow

On the right side of the page, click on the drop down `Run workflow`, and select the branch `develop`; then run the workflow.

## Validate

Logon to `AWS JP Automation PREPROD` and validate the cluster is present.

## Destroy

Navigate to: https://github.com/AmwayCommon/jp-infra-iac/actions/workflows/demo-destroy.yml

And similar to the deployment, click on `Run workflow`, select the branch `develop` then click the `Run workflow` button.


# Method 2: Deploy From Local Machine (Development)

## Requirements

 - GNU make or BSD make
 - GNU awk or BSD awk
 - terraform 1.5.x or higher

## Get AWS Credentials (Automation account)

The first step to deploy this cluster is to ensure AWS CLI access to the `JP Automation PREPROD` AWS account. This access needs to be `OWNER` or `CONTRIB` level, in order to allow: (1) write access to the state s3 bucket and dynamodb, as well as access to assume the other deployment role, OIDC creator role.

Once the credentials have been acquired, make sure to set it as the default profile in your shell, e.g.:

    export AWS_PROFILE=jpautomationpreprod


## Configure Secrets

NOTE: in the demo cluster, there are no secrets to configure.

## Check the `make` Help

Running `make help` will show you some helpful messages:

```
❯ make help

Usage:
  make STACK=stack-name
  help             Display this help

Terraform. All actions except `init` require a vars.tfvars file
  init             Initialize the modules, provider, etc for ${STACK}
  refresh          Refresh the modules, useful when they're stored in git for ${STACK}
  plan             Make a terraform plan and save to .terraform.plan for ${STACK}
  apply            Apply .terraform.plan for ${STACK}
  destroy          Make a plan to destroy everything for ${STACK}

Build all stacks
  all              Successively init, plan and apply all stacks
```

While the last option, `all`, is useful, let's proceed one stack at a time.


## Infra Stack

### Initialize the Stack

Run:

    make STACK=cluster-infra init

(output not shown)

This will download the required terraform providers and set up the modules for this stack.

### Terraform Plan

Run:
    make STACK=cluster-infra plan

(output not shown)

This will check the current infra status (there should be no resources deployed) and show what will be applied. The plan will be saved to a file claled `.terraform.plan`.

### Terraform Apply

Finally, run the following and get yourself a coffee or tea:

    make STACK=cluster-infra apply

(output not shown)

This will apply the plan and build the infrastructure.

## Network Stack

### Initialize, plan and apply

Not surprisingly, the steps are the same as above. Since we are using a Makefile, it's possible to run all the steps at once:

    make STACK=cluster-network init plan apply

(output not shown)

## Addons Stack

### Initialize, plan and apply

Same here:

    make STACK=cluster-addons init plan apply

(output not shown)

## Validate

Now you have a full cluster created in the `AWS JP Automation PREPROD` AWS account. Logon to the account and validate the cluster

## Destroy

Now you can destroy all resources:

```
make STACK=cluster-addons destroy apply
make STACK=cluster-network destroy apply
make STACK=cluster-infra destroy apply
```
