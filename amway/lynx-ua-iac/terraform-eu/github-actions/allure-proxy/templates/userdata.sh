#!/bin/bash

sed -i "s/S3_BUCKET_NAME/${s3_name}/g" /etc/nginx/nginx.conf
sed -i "s/USER_AGENT_HEADER/${user_agent}/g" /etc/nginx/nginx.conf
systemctl restart nginx
