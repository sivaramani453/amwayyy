## Zabbix Host discovery
Lambda function to discover aws objects within current account and upload them to zabbix via API.
#### How it works
* Lambda function executes describe instances API call
* Filters instances by "zabbix=true" tag and state running
* Parsing zabbix_templates and zabbix_groups tags. (splitting by comma, deletes empty values, trims every item. )
* Searches if host with the same name already present in zabbix:
  * If yes - cheks diff in templates, groups and state. Update host if values mismatch
  * If no - just skip this host
* Searches specified templates in zabbix. (If no templates specified, OS Linux template is used)
* Searches specified groups in Zabbix. (If groups not specified, default group used, if group not found, lambda will create new group)
* Creates host in discovered/created groups with discovered templates
* Searchs if there are hosts in zabbix left that are not present in aws anymore. Based on env var *WHEN_MISSING* value such hosts will be ignored/disabled/deleted

### Installation
```sh
# first build src code
make build
# prepare archive and push it to the almbda s3 bucket
make install
# deploy
terraform apply
```
### To DO
* add zabbix_port tag support to allow non standart port use
