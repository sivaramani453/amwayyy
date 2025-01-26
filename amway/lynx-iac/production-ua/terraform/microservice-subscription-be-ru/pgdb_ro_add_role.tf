resource "postgresql_role" "pg_ro_role" {
  provider   = postgresql.rds_db
  name       = var.pg_ro_user_name
  login      = true
  password   = var.pg_ro_user_pass
  depends_on = [module.pgsql_rds_sg]
}

resource "postgresql_grant" "pg_tb_grant_ro" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_ro_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "table"
  privileges  = ["SELECT"]
  depends_on  = [module.pgsql_rds_sg]
}

resource "postgresql_grant" "pg_sc_grant_ro" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_ro_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "database"
  privileges  = ["CONNECT"]
  depends_on  = [module.pgsql_rds_sg]
}

resource "postgresql_grant" "pg_fun_grant_ro" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_ro_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "function"
  privileges  = ["EXECUTE"]
  depends_on  = [module.pgsql_rds_sg]
}

resource "postgresql_grant" "pg_seq_grant_ro" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db.name
  role        = postgresql_role.pg_ro_role.name
  schema      = postgresql_schema.pg_schema.name
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT"]
  depends_on  = [module.pgsql_rds_sg]
}

resource "postgresql_default_privileges" "read_only_tables" {
  provider = postgresql.rds_db
  role     = postgresql_role.pg_ro_role.name
  database = postgresql_database.pg_db.name
  schema   = postgresql_schema.pg_schema.name

  owner       = postgresql_role.pg_role.name
  object_type = "table"
  privileges  = ["SELECT"]
}
