variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "selenoid_node_count" {
  description = "Desired count of nodes in Selenoid fleet"
  default     = "1"
}

variable "selenoid_node_shape" {
  description = "Desired shape of nodes in Selenoid fleet"
  default     = "t3.large"
}

variable "spot_liveness" {
  type        = "string"
  description = "TTL of Spot instance"
  default     = "2033-01-01T01:00:00Z"
}
