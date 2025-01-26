data "terraform_remote_state" "core" {
  backend = "s3"

  config {
    bucket = "amway-terraform-states"
    key    = "core/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "gitlab-runner" {
  source         = "github.com/lean-delivery/tf-module-aws-gitlab-runner?ref=1.0.3"
  aws_region     = "${data.terraform_remote_state.core.region}"
  environment    = "gitlab-runner"
  ssh_public_key = "${file("id_rsa.pub")}"

  vpc_id                    = "${data.terraform_remote_state.core.vpc.dev.id}"
  subnet_id_gitlab_runner   = "${data.terraform_remote_state.core.subnet.ci_b.id}"
  subnet_id_runners         = "${data.terraform_remote_state.core.subnet.ci_b.id}"
  availability_zone_runners = "b"

  #allow_ssh_cidr_blocks = ["0.0.0.0/0"]

  # Values below are created during the registration process of the runner.
  runners_name             = "gitlab-runner"
  runners_gitlab_url       = "https://gitlab.com/"
  runners_token            = "VaB5YmXi25u4zqBsdKxM"
  runners_off_peak_periods = "* * * * * sat,sun *"
  tags = {
    Terraform = "true"
    Schedule  = "running"
  }
}
