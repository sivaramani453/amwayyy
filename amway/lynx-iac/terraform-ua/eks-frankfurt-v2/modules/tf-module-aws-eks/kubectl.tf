resource "null_resource" "eks_cluster" {
  triggers = {
    cluster_id = "${module.eks.cluster_id}"
  }
}

data "aws_subnet" "pvc_subnet" {
  id = "${var.spot_subnets[0]}"
}

resource "null_resource" "check_api" {
  depends_on = ["null_resource.eks_cluster"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
exit_code=1
while [ $exit_code -ne 0 ]; do \
exit_code=$(kubectl get pods --all-namespaces --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename} | echo &?); \
sleep 5; \
done;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "priority_class" {
  depends_on = ["null_resource.check_api"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/high-priority--deployments-priorityclass.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename};
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "install_tiller" {
  depends_on = ["null_resource.check_api", "aws_autoscaling_group.spot-asg"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/tiller-rbac.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
helm init --wait --service-account tiller --history-max 10 --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "external_dns_manifest" {
  template = "${file("${path.module}/manifests_templates/external-dns.tpl")}"

  vars = {
    root_domain = "${var.root_domain}"
    policy      = "${var.external_dns_policy}"
    project     = "${var.project}"
    environment = "${var.environment}"
  }
}

resource "local_file" "external_dns_manifest" {
  content  = "${data.template_file.external_dns_manifest.rendered}"
  filename = "${path.module}/manifests/external_dns.yaml"
}

resource "null_resource" "deploy_external_dns" {
  count      = "${ var.deploy_external_dns ? 1 : 0 }"
  depends_on = ["null_resource.check_api", "local_file.external_dns_manifest"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/external_dns.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "cluster_autoscaler_config" {
  template = "${file("${path.module}/manifests_templates/cluster-autoscaler/kubernetes-autoscaler.tpl")}"

  vars = {
    cluster_name = "${var.project}-${var.environment}"
    region       = "${data.aws_region.current.name}"
  }
}

resource "local_file" "cluster_autoscaler_config" {
  content  = "${data.template_file.cluster_autoscaler_config.rendered}"
  filename = "${path.module}/manifests/cluster-autoscaler/kubernetes-autoscaler.yaml"
}

data "template_file" "cluster_autoscaler_priority_configmap" {
  template = "${file("${path.module}/manifests_templates/cluster-autoscaler/autoscaler-priority.tpl")}"

  vars = {
    project     = "${var.project}"
    environment = "${var.environment}"
  }
}

resource "local_file" "cluster_autoscaler_priority_configmap" {
  content  = "${data.template_file.cluster_autoscaler_priority_configmap.rendered}"
  filename = "${path.module}/manifests/cluster-autoscaler/autoscaler-priority.yaml"
}

resource "null_resource" "deploy_cluster_autoscaler" {
  depends_on = ["local_file.cluster_autoscaler_config", "null_resource.priority_class", "local_file.cluster_autoscaler_priority_configmap"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/cluster-autoscaler/autoscaler-priority.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
kubectl apply -f manifests/cluster-autoscaler/kubernetes-autoscaler.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "deploy_metric_server" {
  depends_on = ["null_resource.check_api"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/metric-server/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "deploy_spot-termination-handler" {
  depends_on = ["null_resource.install_tiller"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
helm install --namespace kube-system --name termination-handler manifests/spot-termination-handler/ --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

data "template_file" "aws_alb_ingress_config" {
  template = "${file("${path.module}/manifests_templates/aws-alb-ingress/alb-ingress-controller.tpl")}"

  vars = {
    cluster_name = "${var.project}-${var.environment}"
    region       = "${data.aws_region.current.name}"
    vpc_id       = "${var.vpc_id}"
  }
}

resource "local_file" "aws_alb_ingress_config" {
  content  = "${data.template_file.aws_alb_ingress_config.rendered}"
  filename = "${path.module}/manifests/aws-alb-ingress/alb-ingress-controller.yaml"
}

resource "null_resource" "deploy_aws_alb_ingress" {
  depends_on = ["null_resource.check_api", "local_file.aws_alb_ingress_config"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
kubectl apply -f manifests/aws-alb-ingress/rbac-role.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5; \
kubectl apply -f manifests/aws-alb-ingress/alb-ingress-controller.yaml --kubeconfig ${path.cwd}/${module.eks.kubeconfig_filename}; \
sleep 5;
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}

resource "null_resource" "copy_manifests" {
  depends_on = ["null_resource.deploy_cluster_autoscaler", "local_file.external_dns_manifest", "null_resource.deploy_aws_alb_ingress"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
cp -r ${path.module}/manifests ${path.root}/manifests_rendered
EOS

    interpreter = ["${var.local_exec_interpreter}"]
  }
}
