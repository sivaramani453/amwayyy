FROM alpine:latest
MAINTAINER George Kakovkin georgii_kakovkin@epam.com

ENV HELM_VERSION="v2.14.3"
ENV HELM_DOWNLOAD_LINK="https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz"

RUN apk add --no-cache ca-certificates bash git openssh curl jq
RUN wget -q $HELM_DOWNLOAD_LINK -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && chmod +x /usr/local/bin/helm
WORKDIR /config

RUN helm init --client-only
RUN helm plugin install --version 0.7.1 https://github.com/chartmuseum/helm-push
RUN helm plugin install https://github.com/instrumenta/helm-kubeval

CMD bash
