module "eks-external-dns" {
  source  = "../modules/terraform-aws-eks-external-dns"
  domains = ["mspreprod.eia.amway.net"]

  sources = ["ingress", "service"]

  owner_id                             = "amway-eks-external-dns"
  aws_iam_policy_name                  = "amway_eks_external_dns"
  aws_iam_role_for_policy              = module.eks.worker_iam_role_name
}
