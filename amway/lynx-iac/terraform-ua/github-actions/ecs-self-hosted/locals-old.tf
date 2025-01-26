#    {
#    {  ###################################  
#         AmwayACS/actions        
#  ###################################  
#      git_org = "AmwayACS"
#      git_repo           = "actions"  
#      git_token          = "${var.git_token_epam}"  
#      runners            = 0  
#      labels             = "dev,spot"  
#      init_image         = "amway/actions-init:0.3"  
#      runner_image       = "amway/actions-runner:2.273.5-2"  
#      runner_memory_soft = 256  #      runner_memory_hard = 256
# job settings  
#      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"
# docker machine settings (if capacity)  
#      dm_az             = "b"  
#      dm_region         = "${data.aws_region.current.name}"  
#      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"  
#      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"  
#      dm_is_spot        = "no" # yes or no  
#      dm_block_duration = 60  
#      dm_instance_type  = "t3a.medium"  
#    },  
#    {  ###################################  
#        AmwayACS/lynx-iac        
#  ###################################  
#      git_org = "AmwayACS"
#      git_repo           = "lynx-iac"  
#      git_token          = "${var.git_token_epam}"  
#      runners            = 0  
#      labels             = "dev,spot"  
#      init_image         = "amway/actions-init:0.3"  
#      runner_image       = "amway/actions-runner:2.273.5-2"  
#      runner_memory_soft = 256  
#      runner_memory_hard = 512
# job settings  
#      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"
# docker machine settings (if capacity)  
#      dm_az             = "b"  
#      dm_region         = "${data.aws_region.current.name}"  
#      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"  
#      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"  
#      dm_is_spot        = "no" # yes or no  
#      dm_block_duration = 60  
#      dm_instance_type  = "t3a.micro"  #    },  
#    {  ###################################  
#     AmwayACS/lynx-provision     
#  ###################################  
#      git_org = "AmwayACS"
#      git_repo           = "lynx-provision"  
#      git_token          = "${var.git_token_epam}"  
#      runners            = 1  
#      labels             = "dev,spot"  
#      init_image         = "amway/actions-init:0.3"  
#      runner_image       = "amway/actions-runner:2.273.5-2"  
#      runner_memory_soft = 256  
#      runner_memory_hard = 512
# job settings  
#      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"
# docker machine settings (if capacity)  
#      dm_az             = "b"  
#      dm_region         = "${data.aws_region.current.name}"  
#      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"  
#      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"  
#      dm_is_spot        = "no" # yes or no  
#      dm_block_duration = 60  
#      dm_instance_type  = "t3a.micro"  
#    },
      #####################################
      #           helm-charts             #
      #####################################
#      git_org = "AmwayACS"
#      git_repo           = "microservice-helm-charts"
#      git_token          = "${var.git_token}"
#      runners            = 1
#      labels             = "dev,spot"
#      init_image         = "amway/actions-init:0.3"
#      runner_image       = "amway/actions-runner:2.273.5-2"
#      runner_memory_soft = 256
#      runner_memory_hard = 256

      # job settings
#      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"

      # docker machine settings (if capacity)
#      dm_az             = "b"
#      dm_region         = "${data.aws_region.current.name}"
#      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
#      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
#      dm_is_spot        = "no"                                                 # yes or no
#      dm_block_duration = 60
#      dm_instance_type  = "t3a.medium"
#    },
#    {  
  ###################################  
#           eia blocks            
#  ###################################  
#      git_org = "AmwayACS"
#      git_repo           = "eia-blocks"  
#      git_token          = "${var.git_token_epam}"  
#      runners            = 1  
#      labels             = "dev,spot"  
#      init_image         = "amway/actions-init:0.3"  
#      runner_image       = "amway/actions-runner:2.273.5-2"  
#      runner_memory_soft = 256  
#      runner_memory_hard = 256
# job settings  
#      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"
# docker machine settings (if capacity)  
#      dm_az             = "b"  
#      dm_region         = "${data.aws_region.current.name}"  
#      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"  
#      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"  
#      dm_is_spot        = "no" # yes or no  
#      dm_block_duration = 60  
#      dm_instance_type  = "t3a.medium"  
#    },
#    {  ############################################  
#   AmwayACS/microservice-functional-test  
#  ############################################  
#      git_org = "AmwayACS"
#      git_repo           = "microservice-functional-test"  
#      git_token          = "${var.git_token_epam}"  
#      runners            = 1  
#      labels             = "dev,spot"  
#      init_image         = "amway/actions-init:0.3"  
#      runner_image       = "amway/actions-runner:2.273.5-2"  
#      runner_memory_soft = 256  
#      runner_memory_hard = 512
# job settings  
#      sonar_url = "https://in.sonarqube.hybris.eia.amway.net"
# docker machine settings (if capacity)  
#      dm_az             = "b"  
#      dm_region         = "${data.aws_region.current.name}" 
#      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"  
#      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"  
#      dm_is_spot        = "no" # yes or no  
#      dm_block_duration = 60  
#      dm_instance_type  = "t3a.large"  
#    },
#    {
      ###################################
      #             docgen              #
      ###################################
#      git_org = "AmwayACS"
#      git_repo           = "docgen"
#      git_token          = "${var.git_token}"
#      runners            = 2
#      labels             = "dev,spot"
#      init_image         = "amway/actions-init:0.3"
#      runner_image       = "amway/actions-runner:2.273.5-2"
#      runner_memory_soft = 256
#      runner_memory_hard = 256
      # docker machine settings (if capacity)
#      dm_az             = "b"
#      dm_region         = "${data.aws_region.current.name}"
#      dm_vpc_id         = "${data.terraform_remote_state.core.vpc.dev.id}"
#      dm_subnet_id      = "${data.terraform_remote_state.core.subnet.ci_b.id}"
#      dm_is_spot        = "no"                                                 # yes or no
#      dm_block_duration = 60
#      dm_instance_type  = "t3a.micro"
#    },
