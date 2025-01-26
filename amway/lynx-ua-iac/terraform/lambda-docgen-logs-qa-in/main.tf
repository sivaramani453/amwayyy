data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_caller_identity" "current" {}

resource "null_resource" "create_src_archive" {
  triggers {
    time = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src/"
    command     = "make && make install"
    on_failure  = "fail"
  }
}

module "lambda_function" {
  source = "../modules/lambda"

  filename      = "${path.module}/src/docgen_logs.zip"
  function_name = "SendDocGenInQALogs"
  handler       = "docgen_log_sender.lambda_handler"
  runtime       = "python3.7"
  timeout       = "30"

  # Network config
  vpc_id  = "${data.terraform_remote_state.core.vpc.mumbai_dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.mumbai_dev.mumbai_dev_lambda_a.id}", "${data.terraform_remote_state.core.subnet.mumbai_dev.mumbai_dev_lambda_b.id}"]

  # Invoke permission
  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "logs.ap-south-1.amazonaws.com"
  arn          = "arn:aws:logs:ap-south-1:${data.aws_caller_identity.current.account_id}:*:*:*"

  depends_on = ["${null_resource.create_src_archive.id}"]

  env_vars = {
    ES_HOST     = "vpc-aws-elasticsearch-5unizluspnic6n5zudjomi7eam.eu-central-1.es.amazonaws.com"
    ES_PORT     = "443"
    ES_PROTOCOL = "https"
  }
}

resource "null_resource" "delete_deps" {
  depends_on = ["module.lambda_function"]

  triggers {
    time = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src/"
    command     = "make clean"
  }
}
