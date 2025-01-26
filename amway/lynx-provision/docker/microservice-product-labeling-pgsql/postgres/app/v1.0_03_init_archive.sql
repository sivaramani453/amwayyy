CREATE SCHEMA product_labeling_archive AUTHORIZATION product_labeling_user;

GRANT USAGE ON SCHEMA product_labeling_archive TO product_labeling_user;
GRANT SELECT, INSERT, UPDATE, DELETE on ALL TABLES in SCHEMA product_labeling_archive TO product_labeling_user;
GRANT EXECUTE on ALL FUNCTIONS in SCHEMA product_labeling_archive TO product_labeling_user;
GRANT ALL on ALL SEQUENCES in SCHEMA product_labeling_archive TO product_labeling_user;
