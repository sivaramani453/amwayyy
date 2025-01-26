################
#  Each default value could be overrited by workspace name (see git_repo)
################

locals {
  # GitHub
  git_org {
    default = "${var.default_git_org}"
  }

  git_repo {
    default   = "actions"
    iac       = "lynx-iac"
    provision = "lynx-provision"
    charts    = "charts"
    auto      = "AmwayAutoQA"
    lynx      = "lynx"
    lynx-ru   = "lynx-ru"
    lynx-ci   = "lynx-ci-tests"
  }

  git_token {
    default = "${var.git_token}"
  }

  # EC2
  instance_type {
    default = "${var.default_instance_type}"
    auto    = "t3.large"
    lynx    = "t3.large"
    lynx-ru = "t3.large"
    lynx-ci = "t3.xlarge"
  }

  instance_ami {
    default = "${var.default_ami}"
    iac     = "ami-0310703c5901e572b"
    auto    = "ami-0b11c9bf8a62f02d2"
  }

  instance_disk_size {
    default = "${var.default_disk_size}"
    iac     = "8"
    lynx    = "50"
    lynx-ru = "50"
    lynx-ci = "50"
  }

  instance_subnet {
    default = "${data.terraform_remote_state.core.subnet.core_a.id}"
  }

  instance_kp {
    default = "${var.default_kp}"
  }

  instance_sg {
    default = "${var.default_sg}"
  }

  # Common 
  skype_url    = "${var.skype_url}"
  skype_chan   = "${var.skype_chan}"
  skype_secret = "${var.skype_secret}"
}
