provider "postgresql" {
  alias            = "rds_db"
  host             = aws_db_instance.eia_coupons.address
  port             = 5432
  database         = "postgres"
  username         = var.root_username
  password         = var.root_password
  sslmode          = "require"
  superuser        = "false"
  connect_timeout  = 15
  expected_version = var.engine_version
}

resource "postgresql_role" "pg_role" {
  depends_on = [
    aws_db_instance.eia_coupons
  ]
  provider   = postgresql.rds_db
  name       = var.coupon_username
  login      = true
  password   = var.coupon_password
}

resource "postgresql_database" "pg_db" {
  provider   = postgresql.rds_db
  name       = var.coupon_db
  owner      = postgresql_role.pg_role.name
  template   = "template0"
}

resource "postgresql_schema" "pg_schema" {
  provider     = postgresql.rds_db
  database     = postgresql_database.pg_db.name
  name         = var.coupon_schema
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
