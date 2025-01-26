FROM atlassian/bamboo-agent-base:6.6.3

USER root

RUN apt-get update && \
    apt-get install -y \
        curl \
        python3-pip \
        git \
        openssl \
        jq \
        sudo && \
    pip3 install --upgrade pip awscli docker && \
    apt-get clean && \
    rm /var/lib/apt/lists/*.*

RUN ( curl -sL https://deb.nodesource.com/setup_12.x | bash - ) && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm /var/lib/apt/lists/*.*

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome-stable.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    apt-get clean && \
    rm /var/lib/apt/lists/*.*

ENV CHROME_BIN=/usr/bin/google-chrome

RUN openssl s_client -connect amway-prod.tt.com.pl:443 < /dev/null | sed -ne "/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p" > public.crt
RUN printf "changeit\nyes" | /usr/lib/jvm/java-8-openjdk-amd64/bin/keytool -import -alias amway-prod.tt.com.pl_2018 -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts -file public.crt

ADD files/10-bamboo-user /etc/sudoers.d/

ADD files/init_bamboo_agent.sh /etc/init.d/
RUN chmod +x /etc/init.d/init_bamboo_agent.sh 

ADD files/bamboo-agent.cfg.xml /home/bamboo/bamboo-agent-home/
ADD files/config /home/bamboo/.aws/
RUN chown -R ${BAMBOO_USER}:${BAMBOO_USER} /home/bamboo/

USER ${BAMBOO_USER}

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
RUN echo "[default] \n\
aws_access_key_id = $AWS_ACCESS_KEY_ID \n\
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" > /home/bamboo/.aws/credentials

ENTRYPOINT ["/etc/init.d/init_bamboo_agent.sh"]
