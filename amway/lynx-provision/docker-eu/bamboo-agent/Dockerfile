FROM atlassian/bamboo-agent-base:6.6.3

USER root

RUN apt-get -qq update && \
    apt-get -qq install -y \
        curl \
        python \
        python-pip \
        python3-pip \
        git \
        openssl \
        jq \
        zip \
        unzip \
        groff \
        p7zip \
        mysql-client \
        sudo && \
    pip install ansible==2.9.22 && \
    pip3 install --upgrade pip awscli docker boto3 && \
    echo "DOCKER LIB installed" && \
    pip install awscli --upgrade --quiet && \
    pip install boto3 && \
    pip install PyGithub==1.43.7 && \
    pip install shaper && \
    pip install boto && \
    pip install zabbix-api && \
    ln -sf bash /bin/sh && \
    apt-get clean && \
    rm /var/lib/apt/lists/*.*

RUN openssl s_client -connect amway-prod.tt.com.pl:443 < /dev/null | sed -ne "/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p" > public.crt; \
    printf "changeit\nyes" | /usr/lib/jvm/java-8-openjdk-amd64/bin/keytool -import -alias amway-prod.tt.com.pl_2018 -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts -file public.crt

ADD files/10-bamboo-user /etc/sudoers.d/
ADD files/init_bamboo_agent.sh /etc/init.d/
ADD files/bamboo-agent.cfg.xml /home/bamboo/bamboo-agent-home/
RUN chmod 0440 /etc/sudoers.d/10-bamboo-user && \
    chmod +x /etc/init.d/init_bamboo_agent.sh && \
    chown -R ${BAMBOO_USER}:${BAMBOO_USER} /home/bamboo/

USER ${BAMBOO_USER}

RUN ansible-galaxy collection install community.mysql

RUN wget --no-dns-cache --retry-connrefused --continue --tries=5 --timeout=60 --no-verbose https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_linux_amd64.zip && \
    unzip packer_1.7.2_linux_amd64.zip && \
    rm -f packer_1.7.2_linux_amd64.zip && \
    sudo rm -rf /usr/sbin/packer && \
    wget --no-dns-cache --retry-connrefused --continue --tries=5 --timeout=60 --no-verbose https://releases.hashicorp.com/terraform/0.11.15/terraform_0.11.15_linux_amd64.zip && \
    unzip terraform_0.11.15_linux_amd64.zip && \
    rm -f terraform_0.11.15_linux_amd64.zip && \
    wget --no-dns-cache --retry-connrefused --continue --tries=5 --timeout=60 --no-verbose https://releases.hashicorp.com/vault/1.6.4/vault_1.6.4_linux_amd64.zip && \
    unzip ./vault_*.zip && \
    rm -f ./vault_*.zip && \
    wget --no-dns-cache --retry-connrefused --continue --tries=5 --timeout=60 --no-verbose https://releases.hashicorp.com/terraform/0.12.31/terraform_0.12.31_linux_amd64.zip && \
    unzip terraform_0.12.31_linux_amd64.zip -d /tmp && \
    mv /tmp/terraform ./terraform12 && \
    rm -f terraform_0.12.31_linux_amd64.zip && \
    echo 'export PATH="$PATH:/home/bamboo/"' >> ~/.bashrc

ENV PATH="${PATH}:/home/bamboo"
ENV VM_OPTS="-Xms512m -Xmx1024m"

ENTRYPOINT ["/etc/init.d/init_bamboo_agent.sh"]
