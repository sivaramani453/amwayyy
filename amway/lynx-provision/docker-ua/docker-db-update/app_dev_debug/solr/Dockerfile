FROM solr:7.1

ENV SOLR_HOME=/var/solr/data \
    SOLR_LOGS_DIR=/var/solr/logs \
    SOLR_HEAP=2G \
    SOLR_AUTH_TYPE=basic \
    SOLR_AUTHENTICATION_OPTS="-Dbasicauth=solrserver:server123" \
    SOLR_SSL_ENABLED=false \
    SOLR_SSL_KEY_STORE=/opt/solr/server/etc/solr.jks \
    SOLR_SSL_KEY_STORE_PASSWORD=123456 \
    SOLR_SSL_TRUST_STORE=/opt/solr/server/etc/solr.jks \
    SOLR_SSL_TRUST_STORE_PASSWORD=123456 \
    SOLR_SSL_NEED_CLIENT_AUTH=false \
    SOLR_SSL_WANT_CLIENT_AUTH=true \
    SOLR_SSL_KEY_STORE_TYPE=JKS \
    SOLR_SSL_TRUST_STORE_TYPE=JKS

USER root

COPY ./contrib/hybris /opt/solr/contrib/hybris
COPY ./solr.jks /opt/solr/server/etc/
#COPY ./solr-webapp/webapp/WEB-INF/lib/ /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/

RUN mkdir -p /var/solr/data && \
    mkdir -p /var/solr/logs && \ 
    cp -a /opt/solr/server/solr/solr.xml /var/solr/data/ && \
    cp -a /opt/solr/server/solr/zoo.cfg /var/solr/data/

COPY ./solr_assets/configsets /var/solr/data/configsets

RUN  chown -R solr:solr /var/solr && \
     chown -R solr:solr /opt/solr

EXPOSE 8983
USER solr
