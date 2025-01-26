variable "ecs_service_name" {
  description = "The name of the instance-scheduler ecs service"
  default     = "instance-scheduler-eu"
}

variable "instance_scheduler_config_table_name" {
  description = "The instance-scheduler config table name for dynamodb created by the AWS CloudFormation"
  default     = "amway-eu-instance-scheduler-ConfigTable-6WWZIRVL7S0X"
}

variable "instance_scheduler_kms_arn" {
  description = "The instance-scheduler kms key arn created by the AWS CloudFormation"
  default     = "arn:aws:kms:eu-central-1:744058822102:key/48a8dc69-91e6-40d7-a696-d512db863869"
}

variable "container_image_name" {
  description = "The name of the continaer image in the ecr"
  default     = "744058822102.dkr.ecr.eu-central-1.amazonaws.com/instance-scheduler-eu:v1.1"
}
