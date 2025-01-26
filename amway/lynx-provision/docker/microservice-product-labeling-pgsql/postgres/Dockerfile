FROM postgres:11.8

RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq \
    && apt-get install -yq --no-install-recommends \
    ca-certificates \
    libpq-dev \
    postgresql-server-dev-11 \
    postgresql-common \
    wget \
    unzip \
    make \
    postgresql-11-cron \
    postgresql-11-partman \
    build-essential \
    libssl-dev \
    libkrb5-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /tmp \
    && wget https://github.com/omniti-labs/pg_jobmon/archive/v1.3.3.zip \
    && unzip v1.3.3.zip \
    && make -C pg_jobmon-1.3.3 \
    && make NO_BGW=1 install -C pg_jobmon-1.3.3 \
    && rm v1.3.3.zip \
    && rm -rf pg_jobmon-1.3.3

RUN apt-get remove -y ca-certificates wget unzip make build-essential \
    && apt-get -y autoremove --purge \
    && apt-get clean \
    && apt-get purge \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

ENV PATH /usr/bin:$PATH
COPY app/v1.0_01_init_pg.sh /docker-entrypoint-initdb.d/
COPY app/v1.0_02_init_db.sql /docker-entrypoint-initdb.d/
COPY app/v1.0_03_init_archive.sql /docker-entrypoint-initdb.d/
