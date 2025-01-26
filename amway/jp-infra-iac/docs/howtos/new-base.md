# Create A New Base

## TL;DR

Let's say we want to create a base called `bar-cluster`:

```
mkdir bases/bar-cluster
cd bases/bar-cluster
touch {main,variables,outputs}.tf
```

Then edit the files as required.

e.g., to make use of the `foo` component, in `main.tf`:

```
module "foo" {
  source "../../components/foo"
  
  var1 = var.var1
  ...
}
```

## Guiding Principles

- Generally speaking, there is one base per `project` or `stack`; this however does mean that bases can be shared, e.g. if the same project or stack has multiple environments (prod, QA, etc)
- We are also striving to offer some 'generic' bases, such as `simple-ingress`, `common-addons` and `generic-eks-cluster` that can be used out of the box for many projects
- Bases do not configure providers (AWS account/region, Kubernetes cluster, credentials, etc)
- They may however define extra providers where required (see for example `bases/generic-eks-cluster`); this is useful when multiple AWS accounts or regions are involved
- Bases also do not configure backends (such as s3, terraform cloud)
- Similarly to components, a `base` should not hardcode any project name or credential; bases can be used however to make component resource names more specific, for example if creating a security group for an EKS cluster to allow VPN access, you can call the `security-group` component with an input variable like: `${project_name}-eks-vpn-access`
- Bases should not directly create `resources` in terraform: that's the responsibility of the components
- Instead, bases should call out to `components` using `module` blocks
- Bases can use multiple modules (`components`) and are used to "orchestrate" these `components` together, with dependencies, some configurations

## File Hierarchy

A `base` lives under the `bases/` directory, as shown above in the TL;DR section. It's expected to be a flat structure (unlike `components/`), and usually won't need a `resources/` subdirectory since all the "logic" is handled by `components`.

## Base Files

- `main.tf` is the main file containing the code of the `base`
- `variables.tf` defines input variables; it is recommended to make these detailed, with descriptions and types, as they are the main "entrypoint" or "interface" for all the components required by a base
- `outputs.tf` defines a base's outputs
