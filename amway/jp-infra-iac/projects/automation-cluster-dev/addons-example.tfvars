komodor_api_key = "..."

argocd = {
  argocd_server_host = "argocd.automation.preprod.jp.amway.net"

  argocd_github_connector_user_name = ".."
  argocd_github_connector_password  = ".."
  argocd_github_org_url             = "https://github.com/AmwayCommon"

  argocd_ingress_enabled = true
}

github_auth = {
  github_app_id              = ""
  github_app_installation_id = ""
  github_app_private_key     = ""
}

## OR
#
# github_auth = {
#   github_token = ""
# }
