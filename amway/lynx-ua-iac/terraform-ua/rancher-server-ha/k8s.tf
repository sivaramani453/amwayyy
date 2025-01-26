module "kubernetes_cluster" {
  source = "../modules/rke-cluster/"

  cluster_name                      = var.cluster_name
  region                            = "eu-central-1"
  create_route53                    = true
  route53_zone_id                   = data.terraform_remote_state.core.outputs.route53_zone_id
  route53_zone_name                 = "mspreprod.eia.amway.net"
  vpc_id                            = data.terraform_remote_state.core.outputs.frankfurt_preprod_vpc_id
  subnets                           = local.subnets
  key_pair                          = "Jan Machalica"
  ami                               = "ami-01772c93f654fab56"
  s3_stage                          = "k8s-test"
  masters                           = var.master_count
  master_shape                      = "t3.large"
  master_volume_size                = 100
  workers                           = var.worker_count
  worker_shape                      = "t3.large"
  worker_volume_size                = 50
  allow_ssh_from_subnets            = ["10.0.0.0/8"]
  allow_kube_api_subnets            = ["10.0.0.0/8"]
  allow_node_ports_subnets          = ["10.0.0.0/8"]
  allow_nginx_ingress_ports_subnets = ["10.0.0.0/8", "192.168.0.0/22"]
  tags                              = local.tags
}


