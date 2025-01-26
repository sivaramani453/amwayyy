FROM nexus.hybris.eia.amway.net:8083/hybris:6.6.0.19

ENV JAVA_HOME=/opt/jre/jre1.8.0_131/ \
    PATH=$JAVA_HOME/bin:$PATH

RUN yum -y -d1 install git && \
    yum clean all

COPY ./lynx /opt/hybris/bin/custom
COPY ./lynx-config /opt/hybris/config
COPY ./solr-configuration.impex /opt/hybris/

RUN chown -R hybris:hybris /opt/hybris/bin/custom && \
    chown -R hybris:hybris /opt/hybris/config && \
    mkdir /opt/media && \
    chown -R hybris:hybris /opt/media

USER hybris
WORKDIR /opt/hybris

RUN cp -Rv ./config/solr_assets/configsets \ 
           ./bin/ext-commerce/solrserver/resources/solr/server/solr/ && \           
    mv -v ./config/tomcat/conf/server.xml \
       ./config/tomcat/conf/server.xml.local && \
    mv -v ./config/tomcat/conf/server.xml.remote \
       ./config/tomcat/conf/server.xml

RUN cd ./bin/platform && \
     . ./setantenv.sh && \
     ant customize && \
     ant clean all

COPY ./docker_db_update.local.properties /opt/hybris/config/local.properties
RUN cp -fv ./config/tomcat/conf/wrapper-debug.conf ./config/tomcat/conf/wrapper.conf && \
    cp -v ./config/environments/local_tenant_junit.properties /opt/hybris/config/local_tenant_junit.properties

RUN cd ./bin/platform && \
    . ./setantenv.sh && \
    ant deploy

EXPOSE 80
EXPOSE 443
EXPOSE 9002

USER root

COPY ./docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/bin/bash"]
