FROM ghcr.io/actions/actions-runner:latest
LABEL maintainer="Patrice LaFlamme <patrice_laflamme@amway.com>"

USER root

RUN apt update && apt install -y git curl wget zip unzip maven jq gawk make && \
    apt-get clean
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
          && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
          && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
          && apt update \
          && apt install gh -y \
          && apt-get clean          
USER runner
