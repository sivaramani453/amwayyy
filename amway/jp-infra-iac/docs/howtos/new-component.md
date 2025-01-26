# Create A New Component

## TL;DR

Let's say we want to create a component `foo` to deploy a security group.

First, create the directory and files:

```
mkdir components/foo
cd components/foo
touch {main,variables}.tf
```

Now edit the files as required to create the resource.

Read on for details

## Guiding Principles

- A `component` should have a single responsibility
- For example, create ONE IAM role, deploy one application using one or more helm charts, deploy one cluster
- Generally, components should not refer to each other directly; rather, in the `base`,  call each component and pass the required outputs of one component to another component
- Doing the above allows to specify dependencies based on each base's needs, and allows swapping different components with each other where required
- Some components are slightly more complex and create multiple resources, e.g. the `linkerd` addon or the `eks` component; this is fine as long as all the different resources are tightly coupled and can be considered as a single unit (such is the case for an EKS cluster, such is the case for linkerd)
- A component is independent of any specific Kubernetes cluster or AWS account/region; the component does not contain any configuration regarding these and is strictly concerned with defining the resources
- Components should not hardcode any specific value, e.g. anything related to a project, AWS account, Kubernetes cluster name, team member or group name. These should be configured via variables; while there may be exceptions, it is better to think of components first as generic modules.

## File Hierarchy

All `components` live under the `components/` directory. Under the directory, we have 2 levels:

- directly under `components/` are regular components, most commonly any AWS resource
- then we have the `components/k8s-addons` directory, which is used for add-ons to install inside a Kubernetes cluster

This way we hope to clearly separate what is *infrastructure* and what runs *inside kubernetes*.

## Component Files

While `terraform` doesn't enforce any set files, there are general conventions and we use similar ones, and have a few extra of our own:

- `main.tf` contains the general code of the component; so far we have not encountered components needing anything extra since components have a single responsibility
- `variables.tf` contains the input variables definitions
- `outputs.tf` if any output is required, define them here
- `resources/` this folder contains any non-terraform resources such as a Helm chart's `values.yml`

Note: we do not define `backend.tf`, `provider.tf` or `versions.tf`; all backends, providers and terraform/provider versions are defined in the project/stack or in the base. Components are meant to be abstract enough that they are not tied to any individual AWS account/region, or Kubernetes cluster.

Note: there could be an argument made to define minimum required terraform or provider versions in `versions.tf` to avoid issues in the future...

## How To Reference Resources

Resources inside a module can be referenced this way:

```
templatefile("${path.module}/resources/values.yaml", ...)
```

e.g. if the statement above is in `components/k8s-addons/ingress/main.tf`, it will look for this file: `components/k8s-addons/ingress/resources/values.yaml`

Resources that should be part of a project can be referenced this way, where the default base path is the project's stack bath (e.g. `projects/automation-cluster-dev/stacks/cluster-network/`):
```
templatefile("resources/values.yaml", ...)
```

e.g. if this statement appears in a component called from a base called from `projects/automation-cluster-dev/stacks/cluster-infra/`, then terraform will look for the file: `projects/automation-cluster-dev/stacks/cluster-infra/resources/values.yaml` -- no matter where the statement appears, no matter which component files it appears in.

