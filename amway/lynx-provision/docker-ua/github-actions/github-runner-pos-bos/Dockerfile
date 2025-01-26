FROM ubuntu

# Github runner
ARG GITHUB_RUNNER_VERSION="2.267.1"
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Europe/Moscow

# Env vars
ENV RUNNER_WORKDIR "_work"
ENV CHROME_BIN=/usr/bin/google-chrome

# Deps
RUN apt-get update \
    && apt-get install -y sudo curl jq git wget \
                          python3-pip openssl \
                          libicu66 libssl1.1 liblttng-ust0 \
                          libkrb5-3 zlib1g python \
    && pip3 install --upgrade pip awscli docker \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*.*

# Create user
RUN  useradd -m github \
    && usermod -aG root github \
    && echo "%root ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Nodejs
RUN ( curl -sL https://deb.nodesource.com/setup_12.x | bash - ) \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*.*

# Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome-stable.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && apt-get clean \
    && rm /var/lib/apt/lists/*.*
    
# Github runner
USER github
WORKDIR /home/github

RUN curl -Ls https://github.com/actions/runner/releases/download/v${GITHUB_RUNNER_VERSION}/actions-runner-linux-x64-${GITHUB_RUNNER_VERSION}.tar.gz | tar xz
COPY --chown=github:github app/entrypoint.sh ./entrypoint.sh
RUN sudo chmod u+x ./entrypoint.sh

ENTRYPOINT ["/home/github/entrypoint.sh"]
