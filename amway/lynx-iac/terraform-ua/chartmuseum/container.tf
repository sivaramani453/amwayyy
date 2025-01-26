data "template_file" "container_definitions" {
  template = "${file("${path.module}/container_definitions/app.json.tpl")}"

  vars {
    name           = "${var.service}-${var.environment}"
    cpu            = "${var.cpu}"
    memory         = "${var.memory}"
    docker_image   = "${var.docker_image}:${var.docker_image_tag}"
    container_port = "${var.container_port}"
    region         = "${data.terraform_remote_state.core.region}"
    log-group      = "${aws_cloudwatch_log_group.common.name}"
    log-prefix     = "${data.terraform_remote_state.core.project}"

    storage               = "${var.app_storage}"
    storage_amazon_bucket = "${aws_s3_bucket.app-backend.id}"
    storage_amazon_region = "${data.terraform_remote_state.core.region}"
    chart_url             = "${var.app_chart_url}"
  }
}
