1. Apply terraform code

```
terraform init

terraform apply
```

2. Create (if not exists) project "chartmuseum" in Rancher local cluster: https://rancher.ms.eia.amway.net/c/local/
3. Create (if not exists) namespace "prod" in project from p.2
4. Launch application "Chartmuseum" in project from p.2 with parameters:
```
name: chartmuseum
namespace: prod (p.3)
template: 1.6.2
```

Press "Edit as YAML" and choose yaml file from provision folder.
Populate this file with necessare parameters:

* STORAGE_AMAZON_BUCKET:  - bucket name from ```terraform output bucket```
* CHART_URL: - domain name from ```terraform output chartmuseum_absolute_url```
* ingress.hosts: - fqdn for ingress, get in from CHART_URL
* AWS_ACCESS_KEY_ID: - get it from tfstate file of this service
* AWS_SECRET_ACCESS_KEY: - get it from tfstate file of this service
* BASIC_AUTH_USER: - username for user that can upload/delete charts (get from secret store)
* BASIC_AUTH_PASS: - password for user that can upload/delete charts (get from secret store)
