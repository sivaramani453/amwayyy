module "consul-nodes" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.21.0"

  name           = "${data.terraform_remote_state.core.project}-selenoid-consul-cluster-test"
  instance_count = "${var.consul_cluster_size}"

  ami                    = "${data.aws_ami.consul-ami.image_id}"
  key_name               = "EPAM-SE"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${data.aws_security_group.main.id}"]
  subnet_ids             = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]
}
