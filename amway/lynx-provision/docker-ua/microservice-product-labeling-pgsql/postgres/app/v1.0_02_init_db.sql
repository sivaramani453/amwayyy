CREATE SCHEMA product_labeling AUTHORIZATION product_labeling_user;

GRANT USAGE ON SCHEMA product_labeling TO product_labeling_user;
GRANT SELECT, INSERT, UPDATE, DELETE on ALL TABLES in SCHEMA product_labeling TO product_labeling_user;
GRANT EXECUTE on ALL FUNCTIONS in SCHEMA product_labeling TO product_labeling_user;
GRANT ALL on ALL SEQUENCES in SCHEMA product_labeling TO product_labeling_user;

-- turn on large object compatibility
ALTER DATABASE product_labeling SET lo_compat_privileges TO on;

-- Add extenstion for dblink, necessary to run pg_jobmon
CREATE EXTENSION dblink SCHEMA product_labeling;

-- Add extension for pg_jobmon, necessary to run pg_partman
CREATE EXTENSION pg_jobmon SCHEMA product_labeling;

-- Add extension for pg_partman
CREATE EXTENSION pg_partman SCHEMA product_labeling;

-- Add extension for pg_cron
CREATE EXTENSION pg_cron;

-- insert username/password to dblink connection
INSERT INTO product_labeling.dblink_mapping_jobmon (username, pwd) VALUES ('product_labeling_user', 'product_labeling_pass');
