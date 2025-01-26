resource "postgresql_database" "pg_db_ua_test" {
  provider   = postgresql.rds_db
  name       = var.pg_db_name_ua_test
  owner      = postgresql_role.pg_role.name
  template   = "template0"
}

resource "postgresql_schema" "pg_schema_ua_test" {
  provider     = postgresql.rds_db
  database     = postgresql_database.pg_db_ua_test.name
  name         = var.pg_schema_name
  owner        = postgresql_role.pg_role.name
  drop_cascade = true
}

resource "postgresql_grant" "pg_tb_grant_ua_test" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db_ua_test.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema_ua_test.name
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "DELETE", "UPDATE"]
}

resource "postgresql_grant" "pg_sc_grant_ua_test" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db_ua_test.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema_ua_test.name
  object_type = "database"
  privileges  = ["CREATE", "CONNECT"]
}

resource "postgresql_grant" "pg_fun_grant_ua_test" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db_ua_test.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema_ua_test.name
  object_type = "function"
  privileges  = ["EXECUTE"]
}

resource "postgresql_grant" "pg_seq_grant_ua_test" {
  provider    = postgresql.rds_db
  database    = postgresql_database.pg_db_ua_test.name
  role        = postgresql_role.pg_role.name
  schema      = postgresql_schema.pg_schema_ua_test.name
  object_type = "sequence"
  privileges  = ["ALL"]
}
