#!/bin/bash
echo "shared_preload_libraries = 'pg_cron'" >> $PGDATA/postgresql.conf
echo "cron.database_name = 'product_labeling'" >> $PGDATA/postgresql.conf
echo "pg_partman_bgw.dbname = 'product_labeling'" >> $PGDATA/postgresql.conf
pg_ctl restart
