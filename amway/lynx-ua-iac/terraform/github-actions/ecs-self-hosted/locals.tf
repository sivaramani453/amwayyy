locals {
  services = [
    {
      ###################################
      #         AmwayACS/actions        #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "actions"
      git_token          = "${var.git_token}"
      runners            = 0
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #        AmwayACS/lynx-iac        #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "lynx-iac"
      git_token          = "${var.git_token}"
      runners            = 0
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 512

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.micro"
    },
    {
      ###################################
      #     AmwayACS/lynx-provision     #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "lynx-provision"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 512

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.micro"
    },
    {
      #####################################
      #           helm-charts             #
      #####################################
      git_org = "AmwayACS"

      git_repo           = "microservice-helm-charts"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #           lambda-sms            #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "aws-lambda-sms"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #         product labeling        #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-product-labeling"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.large"
    },
    {
      ###################################
      # microservice-address-validation #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-address-validation"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.large"
    },
    {
      ###################################
      #           eia blocks            #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "eia-blocks"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #          eia-coupons            #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-coupons"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #       customs-declaration       #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-customs-declaration"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #              mdms               #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "lynx-ru-mdms"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #          vip-reports            #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "vip-reports"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3.medium"
    },
    {
      ###################################
      #             docgen              #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "docgen"
      git_token          = "${var.git_token}"
      runners            = 2
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.micro"
    },
    {
      ###################################
      #           prerender             #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-prerender"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #   address validation adapter    #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-address-validation-adapter"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #        prerender-heater         #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-prerender-heater"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.micro"
    },
    {
      ###################################
      #          prerender-lb           #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-prerender-load-balancer"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #        bank-identification      #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-bank-identification"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #   AmwayACS/lynx-bamboo-scripts  #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "lynx-bamboo-scripts"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 512

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ############################################
      #   AmwayACS/microservice-functional-test  #
      ############################################
      git_org = "AmwayACS"

      git_repo           = "microservice-functional-test"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 512

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.large"
    },
    {
      #############################
      #   AmwayACS/lynx-ru-apigw  #
      #############################
      git_org = "AmwayACS"

      git_repo           = "lynx-ru-apigw"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 512

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #        document-upload     #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-document-upload-rukz"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 256
      runner_memory_hard = 256

      # job settings
      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
      dm_az             = "b"
      dm_region         = "${data.aws_region.current.name}"
      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
      dm_is_spot        = "no"                                                 # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
  ]

  amway_application_id {
    default = "APP1433689"
    ru      = "APP3150571"
    eu      = "APP1433689"
  }

  amway_common_tags {
    Name          = "${var.cluster_name}"
    Terraform     = "True"
    Environment   = "DEV"
    ApplicationID = "${lookup(local.amway_application_id, replace(terraform.workspace, "/(?:.*)(eu|ru)(?:.*)/", "$1"), local.amway_application_id["default"])}"
  }

  data_tags = {
    DataClassification = "Internal"
  }

  tags = {
    Service        = "github-actions-ecs-self-hosted"
    Project        = "${data.terraform_remote_state.core.project}"
    Tf-Environment = "DEV"
    Tf-Workspace   = "${terraform.workspace}"
    Tf-Application = "github-actions-ecs-self-hosted"
  }
}
