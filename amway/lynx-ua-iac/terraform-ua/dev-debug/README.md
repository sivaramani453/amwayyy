```terraform init -backend-config="key=dev-debug/${bamboo.ManualBuildTriggerReason.userName}.tfstate"```

```terraform destroy --auto-approve -var 'instance_name=${bamboo.ManualBuildTriggerReason.userName}' -var-file=russia-r1.tfvars```

```terraform apply --auto-approve -var 'instance_name=${bamboo.ManualBuildTriggerReason.userName}' -var-file=russia-r1.tfvars```

where 

```${bamboo.ManualBuildTriggerReason.userName}``` - User Login

```russia-r1.tfvars``` - Project's stream specific variables