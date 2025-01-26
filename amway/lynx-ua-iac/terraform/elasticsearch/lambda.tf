resource "null_resource" "get_src_code" {
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
  depends_on = ["${null_resource.get_src_code.id}"]
  source     = "../modules/lambda"

  filename      = "${path.module}/src/curator.zip"
  function_name = "ElasticSearchCurator"
  handler       = "clean_docs.lambda_handler"
  runtime       = "python3.7"
  timeout       = "120"

  # Network config (sec group still be created, just ignore it)
  vpc_id  = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnets = ["${data.terraform_remote_state.core.subnet.core_a.id}", "${data.terraform_remote_state.core.subnet.core_b.id}", "${data.terraform_remote_state.core.subnet.core_c.id}"]

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.every_day.arn}"

  env_vars = {
    "HOST"       = "${aws_elasticsearch_domain.epam-elasticsearch.endpoint}"
    "REGION"     = "eu-central-1"
    "RET_PERIOD" = "7"
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
