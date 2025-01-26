
# Terraform EKS module

## Description

Module provisions scalable EKS cluster with EC2 spot instances as worker nodes.
By defaut terraform code will provision EKS cluster, IAM roles for worker nodes and cluster, additional IAM policies, security groups, instance profile, autoscaling groups and launch configurations for spot and on-demand worker nodes (autoscaling groups will be created per AZ for each launch configuration). Also module will deploy [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/cluster-autoscaler-1.16.1/cluster-autoscaler), [spot termination handler](https://github.com/banzaicloud/banzai-charts/tree/master/spot-termination-handler), [tiller](https://helm.sh/docs/glossary/#tiller),  [metric server](https://github.com/helm/charts/tree/master/stable/metrics-server#metrics-server), [externalDNS](draw.io/externalDNS.png) and [aws-alb-ingress-controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller).

## Deployment diagram:

TBD
<!-- ![deployment](draw.io/eks_infra.png) -->

## Default EKS deployments:

TBD
<!-- ![deployment](draw.io/default_deployments.png) -->

## Requirements

Folloving resources shoud be created before cluster provisioning:
 * AWS VPC - https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
 * AWS Route53 HostedZone

 | Tool       | Version   |
 | ---------- | --------- |
 | terraform  | ==0.11.14  |
 | kubectl    | >=1.13.4   |
 | helm       | >=2.13.1   |
 | aws-cli    | ==1.16.140  |
 | aws-iam-authenticator   |  ==1.12.7  |

## NOTES
 * rendered manifests and Helm charts for Kubernetes will be available in ${path.root}/manifests_rendered. Store it for further edition if required.

## Usage

```HCL
provider "aws" {
  region  = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.67.0"

  name = "amway-frankfurt-eks"

  cidr = "10.120.160.0/22"

  # Subnets
  azs              = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  #FIXME
  private_subnets  = ["10.120.160.0/25", "10.120.160.128/25", "10.120.161.0/25"]
  public_subnets   = ["10.120.161.128/25", "10.120.162.0/25", "10.120.162.128/25"]
  database_subnets = ["10.120.163.0/26", "10.120.163.64/26", "10.120.163.128/26"]

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_dhcp_options  = true

  # NAT
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/amway-frankfurt-dev" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/amway-frankfurt-dev" = "shared"
  }

  vpc_tags = {
    "kubernetes.io/cluster/amway-frankfurt-dev" = "shared"
  }

  tags = {
    Terraform   = "true"
    Service     = "amway-frankfurt-eks"
    Environment = "dev"
  }
}

module "eks" {
  source = "github.com/lean-delivery/tf-module-aws-eks?ref=03473f9849fdbc8a61e0aa755c29742643a95c30"

  # source      = "/Users/artyom_gatalsky/work/projects/ldi/repos/tf-module-aws-eks"
  project     = "amway"
  environment = "frankfurt-dev"

  cluster_version           = "1.14"
  cluster_enabled_log_types = ["api"]

  vpc_id          = "${module.vpc.vpc_id}"
  private_subnets = "${module.vpc.private_subnets}"
  public_subnets  = "${module.vpc.public_subnets}"

  spot_configuration = [
    {
      instance_type              = "t3.large"
      additional_instance_type_1 = "m4.large"
      additional_instance_type_2 = "m5.large"
      spot_price                 = "0.05"
      asg_max_size               = "4"
      asg_min_size               = "1"
      asg_desired_capacity       = "1"
      additional_kubelet_args    = ""
    },
    {
      instance_type              = "t3.xlarge"
      additional_instance_type_1 = "m4.xlarge"
      additional_instance_type_2 = "m5.xlarge"
      spot_price                 = "0.09"
      asg_max_size               = "4"
      asg_min_size               = "0"
      asg_desired_capacity       = "0"
      additional_kubelet_args    = ""
    },
  ]

  on_demand_configuration = [
    {
      instance_type           = "t3.xlarge"
      asg_max_size            = "6"
      asg_min_size            = "0"
      asg_desired_capacity    = "0"
      additional_kubelet_args = ""
    },
  ]

  service_on_demand_configuration = [
    {
      instance_type           = "t3.small"
      asg_max_size            = "1"
      asg_min_size            = "1"
      asg_desired_capacity    = "1"
      additional_kubelet_args = ""
    },
  ]

  worker_nodes_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzX3UBP+PcRwT+KtM3jxlAPrsihEaFaKN74SafmeL0WwCCIk0doHihXc4/bW3Np1VgV8b9Jlr63g7eIFlzdlG3KxqFXFbG+TF/oNjmdmConzQ0uj7l75+xBEBYfN//ZEx5H9V5Am1G/gd/dCGUVV7lyae2CqipNwHsPcfweQixg5huh1cn8511fpYDKSRdVI+qF3flBo6lwNALQI23+TJ8mGHW/Hj3iw1FWD3JqK/gKr1Wvrit1v7gCDQ8wNDVRp/3FElCrH+DQlXgs74x7z6NeZbGUvCfLwOuDFVWOFQr2mvBDpNuCVEB188bHWW2dj9dzv3YCFIGxoPP2dUUIFur"

  deploy_external_dns = true
  external_dns_policy = "upsert-only"
  root_domain         = "hybris.eia.amway.net"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| service\_on\_demand\_configuration | List of maps that contains configurations for ASGs with on-demand workers instances what will be used in EKS-cluster | list | `[{ instance_type = "t3.small", asg_max_size  = "1", asg_min_size  = "1", asg_desired_capacity = "1", additional_kubelet_args = ""}]` | no |
| cluster\_enabled\_log\_types | A list of the desired control plane logging to enable. For more information, see [Amazon EKS Control Plane Logging documentation](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | list | `[]` | no |
| cluster\_version | Kubernetes version to use for the EKS cluster. | string | `"1.14"` | no |
| environment | Environment name is used to identify resources | string | n/a | yes |
| local\_exec\_interpreter | Command to run for local-exec resources. Must be a shell-style interpreter. If you are on Windows Git Bash is a good choice. | list | `["/bin/sh", "-c"]` | no |
| map\_accounts | Additional AWS account numbers to add to the aws-auth configmap. See [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v4.0.0/examples/eks_test_fixture/variables.tf) for example format. | list | `<list>` | no |
| map\_accounts\_count | The count of accounts in the map_accounts list. | string | `"0"` | no |
| map\_roles | Additional IAM roles to add to the aws-auth configmap. See [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v4.0.0/examples/eks_test_fixture/variables.tf) for example format. | list | `<list>` | no |
| map\_roles\_count | The count of roles in the map_roles list. | string | `"0"` | no |
| map\_users | Additional IAM users to add to the aws-auth configmap. See [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v4.0.0/examples/eks_test_fixture/variables.tf) for example format. | list | `<list>` | no |
| map\_users\_count | The count of roles in the map_users list. | string | `"0"` | no |
| on\_demand\_configuration | List of maps that contains configurations for ASGs with on-demand workers instances what will be used in EKS-cluster | list | `[{instance_type = "m4.xlarge", asg_max_size  = "6", asg_min_size  = "0", asg_desired_capacity = "0", additional_kubelet_args = ""}]` | no |
| private\_subnets | List of private subnets for cluster worker nodes provisioning | list | n/a | yes |
| project | Project name is used to identify resources | string | n/a | yes |
| public\_subnets | List of public subnets for ALB provisioning | list | n/a | yes |
| root\_domain | Root domain in which custom DNS record for ALB would be created | string | "" | no |
| spot\_configuration | List of maps that contains configurations for ASGs with spot workers instances what will be used in EKS-cluster | list | `[{instance_type = "m4.large", spot_price = "0.05", asg_max_size  = "4", asg_min_size  = "1", asg_desired_capacity = "1", additional_kubelet_args = ""}, {instance_type = "m4.xlarge", spot_price    = "0.08", asg_max_size  = "4", asg_min_size  = "0", asg_desired_capacity = "0", additional_kubelet_args = ""}]` | no |
| volume\_size | Volume size(GB) for worker node in cluster | string | `"50"` | no |
| vpc\_id | VPC ID for cluster provisioning | string | n/a | yes |
| worker\_nodes\_ssh\_key | If Public ssh key provided, will be used for ssh access to worker nodes. Otherwise instances will be created without ssh key. | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | The Amazon Resource Name (ARN) of the cluster. |
| cluster\_certificate\_authority\_data | EKS cluster certificate. |
| cluster\_endpoint | EKS cluster API endpoint. |
| cluster\_iam\_role\_arn | IAM role ARN of the EKS cluster. |
| cluster\_iam\_role\_name | IAM role name of the EKS cluster. |
| cluster\_id | EKS cluster id. |
| cluster\_security\_group\_id | EKS cluster security group id. |
| cluster\_version | EKS cluster version. |
| config\_map\_aws\_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| iam\_instance\_profile\_name | IAM instance profile name for EKS worker nodes. |
| kubeconfig | kubectl config file contents for this EKS cluster. |
| kubeconfig\_filename | The filename of the generated kubectl config. |
| launch\_configuration\_on\_demand\_asg\_names | Launch configuration name for EKS on-demand worker nodes. |
| launch\_configuration\_service\_on\_demand\_asg\_names | Launch configuration name for EKS non-scalable on-demand worker nodes. |
| launch\_configuration\_spot\_asg\_names | Launch configurations names for EKS spot worker nodes. |
| on\_demand\_asg\_arns | EKS on-demand worker nodes ASGs arns. |
| on\_demand\_asg\_ids | EKS on-demand worker nodes ASGs IDs. |
| on\_demand\_asg\_names | EKS on-demand worker nodes ASGs names. |
| service\_on\_demand\_asg\_arns | EKS non-scalable on-demand worker nodes ASGs arns. |
| service\_on\_demand\_asg\_ids | EKS non-scalable on-demand worker nodes ASGs IDs. |
| service\_on\_demand\_asg\_names | EKS non-scalable on-demand worker nodes ASGs names. |
| path\_to\_manifests | Path to rendered manifests for EKS deployments. |
| spot\_asg\_arns | EKS spot worker nodes ASGs arns. |
| spot\_asg\_ids | EKS spot worker nodes ASGs IDs. |
| spot\_asg\_names | EKS spot worker nodes ASGs names. |
| ssh\_key\_name | SSH key name for worker nodes. |
| worker\_iam\_role\_arn | IAM role ARN for EKS worker groups. |
| worker\_iam\_role\_name | IAM role name for EKS worker groups. |
| worker\_security\_group\_id | Security group ID attached to the EKS workers. |
