AWS LoadBalancer controller working setup

https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/installation/

1. Ensure that cluster private networks and public networks has proper labels:
   kubernetes.io/cluster/<cluster-name>: shared
   kubernetes.io/role/internal-elb: 1 (for internal networks)
   kubernetes.io/role/elb: 1 (for internet-facing networks)
2. Get IAM policy and attach to workers IAM role:
   curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.0/docs/install/iam_policy.json
3. Use Helm:
   helm repo add eks https://aws.github.io/eks-charts
   helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=<cluster-name>
