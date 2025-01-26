# Polylith

An overview has been presented here in Confluence:
https://amwaycloud.atlassian.net/wiki/spaces/PEO/blog/2023/08/16/275554377/Pat+s+Brain+Polylith+as+applied+to+Terraform

## What is Polylith?

Polylith is an architecture for a monorepo. It provides concepts to organize codes into different "bricks", aka pieces of code that are assembled together (like Lego bricks) to form a codebase.

The main goal of Polylith is to allow the use of monorepos for multiple projects, while staying sane, allowing sharing of code and components, different implementations, different ways of deploying the artifacts.

## Bricks

### Components

The basic brick type is a component - a self-contained set of functions (or, in our case, terraform configs) that is agnostic to its environment or deployment. These define basic building blocks of our inrastructure: an EKS cluster, an IAM role, a Route 53 record, etc.

Nothing in a component is hard-coded - the name can be anything, it could be deployed to any AWS region or account, etc.

### Bases

Bases are here to orchestrate multiple components. They have more "opinions" about where things go and how they are named, and overall a base presents a whole piece of infrastructure - an EKS cluster, for example, or a set of Helm charts and their configs to transform a bare Kubernetes cluster into an Automation platform.

A base is still not expected to have all the details - e.g., it will receive a lot of input variables concerning specific permissions, ingress/egress CIDRs, cluster names, AWS providers, and so on. However it can make use of these input variables to parameterize components.

### Projects and Stacks

Finally, the highest level building block in Polylith is called a Project. Generally, a project contains build files and scripts that help create a deployable artifact of a program or service. Makefiles, Dockerfiles, pom.xml, etc.

In the case of Terraform, our "deployable artifact" is the intfrastructure itself. This is where the input variables for the bases are defined, this is where the Terraform providers are configured, and where the bases are put together to create the complete infra.

This allows us to define one project for each infra/cluster we want to deploy; for each environment. For example, an automation non-prod cluster is one project, and the automation-prod cluster would be another project. Each makes use of the same bases, but they are configured slightly differently due to different AWS accounts, naming requirements, access control, and so on.

Using projets in this way makes explicit what we have deployed and where, and how they are configured.

Additionally, to help prevent some potential pitfalls when using terraform (e.g. accidentally deleting a whole cluster if all you want is to change a name of some components...), we have decided to separate projects into multiple Stacks. Each stack represents a specific stage of the infra build-up, e.g.:

 - cluster-infra: build the EKS cluster, IAM roles, Security Groups
 - cluster-network: deploy the ingress controller, DNS records
 - cluster-addons: deploy "add-ons", in other words software running *inside* Kubernetes that will provide additional functionality: Prometheus exporter, linkerd service mesh, autoscaler, etc
