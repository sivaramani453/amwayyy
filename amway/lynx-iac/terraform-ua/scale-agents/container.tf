data "template_file" "container_definitions" {
  template = "${file("${path.module}/container_definitions/app.json.tpl")}"

  vars {
    name         = "${var.service}-${var.environment}"
    cpu          = "${var.cpu}"
    memory       = "${var.memory}"
    docker_image = "${var.docker_image}:${var.docker_image_tag}"
    region       = "${data.terraform_remote_state.core.region}"
    log-group    = "${aws_cloudwatch_log_group.common.name}"
    log-prefix   = "${data.terraform_remote_state.core.project}"
  }
}
