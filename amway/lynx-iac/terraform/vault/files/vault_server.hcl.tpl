
cluster_name = "${cluster_name}"
max_lease_ttl = "24h"
default_lease_ttl = "24h"

ui = "true"
disable_cache = "true"
disable_mlock = "false"

api_addr = "https://${lb_dns_name}"
cluster_addr = "https://${vault_node_dns_name}:8201"


listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "0.0.0.0:8201" 
  tls_min_version  = "tls12"
  tls_disable      = "true"
}

listener "tcp" {
  address = "127.0.0.1:9200"
  tls_disable = "true"
}

storage "s3" {
  bucket     = "${vault_data_bucket_name}"
  region     = "${region}"
  kms_key_id = "${vault_kms_seal_key_id}"
  max_parallel = "512"
}

ha_storage "dynamodb" {
  ha_enabled = "true"
  table      = "${vault_dynamodb_table_name}"
  region     = "${region}"
  max_parallel   = "25"
  read_capacity  = "5"
  write_capacity = "5"
}

seal "awskms" {
  region     = "${region}"
  kms_key_id = "${vault_kms_seal_key_id}"
}
