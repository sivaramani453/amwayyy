installCRDs: false

server:
  ingress:
    enabled: ${ argocd_ingress_enabled }
    ingressClassName: "nginx"
    annotations:
      external-dns.alpha.kubernetes.io/hostname: ${argocd_server_host}.
      cert-manager.io/cluster-issuer: letsencrypt-prod
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    hosts:
      - ${ argocd_server_host }
    tls:
      - secretName: argocd-secret
        hosts:
          - ${ argocd_server_host }
    https: true
  config:
    url: https://${ argocd_server_host }
    admin.enabled: "true"
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${common_infra_support_arn}
