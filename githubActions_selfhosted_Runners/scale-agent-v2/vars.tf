variable "git_token" {
  type        = string
  description = "Github service user token external repo scope"
}

variable "default_git_org" {
  type        = string
  description = "Default github organization"
  default     = "SivakumarWork"
}

variable "default_git_secret" {
  type = string
  description = "Default github actions webhook secret"
  default = "gitSecret@123"
  #above just some nonsense, fill it up yourself
}

variable "default_teams_webhook_url" {
  type = string
  description = "Default Teams webhook URL"
  default = "https://amwaycorp.webhook.office.com/webhookb2/0a0dc835-fe65-4b64-b052-2ed37211d3db@38c3fde4-197b-47b9-9500-769f547df698/IncomingWebhook/dd51d47e777b4d64915c41643d27fa3a/5d4ef13a-73b5-4ec4-8360-ebcfeb4717c8"
}

variable "default_instance_type" {
  type        = string
  description = "Default ec2 instance type to run"
  default     = "t3.micro"
}

# Currently def ami is ami for building hybris artifacts
variable "default_ami" {
  type        = string
  description = "Default ami id"
  default     = "ami-0097c5d776653bb6b"
}

variable "default_disk_size" {
  type        = string
  description = "Default instance ebs vol size"
  default     = "10"
}

variable "default_sg" {
  type        = string
  description = "Default security group for runner"
  default     = "sg-01ded624c9fdbb55f"
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
