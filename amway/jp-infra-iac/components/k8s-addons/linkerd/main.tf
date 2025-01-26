# From: https://github.com/linkerd/linkerd2/discussions/6230

# linkerd Mutual TLS certs
resource "tls_private_key" "trustanchor_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "trustanchor_cert" {
  #key_algorithm         = tls_private_key.trustanchor_key.algorithm
  private_key_pem       = tls_private_key.trustanchor_key.private_key_pem
  validity_period_hours = 87600
  is_ca_certificate     = true

  subject {
    common_name = "identity.linkerd.cluster.local"
  }

  allowed_uses = [
    "crl_signing",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]
}

resource "tls_private_key" "issuer_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "issuer_req" {
  #key_algorithm   = tls_private_key.issuer_key.algorithm
  private_key_pem = tls_private_key.issuer_key.private_key_pem

  subject {
    common_name = "identity.linkerd.cluster.local"
  }
}

resource "tls_locally_signed_cert" "issuer_cert" {
  cert_request_pem = tls_cert_request.issuer_req.cert_request_pem
  #ca_key_algorithm      = tls_private_key.trustanchor_key.algorithm
  ca_private_key_pem    = tls_private_key.trustanchor_key.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.trustanchor_cert.cert_pem
  validity_period_hours = 8760
  is_ca_certificate     = true

  allowed_uses = [
    "crl_signing",
    "cert_signing",
    "server_auth",
    "client_auth"
  ]
}

resource "helm_release" "linkerd_crds" {
  repository       = "https://helm.linkerd.io/stable"
  name             = "linkerd-crds"
  chart            = "linkerd-crds"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
}

resource "helm_release" "linkerd_control_plane" {
  name             = "linkerd-control-plane"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-control-plane"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  depends_on = [
    helm_release.linkerd_crds,
    tls_self_signed_cert.trustanchor_cert,
    tls_locally_signed_cert.issuer_cert,
    tls_private_key.issuer_key
  ]

  values = [
  file("${path.module}/resources/linkerd-values.yaml")]

  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_self_signed_cert.trustanchor_cert.cert_pem
  }

  set {
    name  = "identity.issuer.crtExpiry"
    value = tls_locally_signed_cert.issuer_cert.validity_end_time
  }

  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.issuer_cert.cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer_key.private_key_pem
  }

}

resource "helm_release" "linkerd_viz" {
  name             = "linkerd-viz"
  repository       = "https://helm.linkerd.io/stable"
  chart            = "linkerd-viz"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true

  values = [
  file("${path.module}/resources/linkerd-viz-values.yaml")]

  set {
    name  = "linkerdNamespace"
    value = var.namespace
  }
  depends_on = [
    helm_release.linkerd_control_plane
  ]
}
