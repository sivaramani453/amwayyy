# Create A New Project Or Stack

Projects and Stacks are a little bit more freeform than bases and components. This HOWTO will try to expose two different ways of organizing projects and stacks, that have already been in use as of 2023-09-15.

## TL;DR (stacks as parts of the whole project)

    templates/eks-template shows a good example of this type of project.


## TL;DR (stacks as environments)

    templates/simple-project shows a good example of this type of project.

## Guiding Principles

- Secret values should be stored in a separate `secrets.tfvars` file; this file is *never* checked in to git
- However, it's useful to add a `secrets.example.tfvars` file or similar one, with dummy values, to show prospective users how to use the file
- Some future HOWTO will explain how to populate `secrets.tfvars` dynamically using GitHub Secrets in GitHub Actions
- Definitely *do* include `providers.tf`, `versions.tf` (optional but recommended), `backend.tf`; *this* is where the actual deploy environment is defined, at the project level
- Otherwise, `projects` are very much more freeform than `bases` or `components`
- In the case of *simple* deployments (such as `projects/jp-acsd-bnc-training-data`), we recommend using a single project; each `stack` would represent an environment, such as UAT or Prod
- In the case of more complex deployments (such as `projects/automation-cluster-dev`), we recommend using `stacks` to subdivide the infrastructure into discrete parts that can be deployed separately (though of course there are dependencies between each stack, an order to deploy); in this case, each environment would consist of a wholly separate project, e.g. `projects/automation-cluster-prod`
- In complex deployments, we recommend having all common variables at the root of the project, e.g. `projects/automation-cluster-dev/vars.tfvars`; these variables are used in all or most of the stacks, so defining them once is a good strategy
- Use one or more `Makefile` as a simple task runner
- Use the `templates` folder to help start more quickly
- Pay special close attention to how the backends are defined; the recommended way (for AWS) is shown in the `projects/automation-cluster/cluster-infra/provider.tf` file, and is also explained in [iam-setup.md](../explanations/iam-setup.md)

## File Hierarchy

We recommend keeping shared files at the root of your project, e.g. a shared `vars.tfvars` file or a `Makefile` that orchestrate each stack one by one.

We recommend separating your project into multiple `stacks`: e.g., one stack will create the basic infra, the other stack will create other resources that are built on top of that basic infra; this way, future updates to the stacks will be quicker (fewer resources to analyze and update) and the 'blast radius' of any accidental deletion of resources will be minimized to a particular stack.

Finally, we have so far 2 different types of projects:
 - the first type where a whole project is made of multiple stacks; in this case, we recommend creating one `project` for every environment (e.g. one project for prod, one project for uat, etc). Since each will use the same bases, generally, the code is reused and because each environment is a separate project it's easier to reason about each one.
 - the second type is a simpler project type where each environment is a `stack` inside the `project`. This helps reduce a bit the clutter of the `projects/` directory.

## Project Or Stack Files

- `Makefile`, since `make` is a useful task runner and dependency manager
- `provider.tf` to configure the S3 backend and other providers
- `main.tf` where other modules are called; *NOTE*: these modules must be `bases`, do not call `components` directly; any orchestration of different `components` is handled inside the `bases`

Other than that, organize your project as you see fit. We provide 2 different templates to show our current ideal/proposed structures.
