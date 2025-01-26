variable "path_to_ssh_key" {
  type        = "string"
  description = "Path to EPAM-SE.pem on our local system"
}

variable "docker_registry_user" {
  type = "string"
}

variable "docker_registry_password" {
  type = "string"
}
