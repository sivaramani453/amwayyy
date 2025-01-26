# AWEU Terraform Vault Setup

- This setup uses only AWS services, so there are no external dependencies or backends to manage
- HA Storage via DynamoDB easily handles node failures
- The S3 storage backend is simple and reliable
- Versioning on the S3 buckets allows for secret recovery (with some limitations)
- S3 and DynamoDB scale with usage, meaning cost is automatically optimized
- The ALB will only route to a healthy Vault primary node, preventing unnecessary redirects
- AWS KMS service allows auto unseal operation for Vault cluster
- Also the Packer pre-baked AMIs allows for simple live Vault upgrades

## Getting started
Clone https://github.com/AmwayACS/lynx-iac repository, go to ./terraform-eu/vault directory
Run `terraform init`, then create a new terraform workspace by executing command `terraform workspace new name_of_the_workspace` and `terraform apply`. We use terraform workspace name as name of the vault cluster. For more details, please check source code.

Next you must initialize Vault on one of the nodes.
Temporarily attach an SSH security group to all Vault instances, SSH in, and become root.
Execute `export VAULT_ADDR="http://127.0.0.1:9200"`
After this perform `vault operator init`, it will print unsealed keys and also root token for initial setup.
Copy all of the recovery keys and the root key locally and then to the correct folders in S3 Vault resource bucket using the CLI.

Clear your history and exit

```bash
cat /dev/null > ~/.bash_history && history -c && exit
```
Remove the temporary SSH security group

## Vault configuration
On your local machine add to your environment variables `VAULT_ADDR` with value you have set in `lb_dns_name` and login into vault with root token:
``` bash
 vault login
 ```
> The default auth method is "token". If not supplied via the CLI,
  Vault will prompt for input. If the argument is "-", the values are read
  from stdin.

Upload vault administration policy, which could be found under ./terraform/vault/files
```bash
vault policy write admin vault-admin-policy.hcl
```
After this enable authorization with GitHub personal access token.
```bash
vault auth enable github
vault write auth/github/config organization=AmwayACS
vault write auth/github/map/teams/epam-vault-admin value=admin
```
Now you can login into vault with GitHub personal access token and make further configuration. e.g,enable key value storage
```bash
vault secrets enable -path=amway kv-v2
```
More information about key value secret storage in vault and authorization with GitHub could be found under: https://amway-prod.tt.com.pl/confluence/display/AMWEIA/Vault+secrets+management+tool

## Upgrading Vault
We use pre-baked AMIs builded with Packer.  
Packer configuration and Ansible role for Vault could be found under: https://github.com/AmwayACS/lynx-provision

The Packer builder uses Ansible to provision the AMI, it installs Vault securely, following all relevant recommendations in Hashicorp's [Production Hardening](https://www.vaultproject.io/guides/production.html) guide. Namely, it creates a Vault service user, installs Vault with a verified checksum, creates the necessary files/folders, and adds a Vault systemd service.

The Packer builder also exports a global `VAULT ADDR` at `127.0.0.1:9200`, which is used as a local only listener in the Vault configuration.

Vault can be upgraded by manually modifying `vault_version` and `vault_version_checksum` to match the newest version. Then simply rebuild the Packer image  and `terraform apply`.

## Overview

### Application Load Balancer
An Application Load Balancer routes traffic to only the Vault primary node, based on a health check. SSL offloading is performed at ALB level. This done because we would like AWS to manage all certificate operation. Security groups restrict access to the Vault instances to only the ALB, which should be the only method of accessing Vault.

We also enable a localhost listener directly on the node so that the root user can access Vault normally in case of emergency. Since this listener is insecure it is on a special port and only accessible from the node itself. Access to the Vault nodes should be carefully controlled, even though access to the node does not imply access to secrets.

### S3 Storage Backend

We use S3 as the backend because it is simple to set up and secure, and also because we can use Terraform to manage bucket policies and IAM instance profiles to manage read/write access.

### S3 Resources Bucket

We use a second S3 bucket to store all Vault resources.

### DynamoDB HA Backend

S3 does not support locking and therefore cannot manage an HA Vault setup. However we can use DynamoDB with the [ha_storage](https://www.vaultproject.io/docs/configuration/index.html#ha_storage) option to manage HA and still use S3 as the storage backend. With the proper IAM permissions Vault can manage the Dynamo table on its own, and since we only use it for HA coordination, the table can be provisioned with minimal cost.

### Automated Unsealing
Using AWS KMS method 'unseal keys' are now 'recovery keys' and unseals will happen
automatically with the correct KMS key, permissions, and seal stanza.
