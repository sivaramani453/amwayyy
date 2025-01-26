1. If cluster not exist - check the variable cluster-exist is set to 0, else set it to 1

2. Apply terraform code (ensure that you use terraform v.0.13+)

```
terraform init

terraform apply
```

3. Change cluster-exist variable to "1" and retry terraform apply

```
terraform apply
```

4. Apply letsencrypt yaml

```
kubectl apply letsencrypt-issuer.yaml
```

5. Install two nginx-ingress controllers (internal and internet-facing, use helm v.3)
```
cd nginx-ingress;
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx -f values-public.yml -n ingress-nginx --create-namespace ingress-nginx/ingress-nginx
helm install ingress-nginx-internal iingress-nginx/ingress-nginx -f values-internal.yml -n ingress-nginx
```
5. Install Rancher (use helm v.3)

```
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher3.hybris.eia.amway.net --set ingress.tls.source=letsEncrypt
```
