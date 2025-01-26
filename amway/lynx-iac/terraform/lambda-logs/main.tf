# Network data required
data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "null_resource" "make" {
  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command     = "GOOS=linux BINARY_NAME=${var.handlername} make; BINARY_NAME=${var.handlername} make install"
  }
}

module "lambda_function" {
  source = "../modules/lambda"

  filename           = "${path.module}/src/${var.handlername}.zip"
  function_name      = "${var.function_name}"
  handler            = "${var.handlername}"
  runtime            = "go1.x"
  timeout            = "${var.timeout}"
  env_vars           = "${var.env_vars}"
  custom_tags_common = "${var.custom_tags_common}"

  # Network config
  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]

  # invoke permission
  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "logs.${var.region}.amazonaws.com"
  arn          = "arn:aws:logs:eu-central-1:860702706577:*:*:*"

  depends_on = ["null_resource.make"]
}

resource "null_resource" "make_uninstall" {
  # just wait lambda module
  triggers {
    tmp = "${module.lambda_function.invoke_arn}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command     = "BINARY_NAME=${var.handlername} make clean"
  }
}
