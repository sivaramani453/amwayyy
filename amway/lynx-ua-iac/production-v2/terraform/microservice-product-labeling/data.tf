data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-ru-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_subnet" "kube-a" {
  id = "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_a.id}"
}

data "aws_subnet" "kube-b" {
  id = "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_b.id}"
}

data "aws_subnet" "kube-c" {
  id = "${data.terraform_remote_state.core.frankfurt.subnet.kubenetes_c.id}"
}

data "aws_ami" "env_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["MC-PRODUCT-LABELING*"]
  }
}

data "template_file" "nodes_user_data" {
  template = "${file("${path.module}/files/userdata.tpl")}"
}

data "template_file" "hosts" {
  depends_on = ["aws_instance.pl_nodes"]
  template   = "${file("${path.module}/files/hosts.tpl")}"

  vars = {
    pl_node1_fqdn = "${element(aws_route53_record.pl_nodes_urls.*.name, 0)}"
    pl_node2_fqdn = "${element(aws_route53_record.pl_nodes_urls.*.name, 1)}"
    pl_node3_fqdn = "${element(aws_route53_record.pl_nodes_urls.*.name, 2)}"
  }
}
