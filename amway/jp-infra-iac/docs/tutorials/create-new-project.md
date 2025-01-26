# Tutorial: Create A New Project

## About

In this tutorial, we will create a new project that deploys a barebones EKS cluster with a few services (ingress for example).

This is the `demo` cluster that will be used in the [deploy-existing-project.md](deploy-existing-project.md) tutorial.

# Create project from the `template`

## Copy template files

First, create a new folder under `projects/`; let's call this one `demo/`:

```
mkdir projects/demo
```

Next, copy the template into this new folder:

```
cp -R templates/eks-template/* projects/demo/
```

You will now have the full template:

```
$ pwd
.../jp-infra-iac/projects/demo
$ tree
.
|-- Makefile
|-- secrets_example.tfvars
|-- stacks
|   |-- cluster-addons
|   |   |-- Makefile
|   |   |-- main.tf
|   |   |-- provider.tf
|   |   `-- variables.tf
|   |-- cluster-infra
|   |   |-- Makefile
|   |   |-- main.tf
|   |   |-- provider.tf
|   |   `-- variables.tf
|   `-- cluster-network
|       |-- Makefile
|       |-- main.tf
|       |-- provider.tf
|       `-- variables.tf
`-- vars.tfvars
```

## Customize the providers, s3 backend, variables

Now the real work begins. For each stack, let's configure the providers (aws, helm, kubernetes).

First thing to notice is that each stack already have the s3 backend mostly configured, and we just need to customize the s3 prefix. Let's do that in each of the stacks' `provider.tf` file. e.g., in `stacks/cluster-infra/provider.tf`, we would end up with this:

```
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
  backend "s3" {
    bucket         = "jpn-automation-dev-tfstate" #### THIS IS THE LINE WE CUSTOMIZED ###
    key            = "demo-infra"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"
  }
}
```

### cluster-infra providers:
Next up, we add the provider configs for the `cluster-infra` stack. The entire file now looks like this:

```
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
  backend "s3" {
    bucket         = "jpn-automation-dev-tfstate"
    key            = "demo-infra"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"
  }
}

### NEW CUSTOMIZATIONS START HERE ###

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy"
    session_name = "cicd"
    external_id  = "cicd"
  }

  default_tags {
    tags = var.default_tags
  }
}

provider "aws" {
  alias  = "oidc_creator"
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::492449516969:role/oidc-creator-role"
    session_name = "oidc-creator"
    external_id  = "oidc-creator"
  }


  default_tags {
    tags = var.default_tags
  }
}

```

First, we configure the main AWS provider, which will deploy a cluster in the `ap-northeast-1` region of the `AWS JP AUTOMATION PREPROD` account.

We also configure a *second* AWS provider, this one enables the creation of an OIDC provider which will be used for EKS resources to interface with IAM.

Finally, `default_tags` are applied to any resource created in AWS using this config (very useful!) Due to the reptitive nature and many places those default tags have to be applied (including, as we'll see later, tags that have to be explicitly added to a launch template, where our default_tags don't automatically apply), we are using a variable for this. We will configure this variable in a later step.

### cluster-network providers

Next, we configure the `cluster-infra` stack's `provider.tf`:

```
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
  backend "s3" {
    bucket         = "jpn-automation-dev-tfstate"
    key            = "demo-network"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy"
    session_name = "cicd"
    external_id  = "cicd"
  }

  default_tags {
    tags = var.default_tags
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy"
    session_name = "cicd"
    external_id  = "cicd"
  }

  default_tags {
    tags = var.default_tags
  }
}

data "aws_eks_cluster" "demo_cluster" {
  name = var.eks_cluster_config.name
}

data "aws_eks_cluster_auth" "demo_cluster" {
  name = var.eks_cluster_config.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.demo_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.demo_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.demo_cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.demo_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.demo_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.demo_cluster.token
  }
}

```

A few things of importance here:

 - once again we have 2 AWS providers; while both use the same IAM role, one of them uses the `us-east-1` region, useful for ACM certificates
 - the `us-east-1` provider has an alias, which will help us refer to it in our terraform code
 - we need to configure helm and kubernetes based on the EKS cluster config; to avoid hard-coding certificates, urls, etc, we obtain this config using a data provider.

### cluster-addons provider

Finally, we configure our `cluster-addons` stack `provider.tf`:

```
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
  backend "s3" {
    bucket         = "jpn-automation-dev-tfstate"
    key            = "demo-addons"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn     = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy"
    session_name = "cicd"
    external_id  = "cicd"
  }

  default_tags {
    tags = var.default_tags
  }
}

data "aws_eks_cluster" "demo_cluster" {
  name = var.eks_cluster_config.name
}

data "aws_eks_cluster_auth" "demo_cluster" {
  name = var.eks_cluster_config.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.demo_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.demo_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.demo_cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.demo_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.demo_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.demo_cluster.token
  }
}

```

At this point, there should be nothing surprising here. We only need one AWS provider, otherwise the same comments as the previous two stacks apply.

## Set main project variables

Let's add this under `demo/vars.tfvars` to configure our cluster, including the `default_tags` mentioned earlier:

```
default_tags = {
  ApplicationID = "APP3001178",
  Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
  Project       = "CICD",
  Country       = "Japan",
  Environment   = "DEV"
}

eks_cluster_config = {
  name    = "demo"
  version = "1.27"
  vpc_id  = "vpc-0d1aa036eb0120566" #### Premade VPC in the AUTOMATION PREPROD account
  subnet_ids = [
    "subnet-06b6f68878d1c52aa",
    "subnet-0ea3a984379b2eedf"
  ]
  security_group_ids      = []
  policy_arns             = []
  automation_account_root = "arn:aws:iam::492449516969:root"
  eks_auth_roles = [{
    rolearn  = "arn:aws:iam::492449516969:role/AWS-CDA-492449516969-OWNER" ## Allow the OWNER role to access EKS
    username = "admin"
    groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::492449516969:role/jpn-automation-dev-deploy" ## Allow the deploy IAM role to access EKS
      username = "admin"
      groups   = ["system:masters"]
    }
  ]
}

## Here we define the node group with a single SPOT instsance
node_groups = {
  spot = {
    use_name_prefix                 = true
    launch_template_use_name_prefix = true
    description                     = "SPOT instances"
    name                            = "demo-spot"
    iam_role_name                   = "demo-spot-"
    instance_types                  = ["t3.large", "t2.large"]
    capacity_type                   = "SPOT"
    subnet_ids = [
        "subnet-06b6f68878d1c52aa",
        "subnet-0ea3a984379b2eedf"
    ]
    min_size     = 1
    max_size     = 4
    desired_size = 2

    launch_template_tags = {
      ApplicationID = "APP3001178",
      Contact       = "AJ.USR.DEVOPS-SUPPORT-JP@amway.com",
      Project       = "CICD",
      Country       = "Japan",
      Environment   = "DEV"
    }
  }
}

## We will run this cluster under the domain below
domain_info = {
  domain_name               = "demo.automation.preprod.jp.amway.net"
  subject_alternative_names = ["*.demo.automation.preprod.jp.amway.net"]
  route53_zone              = "automation.preprod.jp.amway.net"
  txtOwnerId                = "Z0535437329PM8KXXW6KB"
}

```

In this case, we won't be needing any secrets, but we still need an empty `demo/secrets.tfvars` file. Create it.

## Customize each stack

### Select bases for cluster-infra

First, let's create a simple, generic, EKS cluster. Add this to `stacks/cluster-infra/main.tf`:

```
module "demo_cluster" {
  source = "../../../../bases/generic-eks-cluster"

  eks_cluster_config = var.eks_cluster_config
  node_groups        = var.node_groups
  default_tags       = var.default_tags
  eks_extra_tags = {
    TerminationProtection = "false"
  }
  providers = {
    aws              = aws
    aws.oidc_creator = aws.oidc_creator
  }
}

output "common_infra_support_arn" {
  value = module.demo_cluster.common_infra_support_arn
}
```

Here, we use just one base: a generic EKS cluster, which creates the necessary security groups, IAM roles, OIDC provider, and EC2 node group as defined previously in our `vars.tfvars` file. Additionally, there's an output for an ARN, that will be used in later stacks.


Populate the `stacks/cluster-infra/variables.tf`:

```
variable "default_tags" {
  type = map(string)
}

variable "node_groups" {
  description = "Map of definition for each node group. See variables.tf for examples."
  type        = any
}

variable "domain_info" {
  description = "Information about the domain and SSL"
  type        = any
}

variable "eks_cluster_config" {
  description = "Configuration object for the EKS cluster"
  type        = any
}
```

These match what we see in our `vars.tfvars` from earlier steps.

### Select bases for cluster-network

Now, the network stack is a little bit special. Before we can do *anything* else, we need to configure it to allow our target account's IAM role to access EKS, and then we can configure our simple ingress. Therefore, we use 2 bases in `stacks/cluster-network/main.tf`:

```
module "aws_auth" {
  source         = "../../../../bases/eks-aws-auth"
  eks_auth_roles = var.eks_cluster_config.eks_auth_roles
}

module "demo_cluster_ingress" {
  source = "../../../../bases/simple-ingress"

  eks_cluster_config = var.eks_cluster_config
  domain_info        = var.domain_info
  nginx_ingress_info = {
    domain_name               = var.domain_info.domain_name
    subject_alternative_names = var.domain_info.subject_alternative_names

  }
}

```

And once again, set our `variables.tf`:

```
variable "default_tags" {
  type = map(string)
}

variable "domain_info" {
  type = any
}

variable "eks_cluster_config" {
  description = "Configuration object for the EKS cluster"
  type        = any
}

variable "node_groups" {
  description = "unused"
  type        = any
}

```


### Select bases for cluster-addons

And now the addons. In this case, we'll only use the common addons to finalize our EKS cluster:

```
### This remote state allows us to reuse some info from another stack
data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket         = "jpn-automation-dev-tfstate"
    key            = "demo-infra"
    region         = "ap-northeast-1"
    dynamodb_table = "jpn-automation-dev-tfstate"

  }
}

## Get the output we defined in the infra stack
locals {
  common_infra_support_arn = data.terraform_remote_state.infra.outputs.common_infra_support_arn
}

module "common_addons" {
  source                   = "../../../../bases/common-addons"
  common_infra_support_arn = local.common_infra_support_arn
  eks_cluster_config       = var.eks_cluster_config
  domain_info              = var.domain_info
}

```

And define our variables:

```
variable "default_tags" {
  type = map(string)
}

variable "eks_cluster_config" {
  type = any
}

variable "domain_info" {
  type = any
}
```

# Create the GitHub workflow

Create the workflow file, e.g. `.github/workflows/demo.yml` and write the pipeline:

```
name: Demo cluster - deploy

on:
  workflow_dispatch: {}

permissions:
  id-token: write
  contents: read

env:
  PROJECT_DIR: projects/demo

jobs:
  deploy_cluster:
    name: Deploy the EKS infra
    runs-on: jpn-automation-dev
    steps:
      - name: Install tools
        run: sudo apt update && sudo apt install -y curl unzip make gawk git
      - name: Checkout
        uses: actions/checkout@v3
      - name: Get AWS CLI
        run: |
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          unzip awscliv2.zip
          sudo ./aws/install
      - name: Login to AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: arn:aws:iam::492449516969:role/jp-cicd-automation-infra
          role-session-name: github
      - name: Setup Node.js environment
        uses: actions/setup-node@v3.8.1
        with:
          node-version: 18
      - name: HashiCorp - Setup Terraform
        uses: hashicorp/setup-terraform@v2.0.3
        with:
          terraform_version: 1.5
      - name: Check formatting
        run: |
          terraform fmt -check -recursive

      - name: Setup project
        working-directory: ${{ env.PROJECT_DIR }}
        run:
          make STACK=cluster-infra init
      - name: Plan
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-infra plan
      - name: Apply
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-infra apply
  setup_cluster:
    name: Setup the EKS cluster
    runs-on: jpn-automation-dev
    needs: [deploy_cluster]
    steps:
      - name: Install tools
        run: sudo apt update && sudo apt install -y curl unzip make gawk git
      - name: Checkout
        uses: actions/checkout@v3
      - name: Get AWS CLI
        run: |
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          unzip awscliv2.zip
          sudo ./aws/install
      - name: Login to AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: arn:aws:iam::492449516969:role/jp-cicd-automation-infra
          role-session-name: github
      - name: Setup Node.js environment
        uses: actions/setup-node@v3.8.1
        with:
          node-version: 18
      - name: HashiCorp - Setup Terraform
        uses: hashicorp/setup-terraform@v2.0.3
        with:
          terraform_version: 1.5
      - name: Check formatting
        run: |
          terraform fmt -check -recursive

      - name: Setup networking
        working-directory: ${{ env.PROJECT_DIR }}
        run:
          make STACK=cluster-network init
      - name: Plan
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-network plan
      - name: Apply
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-network apply

      - name: Setup addons
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          touch secrets.tfvars
          make STACK=cluster-addons init
      - name: Plan
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-addons plan
      - name: Apply
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-addons apply

```

Similarly for destroying the cluster, `.github/workflows/demo-destroy.yml`:

```
name: Demo cluster - destroy

on:
  workflow_dispatch: {}

permissions:
  id-token: write
  contents: read

env:
  PROJECT_DIR: projects/demo

jobs:
  destroy_addons_network:
    name: Destroy the EKS cluster's addons and networking
    runs-on: jpn-automation-dev
    steps:
      - name: Install tools
        run: sudo apt update && sudo apt install -y curl unzip make gawk git
      - name: Checkout
        uses: actions/checkout@v3
      - name: Get AWS CLI
        run: |
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          unzip awscliv2.zip
          sudo ./aws/install
      - name: Login to AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: arn:aws:iam::492449516969:role/jp-cicd-automation-infra
          role-session-name: github
      - name: Setup Node.js environment
        uses: actions/setup-node@v3.8.1
        with:
          node-version: 18
      - name: HashiCorp - Setup Terraform
        uses: hashicorp/setup-terraform@v2.0.3
        with:
          terraform_version: 1.5
      - name: Check formatting
        run: |
          terraform fmt -check -recursive

      - name: Setup addons
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          touch secrets.tfvars
          make STACK=cluster-addons init
      - name: Plan the addons destroy
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-addons destroy
      - name: Apply
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-addons apply

      - name: Setup networking
        working-directory: ${{ env.PROJECT_DIR }}
        run:
          make STACK=cluster-network init
      - name: Plan the addons destroy
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-network destroy
      - name: Apply
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-network apply


  destroy_cluster:
    name: Destroy the EKS infra
    runs-on: automation-dev
    needs: [destroy_addons_network]
    steps:
       - name: Install tools
        run: sudo apt update && sudo apt install -y curl unzip make gawk git
      - name: Checkout
        uses: actions/checkout@v3
      - name: Get AWS CLI
        run: |
          curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
          unzip awscliv2.zip
          sudo ./aws/install
      - name: Login to AWS
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-region: ap-northeast-1
          role-to-assume: arn:aws:iam::492449516969:role/jp-cicd-automation-infra
          role-session-name: github
      - name: Setup Node.js environment
        uses: actions/setup-node@v3.8.1
        with:
          node-version: 18
      - name: HashiCorp - Setup Terraform
        uses: hashicorp/setup-terraform@v2.0.3
        with:
          terraform_version: 1.5
      - name: Check formatting
        run: |
          terraform fmt -check -recursive

      - name: Setup project
        working-directory: ${{ env.PROJECT_DIR }}
        run:
          make STACK=cluster-infra init
      - name: Plan the infra destroy
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-infra destroy
      - name: Apply
        working-directory: ${{ env.PROJECT_DIR }}
        run: |
          make STACK=cluster-infra apply
```


# Deploy the cluster

Congratulations! You are now ready to deploy a demo EKS cluster in the `AWS JP Automation PREPROD` account!

To deploy the cluster, refer to [deploy-existing-project.md](deploy-existing-project.md)
