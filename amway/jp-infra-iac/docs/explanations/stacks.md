# Stacks

## Stacks vs Projects

`Stacks` are a new brick type we have added to the usual Polylith architecture. While we don't consider stacks to be worthy of a whole new brick category, we felt we needed an extra level of abstraction/separation of concerns.

There are 2 reasons we added stacks to the Polylith bricks, as subsets of project bricks, is due to how Terraform works and functions, and due to recommendations from HashiCorp themselves:

### Resource and provider dependencies

 - Some resources, like Kubernetes clusters are created
 - Later on, we need to use said resources in provider configurations (e.g. configuring a Helm provider with the newly-created EKS cluster)

This can lead to a situation where the Kubernetes provider canNOT be initialized because the Kubernetes cluster itself does not exist yet! There are a few hacky ways to work around this, but following experimentation and many frustrating hours, we have decided to follow the more traditional approach, which also gives us a second benefit as follows.

### Protection against unintentional deletion of resources

Terraform itself, and the providers, can sometimes act in, not random or arbitrary, but unexpected ways. Sometimes, changing the name of a resource will require deletion of said resource and a rebuild. Imagine if you change an input variable, which ends up renaming an EKS cluster, when all you wanted was to update its name and deploy a new Helm chart.

Now that your cluster is gone, the Kubernetes/Helm providers are no longer configured properly, and your Helm deploy is gone. And as a "bonus", the rest of what you had deployed is gone as well.

As per recommendations from HashiCorp and the wider community, it is better to first deploy the cluster and base infrastructure, and then deploy resources on top of these in a separate configuration.

With Polylith, we can accomplish that by creating multiple projects but that could get out of hand, with too many folders directly located inside the `projects` folder, leading to confusion about which of these projects are related and in what order they can be deployed.

Therefore, we have created `stacks`, as subfolders of `projects`, with Makefiles governing their use and ordering. This makes the relations between stacks and projects obvious, explicit, and self-contained. We think that's a win overall for making sense of IaC projects.


## How we organized our Stacks for EKS clusters

    The model below worked well for our EKS cluster deployments. It is not a template that *every* IaC project should follow in this repository; perhaps in some simple-enough projects, stacks might even be unnecessary! For example, both `s3-backend-setup` projects in this repository have a simple flat structure - all they do, after all, is deploy an s3 bucket and dynamodb table. Nothing fancy, no need to separate any concern or layers.
    
In this model, each layer builds upon resources provided in the previous layer. The three layers are as follows:

### cluster-infra: core infrastructure

This stack deploys the EKS cluster itself, as well as a node group, IAM role for the cluster and IRSA, an OIDC provider allowing bridging Kubernetes resources and IAM, and the core security groups used by the cluster's EC2 nodes.

### cluster-network: ingress and DNS, aws-auth

This stack, depends on the cluster-infra stack, accomplishes 2 main goals:

 - configures the aws-auth (for some reason, despite the `terraform-aws-eks` module's claims, it was not possible to set this up at the same time as the cluster, so it is not done separately), which allows the OWNER IAM role (and others, configurable), to have admin access to the EKS cluster
 - configures the subdomain of jp.amway.net or preprod.jp.amway.net that will host all the other hostnames of this EKS cluster, as well as an ingress-nginx ingress controller which launches an NLB
 
### cluster-addons: observability and other basic services

Finally, this stack completes the cluster by deploying maby addons (via Helm) to Kubernetes, such as:
 - prometheus exporter for stats and logs
 - linkerd service mesh
 - cluster autoscaler
 - and many more depending on the tyoe of cluster!
