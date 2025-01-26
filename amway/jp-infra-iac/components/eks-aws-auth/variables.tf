variable "eks_auth_roles" {
  type = list(object({
    rolearn  = string,
    username = string,
    groups   = list(string)
  }))
}
