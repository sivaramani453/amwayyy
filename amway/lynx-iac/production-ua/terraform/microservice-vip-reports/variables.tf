variable "root_password" {
  type = "string"
  default = ""
}

variable "pg_db_name" {
  type        = "string"
  description = "Database RDS DB name"
  default     = "reports"
}

variable "pg_schema_name" {
  type        = "string"
  description = "Database RDS DB schema name"
  default     = "reports"
}

variable "pg_user_name" {
  type        = "string"
  description = "Role name for the PostgreSQL database"
  default     = "reports_user"
}

variable "pg_user_pass" {
  type        = "string"
  description = "Password of the role for PostgreSQL database"
  default = ""
}
