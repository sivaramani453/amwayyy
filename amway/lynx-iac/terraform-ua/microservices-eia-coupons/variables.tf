variable "root_password" {
  type        = string
  description = "Password of the root user for PostgreSQL"
}

variable "pg_db_name" {
  type        = string
  description = "Database RDS DB name"
  default     = "coupon_ua_dev"
}

variable "pg_schema_name" {
  type        = string
  description = "Database RDS DB schema name"
  default     = "coupon"
}

variable "pg_user_name" {
  type        = string
  description = "Role name for the PostgreSQL database"
  default     = "coupon_ua_user"
}

variable "pg_user_pass" {
  type        = string
  sensitive   = "true"
  description = "Password of the role for PostgreSQL database"
}

variable "engine_version" {
  type        = string
  description = "Engine version of the PostgreSQL database"
  default     = "10.15"
}
