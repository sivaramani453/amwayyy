set -eo pipefail
sudo systemctl stop mysqld
sudo mount -t xfs /dev/nvme1n1p1 /var/lib/mysql
sleep 60

sudo systemctl start mysqld

cat << EOF > script.sql
use hybris;
UPDATE tasks SET p_runningonclusternode = -1;
DELETE FROM JGROUPSPING;
TRUNCATE TABLE carts43sn;
TRUNCATE TABLE solrindexoperation;
TRUNCATE TABLE cronjobhistories;
UPDATE users set p_passwordencoding='plain', passwd='nimda' where p_uid='admin';
EOF

mysql -uhybris -phybris < script.sql

sudo systemctl stop mysqld