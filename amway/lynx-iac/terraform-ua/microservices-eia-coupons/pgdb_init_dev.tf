provider "postgresql" {
  alias            = "rds_db"
  host             = "eia-coupons-db.clyiioiw1agv.eu-central-1.rds.amazonaws.com"
  port             = 5432
  database         = "postgres"
  username         = "coupon_user"
  password         = var.root_password
  sslmode          = "require"
  superuser        = "false"
  connect_timeout  = 15
  expected_version = var.engine_version
}

resource "postgresql_role" "pg_role" {
  provider   = postgresql.rds_db
  name       = var.pg_user_name
  login      = true
  password   = var.pg_user_pass
}

resource "postgresql_database" "pg_db" {
  provider   = postgresql.rds_db
  name       = var.pg_db_name
  owner      = postgresql_role.pg_role.name
  template   = "template0"
}

resource "postgresql_schema" "pg_schema" {
  provider     = postgresql.rds_db
  database     = postgresql_database.pg_db.name
  name         = var.pg_schema_name
  owner        = postgresql_role.pg_role.name
  drop_cascade = true
}

resource "postgresql_grant" "pg_tb_grant" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "DELETE", "UPDATE"]
}

resource "postgresql_grant" "pg_sc_grant" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "database"
  privileges  = ["CREATE"]
}

resource "postgresql_grant" "pg_fun_grant" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "function"
  privileges  = ["EXECUTE"]
}

resource "postgresql_grant" "pg_seq_grant" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "sequence"
  privileges  = ["ALL"]
}
