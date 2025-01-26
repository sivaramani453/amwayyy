data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "prod-amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "gitlab-runner-a" {
  providers = {
    aws = "aws.frankfurt"
  }

  source         = "github.com/lean-delivery/tf-module-aws-gitlab-runner?ref=1.0.6"
  aws_region     = "eu-central-1"
  environment    = "prod-frankfurt-runner-a"
  ssh_public_key = "${file("id_rsa.pub")}"

  gitlab_runner_version = "${var.runner_version}"

  vpc_id                    = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnet_id_gitlab_runner   = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_a.id}"
  subnet_id_runners         = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_a.id}"
  availability_zone_runners = "a"

  docker_machine_instance_type  = "${var.instance_type}"
  docker_machine_spot_price_bid = "${var.spot_price}"

  # Values below are created during the registration process of the runner.
  runners_name             = "${var.runners_name}"
  runners_gitlab_url       = "${var.gitlab_url}"
  runners_token            = "${var.runner_token}"
  runners_off_peak_periods = "${var.runners_off_peak_periods}"

  runner_tags = "${var.runner_tags}"
}

module "gitlab-runner-b" {
  providers = {
    aws = "aws.frankfurt"
  }

  source         = "github.com/lean-delivery/tf-module-aws-gitlab-runner?ref=1.0.6"
  aws_region     = "eu-central-1"
  environment    = "prod-frankfurt-runner-b"
  ssh_public_key = "${file("id_rsa.pub")}"

  gitlab_runner_version = "${var.runner_version}"

  vpc_id                    = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnet_id_gitlab_runner   = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_b.id}"
  subnet_id_runners         = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_b.id}"
  availability_zone_runners = "b"

  docker_machine_instance_type  = "${var.instance_type}"
  docker_machine_spot_price_bid = "${var.spot_price}"

  # Values below are created during the registration process of the runner.
  runners_name             = "${var.runners_name}"
  runners_gitlab_url       = "${var.gitlab_url}"
  runners_token            = "${var.runner_token}"
  runners_off_peak_periods = "${var.runners_off_peak_periods}"

  runner_tags = "${var.runner_tags}"
}

module "gitlab-runner-c" {
  providers = {
    aws = "aws.frankfurt"
  }

  source         = "github.com/lean-delivery/tf-module-aws-gitlab-runner?ref=1.0.6"
  aws_region     = "eu-central-1"
  environment    = "prod-frankfurt-runner-c"
  ssh_public_key = "${file("id_rsa.pub")}"

  gitlab_runner_version = "${var.runner_version}"

  vpc_id                    = "${data.terraform_remote_state.core.frankfurt.prod_vpc.id}"
  subnet_id_gitlab_runner   = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_c.id}"
  subnet_id_runners         = "${data.terraform_remote_state.core.frankfurt.subnet.gitlab_ci_c.id}"
  availability_zone_runners = "c"

  docker_machine_instance_type  = "${var.instance_type}"
  docker_machine_spot_price_bid = "${var.spot_price}"

  # Values below are created during the registration process of the runner.
  runners_name             = "${var.runners_name}"
  runners_gitlab_url       = "${var.gitlab_url}"
  runners_token            = "${var.runner_token}"
  runners_off_peak_periods = "${var.runners_off_peak_periods}"
  runner_tags              = "${var.runner_tags}"
}
