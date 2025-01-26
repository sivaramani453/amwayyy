variable "root_password" {
  type        = string
  description = "Password of the root user for PostgreSQL"
}

variable "engine_version" {
  type        = string
  description = "Engine version of the PostgreSQL database"
  default     = "10.15"
}

variable "major_engine_version" {
  type        = string
  description = "Major engine version of the PostgreSQL database"
  default     = "10"
}

variable "pg_db_name" {
  type        = string
  description = "Database RDS instance name"
  default     = "reports-ua-dev"
}

variable "pg_user_name" {
  type        = string
  description = "Role name for the PostgreSQL database"
  default     = "vip_reports_ua_user"
}

variable "pg_user_pass" {
  type        = string
  sensitive   = "true"
  description = "Password of the role for PostgreSQL database"
}

variable "amway_env_type" {
  type        = string
  description = "Environment tag type according to Amway's tag specification"
  default     = "DEV"
}
