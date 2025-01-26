provider "postgresql" {
#  version          = "~> 1.13.0"
  alias            = "rds_db"
  host             = "${element(split(":", module.db.this_db_instance_endpoint),0)}"
  port             = "${module.db.this_db_instance_port}"
  database         = "postgres"
  username         = "${module.db.this_db_instance_username}"
  password         = "${module.db.this_db_instance_password}"
  sslmode          = "require"
  superuser        = "false"
  connect_timeout  = 15
  expected_version = "10.17"
}

resource "postgresql_role" "pg_role" {
  provider   = "postgresql.rds_db"
  name       = "${var.pg_user_name}"
  login      = true
  password   = "${var.pg_user_pass != "" ? var.pg_user_pass : random_password.pgsql_user_password.result}}"
}

resource "postgresql_database" "pg_db_ua" {
  provider   = "postgresql.rds_db"
  name       = "${var.pg_db_name}"
  owner      = "${postgresql_role.pg_role.name}"
  template   = "template0"
}

resource "postgresql_schema" "pg_schema_ua" {
  provider     = "postgresql.rds_db"
  database     = "${postgresql_database.pg_db_ua.name}"
  name         = "${var.pg_schema_name}"
  owner        = "${postgresql_role.pg_role.name}"
  drop_cascade = true
}

resource "postgresql_grant" "pg_tb_grant_ua" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db_ua.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema_ua.name}"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "DELETE", "UPDATE"]
}

#resource "postgresql_grant" "pg_fun_grant_ua" {
#  provider    = "postgresql.rds_db"
#  database    = "${postgresql_database.pg_db_ua.name}"
#  role        = "${postgresql_role.pg_role.name}"
#  schema      = "${postgresql_schema.pg_schema_ua.name}"
#  object_type = "function"
#  privileges  = ["EXECUTE"]
#  object_type = "database"
#  privileges  = ["CONNECT"]
#}

resource "postgresql_grant" "pg_sc_grant_ua" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db_ua.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema_ua.name}"
  object_type = "database"
  privileges  = ["CREATE", "CONNECT"]
}

resource "postgresql_grant" "pg_seq_grant_ua" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db_ua.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema_ua.name}"
  object_type = "sequence"
  privileges  = ["ALL"]
}
