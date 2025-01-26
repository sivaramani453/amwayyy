## Installation/Removal

Two steps installation is required due to dependancy between modules:
Firstly we need to create VPC and propagate state with values that will be used in eks module.

```
terraform apply --target module.vpc

terraform apply
```

Removal should be done also in two steps: 
As there is no support for dependancy (depends_on) between modules in terraform 0.11 we need to delete modules in necessary order - firstly delete eks that uses values from vpc module and then delete the rest (vpc module)
```
terraform destroy --target module.eks

terraform destroy
```

## Get access to the cluster

User epam.terraform has admin access to the cluster.

```
aws eks --region ${region} update-kubeconfig --name ${cluster_name}
```

By default, the resulting configuration file is created at the default kubeconfig path (.kube/config) in your home directory or merged with an existing kubeconfig at that location. You can specify another path with the --kubeconfig option.

