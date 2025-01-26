locals {
  
#   git_token = {
#     default = "${var.git_token}"
#   }

#   git_org = {
#     default = "${var.default_git_org}"
#   }

#   git_secret = {
#     default = "${var.default_git_secret}"
#   }

#   git_repo = {
#     default   = "actions"
#     iac       = "lynx-iac"
#     provision = "lynx-provision"
#     charts    = "charts"
#     auto      = "AmwayAutoQA"
#     lynx      = "lynx-test"
#     lynx-ci   = "lynx-ci-tests"
#     dashboard = "lynx-eu-dashboard"
#     bamboodev = "lynx-bamboo-job-dev"
#   }

#   teams_webhook_url = {
#     default = <<EOL
#     https://amwaycorp.webhook.office.com/webhookb2/0a0dc835-fe65-4b64-b052-2ed37211d3db@38c3fde4-197b-47b9-9500-769f547df698/IncomingWebhook/dd51d47e777b4d64915c41643d27fa3a/5d4ef13a-73b5-4ec4-8360-ebcfeb4717c8
#     https://epam.webhook.office.com/webhookb2/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/82a5178714a345d3bb00db9f15a51968/ddd52314-da27-45e9-a3ca-d22551bfcec4
#     EOL
#     bamboodev = <<EOL
#     https://amwaycorp.webhook.office.com/webhookb2/0a0dc835-fe65-4b64-b052-2ed37211d3db@38c3fde4-197b-47b9-9500-769f547df698/IncomingWebhook/dd51d47e777b4d64915c41643d27fa3a/5d4ef13a-73b5-4ec4-8360-ebcfeb4717c8
#     https://epam.webhook.office.com/webhookb2/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/82a5178714a345d3bb00db9f15a51968/ddd52314-da27-45e9-a3ca-d22551bfcec4
#     EOL
#     auto = <<EOL
#     https://amwaycorp.webhook.office.com/webhookb2/0a0dc835-fe65-4b64-b052-2ed37211d3db@38c3fde4-197b-47b9-9500-769f547df698/IncomingWebhook/dd51d47e777b4d64915c41643d27fa3a/5d4ef13a-73b5-4ec4-8360-ebcfeb4717c8
#     https://epam.webhook.office.com/webhookb2/f96ab52f-f6a2-46f6-9063-6fd2bde0ce30@b41b72d0-4e9f-4c26-8a69-f949f367c91d/IncomingWebhook/82a5178714a345d3bb00db9f15a51968/ddd52314-da27-45e9-a3ca-d22551bfcec4
#     EOL
#   }

#   spot_maxprice = {
#     default = "0.06"
#     bamboodev = "0.06"
#   }

#   instance_type = {
#     default = "${var.default_instance_type}"
#     auto    = "t3.large"
#     lynx    = "t3.large"
#     lynx-ci = "t3.xlarge"
#   }

#   instance_ondemand = {
#     default = "0"
#     lynx    = "1"
#   }

#   instance_ami = {
#     default   = "${var.default_ami}"
#     lynx      = "ami-08245a6d0de29f0be"
#     auto      = "ami-05d40e45d8f06844d"
#     # "ami-06de50716d83b8361"
#     iac       = "ami-0715cf14be57864fb"
#     dashboard = "ami-020db6fd42f3bfe26"
#     bamboodev = "ami-0e17130c2bca4d3dc"
#   }

#   instance_disk_size = {
#     default = "${var.default_disk_size}"
#     iac     = "8"
#     lynx    = "50"
#     lynx-ci = "50"
#   }

#   instance_subnet = {
#     default   = <<EOL
# ${data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_a_id}
# ${data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_b_id}
# ${data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_c_id}
#     EOL
#   }

#   instance_kp = {
#     default = "${var.default_kp}"
#   }

#   instance_sg = {
#     default = "${var.default_sg}"
#   }

#   lambda_subnet_ids = [
#     data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_a_id,
#     data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_b_id,
#     data.terraform_remote_state.core.outputs.frankfurt_subnet_lambda_c_id,
#   ]

# #   vpc_cidr = [
# #     "10.0.0.0/8",
# #   ]

  common_tags = {
    Terraform     = "true"
    Owner = "Ramani Sivakumar"
    Environment   = "DEV"
    project = "Internal"
  }

  instance_subnet = {
    default   = <<EOL
      ${data.aws_subnet.subnet_id1.id}
      ${data.aws_subnet.subnet_id2.id}
    EOL
  }

#   data_tags = {
#     DataClassification = "Internal"
#   }
}
