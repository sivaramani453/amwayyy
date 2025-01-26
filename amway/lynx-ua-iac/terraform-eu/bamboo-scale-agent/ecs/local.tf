locals {
  core_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_b_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_core_c_id,
  ]

  ci_subnet_ids = [
    data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_a_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_b_id,
    data.terraform_remote_state.core.outputs.frankfurt_subnet_ci_c_id,
  ]

  vpn_subnet_cidrs = [
    "10.0.0.0/8",
  ]

  container = {
    name                           = "${var.ecs_service_name}-container"
    image_name                     = var.container_image_name
    cpu                            = 512
    memory_soft                    = 1024
    memory_hard                    = 1024
    port                           = 80
    count                          = 1
    aws_ci_autotest_ami_id         = "ami-0ad8c148ce09df2c1"
    aws_ci_autotest_ami_snap_id    = "snap-0bde9b2946a9e26d5"
    aws_ci_autotest_instance_shape = "t3a.2xlarge"
    aws_ci_autotest_disk_size      = "30"
    aws_ci_autotest_spot_duration  = "180"
    aws_ci_ami_id                  = "ami-046fc515cd140df04"
    aws_ci_ami_snap_id             = "snap-0b0b0bfa0f09e6a99"
    aws_ci_instance_shape          = "t3a.xlarge"
    aws_ci_disk_size               = "45"
    aws_ci_spot_duration           = "180"
    aws_ci_instance_kp             = "amway-eu-hybris-dev"
  }

  amway_common_tags = {
    Terraform     = "true"
    ApplicationID = "APP1433689"
    Environment   = "DEV"
  }


  amway_data_tags = {
    DataClassification = "Internal"
  }
}
