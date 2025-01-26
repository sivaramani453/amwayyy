.DEFAULT_GOAL:=help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: init plan apply refresh destroy

##@ Terraform. All actions except `init` require a vars.tfvars file
init: ## Initialize the modules, provider, etc
	terraform init
refresh: ## Refresh the modules, useful when they're stored in git
	terraform plan -var-file=../../vars.tfvars -refresh-only -out .terraform.plan
plan: ## Make a terraform plan and save to .terraform.plan
	terraform plan -var-file=../../vars.tfvars -out .terraform.plan
apply: ## Apply .terraform.plan
	terraform apply .terraform.plan
destroy: ## Make a plan to destroy everything
	terraform plan -var-file=../../vars.tfvars -out .terraform.plan -destroy
