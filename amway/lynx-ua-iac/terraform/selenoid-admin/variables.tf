variable "region" {
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "go-grid-router_node_count" {
  description = "Desired count of nodes in Go Grid Router fleet"
  default     = "1"
}

variable "go-grid-router_node_shape" {
  description = "Desired shape of nodes in Go Grid Router fleet"
  default     = "t3.micro"
}

variable "go-grid-router_cidr_blocks" {
  description = "Desired CIDR blocks"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

variable "go-grid-router_allow_all_cidr_blocks" {
  description = "Desired Allow all CIDR blocks"
  type        = "list"
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
}
