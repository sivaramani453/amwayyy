1. Apply terraform code (ensure that you use terraform v.0.13+)

```
terraform init

terraform apply
```

2. Apply letsencrypt yaml

```
kubectl apply letsencrypt-issuer.yaml
```

3. Install Rancher (use helm v.3)

```
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=rancher3.ru.eia.amway.net --set ingress.tls.source=letsEncrypt
```

4. Install two nginx-ingress controllers (internal and internet-facing)
```
cd nginx-ingress;
helm install ingress-nginx -f values_public.yml -n ingress-nginx --create-namespace ingress-nginx/ingress-nginx
helm install ingress-nginx-internal -f values_internal.yml -n ingress-nginx
```

