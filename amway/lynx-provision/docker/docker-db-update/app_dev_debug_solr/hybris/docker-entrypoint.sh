#!/bin/bash
#
# docker-entrypoint for docker-hybris

set -e

if [[ "$VERBOSE" = "yes" ]]; then
    set -x
fi


# If the media directory is bind mounted then chwon it
if [[ "$(stat -c %u /opt/media/sys_master)" != "$(id -u hybris)" ]]; then
    chown -R hybris:hybris /opt/media
fi

echo "Run ant updatesystem"
runuser -l hybris -c'
         cd /opt/hybris/bin/platform; \
         . ./setantenv.sh; \
         ant importImpex -Dresource=/opt/hybris/solr-configuration.impex; \
         ant updatesystem -Dde.hybris.platform.ant.production.skip.build=true \
         -Dde.hybris.platform.ant.production.skip.server=true \
         -DconfigFile=/opt/hybris/bin/custom/lynxeubasestore/resources/updatesystem-configuration.json' >> /opt/hybris/log/tomcat/ant_update.log 2>&1

echo "Launch Hybris"
runuser -l hybris -c'
         cd /opt/hybris/bin/platform; \
         . ./setantenv.sh; \
         ./hybrisserver.sh run'

# run the command given as arguments from CMD
exec "$@"
