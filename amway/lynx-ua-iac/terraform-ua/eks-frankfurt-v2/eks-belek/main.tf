module "eks" {
  source = "../modules/terraform-aws-eks"

  write_kubeconfig = false
  cluster_name     = "amway-eks"
  cluster_version  = "1.22"
  subnets          = data.terraform_remote_state.core.outputs.spot_subnets
  vpc_id           = data.terraform_remote_state.core.outputs.vpc_id

  worker_security_group_id = aws_security_group.kube_workers.id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.xlarge"
      additional_userdata           = ""
      asg_desired_capacity          = 3
      additional_security_group_ids = []
    },
  ]
}
