provider "postgresql" {
  alias            = "rds_db"
  host             = aws_db_instance.vip_reports.address
  port             = 5432
  database         = "postgres"
  username         = "root"
  password         = var.root_password
  sslmode          = "require"
  superuser        = "false"
  connect_timeout  = 15
  expected_version = var.engine_version
}

resource "postgresql_role" "pg_role" {
  depends_on = [
    aws_db_instance.vip_reports
  ]
  provider = postgresql.rds_db
  name     = var.pg_user_name
  login    = true
  password = var.pg_user_pass
  #  depends_on = [module.rds_pgsql]
}

resource "postgresql_database" "pg_db" {
  provider = postgresql.rds_db
  name     = var.pg_db_name
  owner    = postgresql_role.pg_role.name
  template = "template0"
  #  depends_on = [module.rds_pgsql]
}

resource "postgresql_schema" "pg_schema" {
  provider     = postgresql.rds_db
  database     = postgresql_database.pg_db.name
  name         = "reports"
  owner        = postgresql_role.pg_role.name
  drop_cascade = true
  #  depends_on = [module.rds_pgsql]
}

resource "postgresql_grant" "pg_tb_grant" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "DELETE", "UPDATE"]
  #  depends_on = [module.rds_pgsql]
}

resource "postgresql_grant" "pg_sc_grant" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "database"
  privileges  = ["CREATE"]
  #  depends_on = [module.rds_pgsql]
}

resource "postgresql_grant" "pg_fun_grant" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "function"
  privileges  = ["EXECUTE"]
  #  depends_on = [module.rds_pgsql]
}

resource "postgresql_grant" "pg_seq_grant" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "sequence"
  privileges  = ["ALL"]
  #  depends_on = [module.rds_pgsql]
}
