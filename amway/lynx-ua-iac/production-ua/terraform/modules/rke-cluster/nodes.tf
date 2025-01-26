resource "aws_instance" "kube-masters" {
  count = "${var.masters}"

  ami                    = "${var.ami}"
  instance_type          = "${var.master_shape}"
  ebs_optimized          = "true"
  key_name               = "${var.key_pair}"
  vpc_security_group_ids = ["${aws_security_group.kube-nodes.id}", "${aws_security_group.kube-masters.id}"]
  subnet_id              = "${element(var.subnets, count.index)}"

  root_block_device = [{
    volume_type           = "gp3"
    iops                  = "${var.master_volume_iops}"
    volume_size           = "${var.master_volume_size}"
    delete_on_termination = true
  }]

  tags = "${merge(local.tags, 
                  map("Name", format("%s-%s-%d", var.cluster_name, "master", count.index))
                  )
           }"
}

resource "aws_instance" "kube-workers" {
  count = "${var.workers}"

  ami                    = "${var.ami}"
  instance_type          = "${var.worker_shape}"
  ebs_optimized          = "true"
  key_name               = "${var.key_pair}"
  vpc_security_group_ids = ["${aws_security_group.kube-nodes.id}", "${aws_security_group.kube-workers.id}"]
  subnet_id              = "${element(var.subnets, count.index)}"

  root_block_device = [{
    volume_type           = "gp3"
    volume_size           = "${var.worker_volume_size}"
    delete_on_termination = true
  }]

  tags = "${merge(local.tags,
                  map("Name", format("%s-%s-%d", var.cluster_name, "worker", count.index))
                  )
           }"
}
