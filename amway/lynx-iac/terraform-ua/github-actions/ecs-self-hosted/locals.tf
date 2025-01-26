locals {
  services = [
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
      #####################################
      #           helm-charts-v3          #
      #####################################
      git_org = "AmwayACS"

      git_repo           = "microservice-helm-chart-v3"
      git_token          = "${var.git_token}"
      runners            = 1
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
      dm_is_spot        = "yes"
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
      #   AmwayACS/lynx-ru-bamboo-scripts  #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "lynx-ru-bamboo-scripts"
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
      #############################################
      #        microservice-cashback  #
      #############################################
      git_org = "AmwayACS"

      git_repo           = "microservice-cashback"
      git_token          = "${var.git_token}"
      runners            = 1
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
      dm_instance_type  = "t3a.medium"
    },
    {
      ##########################################
      #  microservice-chatbot-api-ru           #
      #########################################
      git_org = "AmwayACS"

      git_repo           = "microservice-chatbot-api-ru"
      git_token          = "${var.git_token}"
      runners            = 1
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
      dm_instance_type  = "t3.medium"
    },
    {
      #############################################
      #        microservice-eventmapper  #
      #############################################
      git_org = "AmwayACS"

      git_repo           = "microservice-hybriseventmapper-ru"
      git_token          = "${var.git_token}"
      runners            = 1
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
      dm_instance_type  = "t3a.medium"
    },
    {
      #############################################
      #        microservice-marketplace-auth-rukz  #
      #############################################
      git_org = "AmwayACS"

      git_repo           = "microservice-marketplace-auth-rukz"
      git_token          = "${var.git_token}"
      runners            = 1
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
      dm_instance_type  = "t3a.medium"
    },
    {
      ########################################
      #        microservice-ozon-auth front  #
      #######################################
      git_org = "AmwayACS"

      git_repo           = "frontend-ozon-authorization-cis"
      git_token          = "${var.git_token}"
      runners            = 1
      labels             = "dev,spot"
      init_image         = "amway/actions-init:0.3"
      runner_image       = "amway/actions-runner:2.273.5-2"
      runner_memory_soft = 512
      runner_memory_hard = 1024

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
      #############################################
      #        microservice-ozon-orders-ru  #
      #############################################
      git_org = "AmwayACS"

      git_repo           = "microservice-ozon-orders-ru"
      git_token          = "${var.git_token}"
      runners            = 1
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
      dm_instance_type  = "t3a.medium"
    },
    {
      ###################################
      #           microservice-prerender             #
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
      #        microservice-prerender-heater         #
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
      #          microservice-prerender-lb           #
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
      ##########################################
      #  microservice-subscription-frontend-ru #
      #########################################
      git_org = "AmwayACS"

      git_repo           = "microservice-subscription-frontend-ru"
      git_token          = "${var.git_token}"
      runners            = 1
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
      dm_instance_type  = "t3.medium"
    },
    {
      ###################################
      # microservice-subscription-be-ru #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-subscription-be-ru"
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
      #############################################
      #        microservice-pii-proxy-ru          #
      #############################################
      git_org = "AmwayACS"

      git_repo           = "microservice-pii-proxy-ru"
      git_token          = "${var.git_token}"
      runners            = 1
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
      dm_is_spot        = "no" # yes or no
      dm_block_duration = 60
      dm_instance_type  = "t3a.medium"
    },
    {
      #############################################
      #        microservice-vk-integration-ru  #
      #############################################
      git_org = "AmwayACS"

      git_repo           = "microservice-vk-integration-ru"
      git_token          = "${var.git_token}"
      runners            = 1
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
      #          microservice-amp-upload-ru           #
      ###################################
      git_org = "AmwayACS"

      git_repo           = "microservice-amp-upload-ru"
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
  ]
}
