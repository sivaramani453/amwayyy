#!/bin/bash
docker run -d --restart=always \
	-p 80:80 -p 443:443 \
	-v $(pwd)/certs/partner.hybris.eia.amway.net-Certificate.cer:/etc/rancher/ssl/cert.pem \
	-v $(pwd)/certs/partner.hybris.eia.amway.net-PrivateKey2.pem:/etc/rancher/ssl/key.pem \
        -v $(pwd)/data:/var/lib/rancher \
	rancher/rancher:latest --no-cacerts
