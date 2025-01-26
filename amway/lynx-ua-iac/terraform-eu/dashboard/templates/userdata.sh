#!/bin/bash

export AWS_DEFAULT_REGION=eu-central-1

JSON=$(aws secretsmanager get-secret-value --secret-id ${s3_keys_secret_name} | jq --raw-output '.SecretString')
JSON_GIT=$(aws secretsmanager get-secret-value --secret-id ${git_user_secret_name} | jq --raw-output '.SecretString')
JSON_DB=$(aws secretsmanager get-secret-value --secret-id ${db_ro_connection_secret_name} | jq --raw-output '.SecretString')

ACCESS_KEY_ID=$(echo $JSON | jq -r ."aws_access_key_id")
SECRET_ACCESS_KEY=$(echo $JSON | jq -r ."aws_secret_access_key")

GIT_USER=$(echo $JSON_GIT | jq -r ."username")
GIT_TOKEN=$(echo $JSON_GIT | jq -r ."external_repo_scope")

GA_RO_DB_USER=$(echo $JSON_DB | jq -r ."db_ro_username")
GA_RO_DB_PASS=$(echo $JSON_DB | jq -r ."db_ro_password")

## write aws keys to passwd file
echo "$ACCESS_KEY_ID:$SECRET_ACCESS_KEY" > /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs

## add record to fstab to mount it on boot
echo "${s3_bucket_name} ${s3_mount_dir} fuse.s3fs  rw,_netdev,allow_other,umask=0022,multireq_max=5,retries=4,dbglevel=warn 0 0" >> /etc/fstab
## 
echo "${s3_mysql_be_bucket_name} ${s3_mysql_be_mount_dir} fuse.s3fs rw,_netdev,allow_other,umask=0022,multireq_max=5,retries=4,iam_role=auto,dbglevel=warn 0 0" >> /etc/fstab

## mount all entries in the /etc/fstab
mount -a

## clone and copy dashboard source files
git clone https://$GIT_USER:$GIT_TOKEN@github.com/AmwayACS/lynx-eu-dashboard.git /root/lynx-eu-dashboard
rsync -az --exclude '.git' --exclude README.md /root/lynx-eu-dashboard/ /opt/dashboard/site/ && rm -rf /root/lynx-eu-dashboard

## replace credentials in the get_status
sed -i "s:default_user:$GA_RO_DB_USER:g" /opt/dashboard/site/get_status.php && \
sed -i "s:default_pass:$GA_RO_DB_PASS:g" /opt/dashboard/site/get_status.php

chown -R nginx:nginx /opt/dashboard/site

systemctl restart nginx
