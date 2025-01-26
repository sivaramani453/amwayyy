FROM python:3.6.8

USER root

RUN pip3 install boto3 \
         pyyaml\
         requests

RUN mkdir -p /root/scale_agents
RUN mkdir -p /root/.bamboo

ADD scale_agents/* /root/scale_agents/

ARG BAMBOO_LOGIN=api_user
ARG BAMBOO_PASSWORD
RUN echo "login=$BAMBOO_LOGIN\n\
password=$BAMBOO_PASSWORD" > /root/.bamboo/credentials

ENTRYPOINT ["python3", "/root/scale_agents/scale_agents.py"]
