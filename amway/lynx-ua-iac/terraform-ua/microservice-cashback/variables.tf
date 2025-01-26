variable "root_password" {
  type        = "string"
  description = "Password of the root user for PostgreSQL database"
  default     = ""
}

variable "engine_version" {
  type        = "string"
  description = "Engine version of the PostgreSQL database"
  default     = "11.8"
}

variable "major_engine_version" {
  type        = "string"
  description = "Major engine version of the PostgreSQL database"
  default     = "11"
}

variable "pg_db_name" {
  type        = "string"
  description = "Database RDS instance name"
  default     = "cashback"
}

variable "pg_user_name" {
  type        = "string"
  description = "Role name for the PostgreSQL database"
  default     = "cashback_user"
}

variable "pg_user_pass" {
  type = "string"
  #  sensitive   = "true"
  description = "Password of the role for PostgreSQL database"
}
