output "rds_address" {
  value = "${module.db.this_db_instance_address}"
}

output "rds_port" {
  value = "${module.db.this_db_instance_port}"
}

output "s3_bucket" {
  value = "${module.s3_bucket.bucket_domain_name}"
}

output "s3_bucket_user" {
  value = "${module.s3_bucket.user_name}"
}

output "etcd_nodes" {
  value = "${module.ec2_cluster_etcd.private_ip}"
}

output "worker_nodes" {
  value = "${module.ec2_cluster_worker.private_ip}"
}
