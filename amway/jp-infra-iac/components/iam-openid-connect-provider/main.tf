terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "tls_certificate" "cluster" {
  url = var.url
}


### OIDC config
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list = var.client_id_list
  thumbprint_list = concat(
    [
    data.tls_certificate.cluster.certificates.0.sha1_fingerprint], var.thumbprint_list
  )
  url = var.url
}

output "oidc_provider" {
  value = aws_iam_openid_connect_provider.cluster
}
