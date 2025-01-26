variable "default_tags" {
  type = map(string)
  default = {
    ApplicationID = "APPXXXXXX",
    Contact       = "XXXXX",
    Project       = "XXXXX",
    Country       = "Japan",
    Environment   = "PROD"
  }
}
