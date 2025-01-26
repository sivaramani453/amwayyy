FROM python:slim

RUN apt-get update \
    && apt install -y curl jq \
    && apt-get clean
    
RUN pip install awscli

COPY app/run.sh /
ENTRYPOINT ["/run.sh"]
