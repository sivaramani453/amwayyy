provider "postgresql" {
  version          = "~> 1.7.1"
  alias            = "rds_db"
  host             = "${element(split(":", module.rds_pgsql.this_db_instance_endpoint),0)}"
  port             = "${module.rds_pgsql.this_db_instance_port}"
  database         = "postgres"
  username         = "${module.rds_pgsql.this_db_instance_username}"
  password         = "${module.rds_pgsql.this_db_instance_password}"
  sslmode          = "require"
  superuser        = "false"
  connect_timeout  = 15
  expected_version = "${var.engine_version}"
}

resource "postgresql_role" "pg_role" {
  provider   = "postgresql.rds_db"
  name       = "${var.pg_user_name}"
  login      = true
  password   = "${var.pg_user_pass}"
  depends_on = ["module.pgsql_rds_sg"]
}

resource "postgresql_role" "pg_role_nagarro" {
  provider   = "postgresql.rds_db"
  name       = "nagarro"
  login      = true
  password   = "${var.pg_user_pass_nagaro}"
  depends_on = ["module.pgsql_rds_sg"]
}

resource "postgresql_database" "pg_db" {
  provider   = "postgresql.rds_db"
  name       = "pudo"
  owner      = "${postgresql_role.pg_role.name}"
  template   = "template0"
  depends_on = ["module.pgsql_rds_sg"]
}

resource "postgresql_schema" "pg_schema" {
  provider     = "postgresql.rds_db"
  database     = "${postgresql_database.pg_db.name}"
  name         = "${postgresql_database.pg_db.name}"
  owner        = "${postgresql_role.pg_role.name}"
  drop_cascade = true
  depends_on   = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_tb_grant" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema.name}"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "DELETE", "UPDATE"]
  depends_on  = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_tb_grant_nagarro" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db.name}"
  role        = "${postgresql_role.pg_role_nagarro.name}"
  schema      = "${postgresql_schema.pg_schema.name}"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "DELETE", "UPDATE"]
  depends_on  = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_fun_grant" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema.name}"
  object_type = "function"
  privileges  = ["EXECUTE"]
  depends_on  = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_fun_grant_nagarro" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db.name}"
  role        = "${postgresql_role.pg_role_nagarro.name}"
  schema      = "${postgresql_schema.pg_schema.name}"
  object_type = "function"
  privileges  = ["EXECUTE"]
  depends_on  = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_seq_grant" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema.name}"
  object_type = "sequence"
  privileges  = ["ALL"]
  depends_on  = ["module.pgsql_rds_sg"]
}
