# Middleware for CI/CD

This middleware captures webhook from Github - when PR is labelled. Then, based on those labels, it triggers proper workflows, that runs tests.

## Requirements

* docker

For my PC it was enough to type: <pre>DOCKER_HOST=unix:///var/run/docker.sock</pre> before running make, as I have Docker Desktop and WSL

## Setting up

* cd src; make build; make deploy; make install
* terraform apply
* paste secret (used for signing request content) and webhook URL to Github Actions
