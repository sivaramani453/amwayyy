variable "default_git_org" {
  type        = string
  description = "Default github organization"
  default     = "AmwayACS"
}

variable "git_token" {
  type        = string
  description = "Github service user token external repo scope"
}

variable "default_instance_type" {
  type        = string
  description = "Default ec2 instance type to run"
  default     = "t3a.micro"
}

# Currently def ami is ami for building hybris artifacts
variable "default_ami" {
  type        = string
  description = "Default ami id"
  default     = "ami-0de6f89f065643b44"
}

variable "default_disk_size" {
  type        = string
  description = "Default instance ebs vol size"
  default     = "30"
}

variable "default_sg" {
  type        = string
  description = "Default security group for runner (hybris trust by default)"
  default     = "sg-03040dbe268f59fa6"
}

variable "default_kp" {
  type        = string
  description = "Keypair to launch an intance with"
  default     = "amway-eu-hybris-dev"
}

variable "skype_url" {
  type        = string
  description = "Skype bot url"
  default     = "https://touch.epm-esp.projects.epam.com/bot-esp/message"
}

variable "skype_chan" {
  type        = string
  description = "Notification channel for skype"
  default     = "aweu_eia_system_engineering"
}

variable "skype_secret" {
  type        = string
  description = "Skype secret for bot"
}
