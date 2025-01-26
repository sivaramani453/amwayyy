1. Apply terraform code

```
terraform init

terraform apply
```

2. Provision kubernetes cluster based on output from terraform(IP addresses, S3 keys)

```
rke up --config provision/cluster.yml
```

3. Upload latest cluster state and config to S3
```
aws s3 cp provision/cluster.rkestate s3://amway-prod-rancher-cluster-rke-config/

aws s3 cp provision/kube_config_cluster.yml s3://amway-prod-rancher-cluster-rke-config/
```
4. Install Rancher (Helm and kubectl binaries shouldbe installed on controller machine)

```
kubectl -n kube-system create serviceaccount tiller --kubeconfig provision/kube_config_cluster.yml
kubectl create clusterrolebinding tiller \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:tiller \
  --kubeconfig provision/kube_config_cluster.yml

helm init --service-account tiller --kubeconfig provision/kube_config_cluster.yml

helm install rancher-stable/rancher \
  --name rancher \
  --version 2.2.7 \
  --namespace cattle-system \
  --set privateCA=true \
  --set hostname=rancher.ms.eia.amway.net \
  --set ingress.tls.source=secret \
  --kubeconfig provision/kube_config_cluster.yml
```
5. Upload certificates for Rancher(get files from secret store)
Note: private key should be unencrypted https://github.com/kubernetes/kubernetes/issues/53100

```
kubectl -n cattle-system create secret tls tls-rancher-ingress \
  --cert=rancher.ms.eia.amway.net-Certificate.cer \
  --key=unencrypted-rancher.ms.eia.amway.net-PrivateKey.pem \
  --kubeconfig provision/kube_config_cluster.yml
```
Make sure the file is called cacerts.pem as Rancher uses that filename to configure the CA certificate.
```
kubectl -n cattle-system create secret generic tls-ca \
  --from-file=cacerts.pem \
  --kubeconfig provision/kube_config_cluster.yml
```