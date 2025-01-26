resource "null_resource" "create_src_archive" {
  triggers {
    time = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command     = "zip dev_debug_terminate.zip dev_debug_terminate.py"
    on_failure  = "fail"
  }
}

module "lambda_function" {
  depends_on = ["${null_resource.create_src_archive.id}"]
  source     = "../modules/lambda"

  filename           = "${path.module}/src/dev_debug_terminate.zip"
  function_name      = "dev-debug-terminate"
  handler            = "dev_debug_terminate.handler"
  runtime            = "python3.7"
  timeout            = "30"
  custom_tags_common = "${var.custom_tags_common}"

  # Network config (sec group still be created, just ignore it)
  vpc_id  = ""
  subnets = []

  statement_id = "AllowExecutionFromCloudWatch"
  principal    = "events.amazonaws.com"
  arn          = "${aws_cloudwatch_event_rule.every_day.arn}"

  env_vars = "${var.env_vars}"
}

resource "null_resource" "delete_zip_archive" {
  depends_on = ["module.lambda_function"]

  triggers {
    time = "${timestamp()}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    command     = "rm dev_debug_terminate.zip"
  }
}
