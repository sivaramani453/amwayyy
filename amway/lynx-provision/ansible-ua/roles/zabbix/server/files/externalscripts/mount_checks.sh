#!/bin/bash
HOST=$1
USER=$2

scp  -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i /usr/lib/zabbix/ssl/EPAM-SE.pem /usr/lib/zabbix/auxiliary_scripts/check_mount.sh $USER@$HOST:/tmp/check_mount.sh 1>/dev/null 2>/dev/null || (echo NO connection && exit 0) 

ssh -ttt  -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -i  /usr/lib/zabbix/ssl/EPAM-SE.pem $USER@$HOST 'sudo bash /tmp/check_mount.sh' 2>/dev/null || (echo NO connection && exit 0)

ssh  -o "UserKnownHostsFile=/dev/null"  -o "StrictHostKeyChecking=no" -i  /usr/lib/zabbix/ssl/EPAM-SE.pem $USER@$HOST 'rm -f /tmp/check_mount.sh' 2>/dev/null 1>/dev/null

