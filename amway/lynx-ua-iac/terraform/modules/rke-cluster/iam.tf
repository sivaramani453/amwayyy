data "template_file" "instance_role_trust_policy" {
  template = "${file("${path.module}/policies/instance-role-trust-policy.json")}"
}

data "template_file" "s3_bucket_policy" {
  template = "${file("${path.module}/policies/s3-policy.json")}"

  vars = {
    s3_arn = "${module.s3_bucket.bucket_arn}"
  }
}

resource "aws_iam_role" "etcd_node" {
  name = "${var.cluster_name}-s3-access-role"

  #The policy that grants an entity permission to assume the role
  assume_role_policy = "${data.template_file.instance_role_trust_policy.rendered}"
}

resource "aws_iam_instance_profile" "etcd_node" {
  name = "${var.cluster_name}-s3-access-profile"
  role = "${aws_iam_role.etcd_node.name}"
}

resource "aws_iam_policy" "etcd_s3_policy" {
  name        = "${var.cluster_name}-s3-access-policy"
  path        = "/"
  description = "Policy for etcd nodes to access s3 bucket for backups."

  policy = "${data.template_file.s3_bucket_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "etcd_node" {
  role       = "${aws_iam_role.etcd_node.name}"
  policy_arn = "${aws_iam_policy.etcd_s3_policy.arn}"
}
