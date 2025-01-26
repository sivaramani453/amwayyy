locals {
  services = [
    {
      # sms microservice
      git_org            = "AmwayACS"
      git_repo           = "aws-lambda-sms"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "prod"
      init_image         = "amway/actions-init:0.1"
      runner_image       = "amway/actions-runner:2.267.1-1"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_b.id}"
      dm_is_spot        = "no"                                                                  # yes/no
      dm_block_duration = 60
      dm_instance_type  = "t3.micro"
    },
    {
      # product labeling
      git_org            = "AmwayACS"
      git_repo           = "microservice-product-labeling"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "prod"
      init_image         = "amway/actions-init:0.1"
      runner_image       = "amway/actions-runner:2.267.1-2"
      runner_memory_soft = 512
      runner_memory_hard = 512

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_b.id}"
      dm_is_spot        = "no"                                                                  # yes/no
      dm_block_duration = 60
      dm_instance_type  = "t3.large"
    },
    {
      # docgen
      git_org            = "AmwayACS"
      git_repo           = "docgen"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "prod"
      init_image         = "amway/actions-init:0.1"
      runner_image       = "amway/actions-runner:2.267.1-1"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_b.id}"
      dm_is_spot        = "no"                                                                  # yes/no
      dm_block_duration = 60
      dm_instance_type  = "t3.micro"
    },
  ]
}
