## EKS based  Kubernetes cluster
This directory represents full dev and qa **kubernets solution**
This means it includes:
  * New separate VPC with it's own CIDR block and VPN connection to Amway network (*core* dir)
  * EKS cluster with custom asg configured in backend (*eks* dir)
  * Instance profiles to attach to workers (*iam* dir, deprecated)
  * Custom load balancers to support ingress-nginx contraoller (*nlb* dir)
  * EFS filesystem for address-validation microservice (*efs* dir)
  * Ext terraform modules for eks cluster (*modules* dir)

### Deploy
The idea behind deploy process is to isolate each component listed above. 
We must apply terraform playbooks in a strict order, since they depend on each other through the output values.
  1. VPC for cluster. VPN is included in the playbooks
  2. NLBs. NLB target groups are used to attach to asg.
  3. EKS cluster.
  4. EFS filesystems.
  5. IAM profiles, deprecated.
