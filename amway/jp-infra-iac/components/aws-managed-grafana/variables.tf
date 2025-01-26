variable "workspace_name" {
  type        = string
  description = "The alias of the prometheus workspace"
}

variable "data_sources" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
}

variable "role_assertion" {
  type        = string
  description = "The alias of the prometheus workspace"
}

variable "editor_role_values" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
}

variable "admin_role_values" {
  type        = list(string)
  description = "The alias of the prometheus workspace"
}

variable "idp_metadata_url" {
  type        = string
  description = "The alias of the prometheus workspace"
}

variable "amg_role_inline_policy" {
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = [
    {
      "Effect" : "Allow",
      "Action" : [
        "aps:ListWorkspaces",
        "aps:DescribeWorkspace",
        "aps:QueryMetrics",
        "aps:GetLabels",
        "aps:GetSeries",
        "aps:GetMetricMetadata"
      ],
      "Resource" : ["*"]
    }
  ]
}
