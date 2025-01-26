.DEFAULT_GOAL:=help

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make STACK=stack-name \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: init plan apply refresh destroy

##@ Terraform. All actions except `init` require a vars.tfvars file
init: ## Initialize the modules, provider, etc for ${STACK}
	make -C stacks/${STACK} init
refresh: ## Refresh the modules, useful when they're stored in git for ${STACK}
	make -C stacks/${STACK} refresh
plan: ## Make a terraform plan and save to .terraform.plan for ${STACK}
	make -C stacks/${STACK} plan
apply: ## Apply .terraform.plan for ${STACK}
	make -C stacks/${STACK} apply
destroy: ## Make a plan to destroy everything for ${STACK}
	make -C stacks/${STACK} destroy

##@ Build all stacks
all: ## Successively init, plan and apply all stacks
	make -C stacks/cluster-infra init plan apply
	make -C stacks/cluster-network init plan apply
	make -C stacks/cluster-addons init plan apply
