module "selenoid" {
  source = "github.com/lean-delivery/tf-module-aws-spot-fleet"

  name = "selenoid"
  type = "common_node"

  subnet_id                        = "${data.terraform_remote_state.core.subnet.core_a.id}"
  security_group_ids               = ["${data.terraform_remote_state.selenoid-admin.instances_sg_id}"]
  termination_on_expiration_policy = true

  ssh_key  = "EPAM-SE"
  capacity = "${var.selenoid_node_count}"

  common_node_ami_id = "${data.aws_ami.selenoid.image_id}"
  ec2_type           = "${var.selenoid_node_shape}"
  public_ip          = "false"
  valid_until        = "${var.spot_liveness}"

  userdata = "/usr/local/bin/consul services register /etc/consul/consul.d/*.json"
}
