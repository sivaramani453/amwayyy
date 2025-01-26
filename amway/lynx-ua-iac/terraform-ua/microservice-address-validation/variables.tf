variable "zookeeper_instance_count" {
  #type        = string
  description = "Number of Zookeeper instances to launch"
  default     = 3
}

variable "zone_id" {
  type    = string
  default = "Z01421911PZSXATXW14QL"
}

variable "zone_name" {
  type    = string
  default = "mspreprod.eia.amway.net"
}

variable "solr_instance_count" {
  type        = string
  description = "Number of Solr instances to launch"
  default     = "2"
}

variable "root_password" {
  type        = string
  description = "Password of the root user for PostgreSQL"
}

variable "microservice_db_user" {
  type        = string
  description = "Microservice user for PostgreSQL"
  default     = "address_user"
}

variable "microservice_db_pass" {
  type        = string
  description = "Password of the microservice user for PostgreSQL"
  default     = "address_pass"
}

variable "path_to_ssh_key" {
  type        = string
  description = "Path to EPAM-SE.pem on our local system"
}

variable "address_validation_url" {
  type        = string
  description = "dns entry for address validation application"
}

variable "adapter_auth_user" {
  type        = string
  description = "User for authorization in adapter"
  default     = "address"
}

variable "adapter_auth_pass" {
  type        = string
  description = "Password for adapter user"
  default     = "address"
}

variable "engine_version" {
  type        = string
  description = "Engine version of the PostgreSQL database"
  default     = "11.15"
}

variable "major_engine_version" {
  type        = string
  description = "Major engine version of the PostgreSQL database"
  default     = "11"
}

variable "amway_env_type" {
  type        = string
  description = "Environment tag type according to Amway's tag specification"
  default     = "DEV"
}

