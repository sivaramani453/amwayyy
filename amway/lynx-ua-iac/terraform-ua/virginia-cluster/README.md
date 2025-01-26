1. Apply terraform code (provide root password for DB when prompted)

 ```
terraform init
terraform apply
```

2. Provision kubernetes cluster based on output from terraform(IP addresses, S3 keys). Populate ```ssh_key_path``` based on your local path for that key

```
rke up --config provision/cluster.yaml
```

3. Upload latest cluster state and config to S3

```
aws s3 cp cluster.rkestate s3://amway-test-virginia-cluster-rke-config/
aws s3 cp kube_config_cluster.yaml s3://amway-test-virginia-cluster-rke-config/
```
