FROM centos:7

# Github runner
ARG GITHUB_RUNNER_VERSION="2.273.5"
ARG DOCKER_MACHINE_URL="https://github.com/docker/machine/releases/download/v0.16.0/docker-machine-Linux-x86_64"
ARG SONAR_SCANNER_VERSION="4.4.0.2170"
ARG DOCKERVERSION=18.06.3-ce

ENV RUNNER_NAME "runner"
ENV GIT_REPO ""
ENV GIT_TOKEN ""
ENV RUNNER_WORKDIR "_work"
ENV PATH="/opt/sonar-scanner/bin:${PATH}"

# Helm
ENV HELM_VERSION="v2.14.3"
ENV HELM_DOWNLOAD_LINK="https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz"

# Deps
RUN yum install -y epel-release \
    && yum clean all

# Install required tools
RUN yum install -y sudo curl git jq zip unzip \
                   openssl openssl-libs \
                   lttng-ust lttng-ust \
                   krb5-libs zlib libicu \
                   krb5-libs wget python-requests \
                   ShellCheck pylint python3 \
    && yum clean all \
    && useradd -m github \
    && usermod -aG wheel github \
    && echo "%wheel ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install pip3 packages
RUN pip3 install awscli ansible hvac docker pyyaml boto boto3 botocore

# Install docker machine
RUN curl -L $DOCKER_MACHINE_URL  > /tmp/docker-machine \
    && mv /tmp/docker-machine /usr/local/bin/docker-machine \
    && chmod +x /usr/local/bin/docker-machine

# Install docker cli
RUN curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
    && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /usr/local/bin docker/docker \
    && rm docker-${DOCKERVERSION}.tgz

# Sonar scanner
RUN curl -L "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-linux.zip" > /tmp/sonar-linux.zip \
    && unzip -qq /tmp/sonar-linux.zip -d /opt \
    && ln -s /opt/sonar-scanner-$SONAR_SCANNER_VERSION-linux /opt/sonar-scanner \
    && rm -rf /tmp/sonar-linux.zip

# Helm
RUN wget -q $HELM_DOWNLOAD_LINK -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

# Nodejs
RUN curl -sL https://rpm.nodesource.com/setup_12.x | bash - \
    && yum install -y nodejs \
    && yum clean all

# Hashicorap
RUN wget -q https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip -O terraform.zip \
    && unzip -qq terraform.zip \
    && mv terraform /usr/local/bin \
    && chmod +x /usr/local/bin/terraform \
    && rm -f terraform.zip

RUN wget -q https://releases.hashicorp.com/vault/1.1.3/vault_1.1.3_linux_amd64.zip -O vault.zip \
    && unzip -qq vault.zip \
    && mv vault /usr/local/bin \
    && chmod +x /usr/local/bin/vault \
    && rm -f vault.zip

# Github runner
USER github
WORKDIR /home/github

RUN curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz
COPY --chown=github:github app/entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

# We need init helm and install plugins as git user
RUN helm init --client-only \
    && helm plugin install --version 0.7.1 https://github.com/chartmuseum/helm-push \
    && helm plugin install https://github.com/instrumenta/helm-kubeval

ENTRYPOINT ["/home/github/entrypoint.sh"]
