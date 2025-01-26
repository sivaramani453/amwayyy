# Setup CICD For A Project

To deploy a project, we recommend (after the testing/development phase) to execute this via CI/CD, and strongly encourage usage of GitHub Actions.

We have provided a reusable workflow that will execute the 3 stages of our example Makefiles (`init`, `plan` or `destroy`, `apply`). We heavily recommend using the same approach we have used in order to benefit from the existing structure.

With this reusable workflow, your GitHub Workflow will need to tell the job where the stack or project lives and which IAM role to assume. Our code will handle the rest!

## TL;DR

Ok so let's deploy our project `foo`. First, create: `.github/workflows/foo-deploy.yml`:

```
name: Foo - deploy

on:
  workflow_dispatch: {}

## The permissions are important here, as they will allow the OIDC connection with AWS
permissions:
  id-token: write
  contents: read

jobs:
  cluster_infra:
    uses: AmwayCommon/jp-cicd-workflows/.github/workflows/aws-iac-deploy.yml@main
    with:
      project_dir: projects/foo/stacks/main
      iam_role: arn:aws:iam:....
```


## Guiding Principles

- Do use the reusable workflows written by the DevOps team, the will make your life easier
- We encourage using the same kind of structures we discussed in [new-project.md](new-project.md), including the Makefiles, so that the reusable workflows will function properly

That's it overall...
