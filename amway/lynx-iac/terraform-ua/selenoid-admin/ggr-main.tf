module "go-grid-router" {
  source = "github.com/lean-delivery/tf-module-aws-spot-fleet"

  name = "go-griyeyed-router"
  type = "common_node"

  subnet_id          = "${data.terraform_remote_state.core.subnet.core_a.id}"
  security_group_ids = ["${aws_security_group.EIA-selenoid.id}"]
  ssh_key            = "EPAM-SE"
  capacity           = "${var.go-grid-router_node_count}"

  lb_integration    = "true"
  load_balancers    = ["${module.ggr-alb.load_balancer_id}"]
  target_group_arns = ["${module.ggr-alb.target_group_arns}"]

  common_node_ami_id = "${data.aws_ami.go-grid-router.image_id}"
  ec2_type           = "${var.go-grid-router_node_shape}"
  public_ip          = "false"

  userdata = "/usr/local/bin/consul services register /etc/consul/consul.d/*.json"
}
