### Create PR from PROD branch to DEV branches
#### Installation
  * Go to src dir
  * make build
  * make install

You will see log.zip file in ./src/ dir
Now you are ready for terraform apply

### Usage
You have to provide the following variables while terraform apply:
 * bot_secret - secret for skype bot
 * channel - channel for skype bot
 * github_api_token - Github API Token with full access (vault)
 * stream - 'ru' or 'eu'
 * code_repo - repository with hybris code (lynx or lynx-ru)
 * config_repo - repository with hybris config (lynx-config or lynx-ru-config)
 * sha_lynx - Last commit sha in prod branch of hybris code (lynx or lynx-ru).
   Will be written within parameter store record.
 * sha_lynx_conf - Last commit sha in prod branch of hybris config (lynx-config or lynx-ru-config).
   Will be written within parameter store record.
 * branches - Commaseparated list of branches that should be updated
   (for RU: support-rel,support-hotfix,support-dev,dev-dev,dev-rel  for EU: support-dev,dev-dev,dev-rel)

### TF STATES
 * create-pr-from-prod-eu.tfstate - for EU
 * create-pr-from-prod-ru.tfstate - for RU