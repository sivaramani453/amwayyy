# Template for hybris CloudFront CDN (migration from akamai)

Template contains 6 vars should be set and workspace for specific envs:
*    Hybris domain to route all traffic to        - ```hybris_domain```
*    Short name of hybris domain (without 'www')  - ```hybris_domain_short```
*    Hybris backend ALB cluster domain name       - ```hybris_alb```
*    Prerender domain to route bot traffic to     - ```prerender_host```
*    Authorization header value for backend ALB   - ```custom_header```
*    ACM certificate ARN for distribution aliases - ```certificate_arn```
*    Workspace is used as suffics for Lambda names etc.

tfvars file example:
```
hybris_domain    = "www.fqa.amway.ru"
hybris_domain_short  = "fqa.amway.ru"
hybris_alb       = "gat8b65a1d384afe8846e220d5e9e246-2982933f23d30d92.elb.eu-central-1.amazonaws.com"
prerender_host   = "prerender-uat.ru.eia.amway.net"
custom_header    = "CF_NFT-some-token"
certificate_arn  = "arn:aws:acm:us-east-1:645993801158:certificate/2d4e15ab-77d8-4a80-a7a6-7fd830761f8a"
```

All existing envs/workspaces vars are placed in named .tfvars files. File names are matched workspace name.
To redeploy existing workspace just switch to it and copy ```<workspace>.tfvars``` to ```terraform.tfvars```
