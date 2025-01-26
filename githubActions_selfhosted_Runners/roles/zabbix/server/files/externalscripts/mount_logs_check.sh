#!/bin/bash
HOST=$1
USER=root

ssh -ttt  -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i  /usr/lib/zabbix/ssl/art_storage_id_rsa $USER@$HOST 'df -h | grep -q /home/storage/logs/ && echo OK || ( (systemctl restart mount_logs && df -h | grep -q /home/storage/logs/ && echo OK) || echo ERROR with mount logs )' 2>/dev/null || (echo NO connection && exit 0)


