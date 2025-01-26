resource "aws_security_group" "kube-nodes" {
  name_prefix = "${var.cluster_name}-nodes-sg"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.allow_ssh_from_subnets}"
    description = "SSH access"
  }

  ingress {
    from_port = 2376
    to_port   = 2376
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
    description = "Canal np vxlan"
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    self        = true
    description = "Flannel np vxlan"
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
    description = "Kubelet API, metrics"
  }

  ingress {
    from_port   = 10252
    to_port     = 10252
    protocol    = "tcp"
    self        = true
    description = "ControllerManager and Scheduler metrics"
  }

  ingress {
    from_port   = 10254
    to_port     = 10254
    protocol    = "tcp"
    self        = true
    description = "Ingress  metrics"
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    self        = true
    description = "Node Exporter metrics"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}

resource "aws_security_group" "kube-masters" {
  name_prefix = "${var.cluster_name}-masters-sg"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = "${var.allow_kube_api_subnets}"
    description = "Kubernetes API"
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
    description = "etcd nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-masters-sg"
  }
}

resource "aws_security_group" "kube-workers" {
  name_prefix = "${var.cluster_name}-workers-sg"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = "${var.allow_node_ports_subnets}"
    description = "Service NodePorts"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "udp"
    cidr_blocks = "${var.allow_node_ports_subnets}"
    description = "Service NodePorts"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.allow_nginx_ingress_ports_subnets}"
    description = "Ingress HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.allow_nginx_ingress_ports_subnets}"
    description = "Ingress HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-workers-sg"
  }
}
