#!/bin/bash

/usr/local/opt/redis/bin/redis-cli -h $1 --scan --pattern "www.kz.amway.com" | xargs -L 1 echo UNLINK | redis-cli -h $1 --pipe

