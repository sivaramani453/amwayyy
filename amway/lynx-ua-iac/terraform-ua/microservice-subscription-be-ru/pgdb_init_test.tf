resource "postgresql_database" "pg_db_test" {
  provider   = "postgresql.rds_db"
  name       = "subscription-be-ru-test"
  owner      = "${postgresql_role.pg_role.name}"
  template   = "template0"
  depends_on = ["module.pgsql_rds_sg"]
}

resource "postgresql_schema" "pg_schema_test" {
  provider     = "postgresql.rds_db"
  database     = "${postgresql_database.pg_db_test.name}"
  name         = "public"
  owner        = "${postgresql_role.pg_role.name}"
  drop_cascade = true
  depends_on   = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_tb_grant_test" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db_test.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema_test.name}"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "DELETE", "UPDATE"]
  depends_on  = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_sc_grant_test" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db_test.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema_test.name}"
  object_type = "database"
  privileges  = ["CREATE"]
  depends_on  = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_fun_grant_test" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db_test.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema_test.name}"
  object_type = "function"
  privileges  = ["EXECUTE"]
  depends_on  = ["module.pgsql_rds_sg"]
}

resource "postgresql_grant" "pg_seq_grant_test" {
  provider    = "postgresql.rds_db"
  database    = "${postgresql_database.pg_db_test.name}"
  role        = "${postgresql_role.pg_role.name}"
  schema      = "${postgresql_schema.pg_schema_test.name}"
  object_type = "sequence"
  privileges  = ["ALL"]
  depends_on  = ["module.pgsql_rds_sg"]
}
