# keep this in secert
variable "splunk_token" {
  description = "Splunk HEC token (Use any value if you are not planning to use splunk here)"
}

# Not sensitive env vars
variable "env_vars" {
  description = "Environment vars to use inside lambda func"
  type        = "map"

  default = {
    DEST       = "splunk"
    SPLUNK_URL = "https://http-inputs-amway.splunkcloud.com/services/collector/event"
  }
}
