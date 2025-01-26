### Vault integration
Plese note that few packer build files contains hashicorep vault
integration. To make things work you should export 2 env vars before run
packer build cmd:
  - *VAULT_ADDR*
  - *VAULT_TOKEN*

Current list of packer files with vault integration:
  - ci-pull-request-agent.json
  - zabbix-server.json (not merged yet :))
