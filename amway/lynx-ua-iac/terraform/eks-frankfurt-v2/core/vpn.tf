# VPN
resource "aws_vpn_gateway" "frankfurt_eks_v2" {
  vpc_id = "${module.frankfurt-eks-vpc.vpc_id}"

  tags = {
    Name      = "VPG-amway-eks-v2-dev"
    Terraform = "true"
  }
}

resource "aws_vpn_connection" "frankfurt_eks_v2" {
  vpn_gateway_id      = "${aws_vpn_gateway.frankfurt_eks_v2.id}"
  customer_gateway_id = "${data.terraform_remote_state.core.frankfurt.customer_gateway_id}"
  type                = "ipsec.1"
  tunnel1_inside_cidr = "169.254.60.0/30"
  tunnel2_inside_cidr = "169.254.60.4/30"
  static_routes_only  = "false"

  tags = {
    Name      = "vpn_amway-eks-v2-dev"
    Terraform = "true"
  }
}

# VPN Routes
resource "aws_vpn_gateway_route_propagation" "frankfurt_eks_v2_private" {
  count          = "${length(module.frankfurt-eks-vpc.private_route_table_ids)}"
  vpn_gateway_id = "${aws_vpn_gateway.frankfurt_eks_v2.id}"
  route_table_id = "${module.frankfurt-eks-vpc.private_route_table_ids[count.index]}"
}

resource "aws_vpn_gateway_route_propagation" "frankfurt_eks_v2_public" {
  count          = "${length(module.frankfurt-eks-vpc.public_route_table_ids)}"
  vpn_gateway_id = "${aws_vpn_gateway.frankfurt_eks_v2.id}"
  route_table_id = "${module.frankfurt-eks-vpc.public_route_table_ids[count.index]}"
}
