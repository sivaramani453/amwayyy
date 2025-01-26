variable "name" {
  type        = "string"
  description = "Name for EFS Mount"
  default     = "kubernetes-efs"
}

variable "efs_allowed_ingress_cidrs" {
  type        = "list"
  description = "A list of CIDRs to allow traffic into the NFS"
}

variable "efs_allowed_egress_cidrs" {
  type        = "list"
  description = "A list of CIDRs to allow traffic from NFS"
}

variable "ipv6_efs_allowed_egress_cidrs" {
  type        = "list"
  description = "A list of CIDRs to allow traffic from NFS IPv6"
}
