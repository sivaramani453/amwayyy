locals {
  tags = map(
    "Name", "eia-vip-reports",
    "Service", "vip-reports",
    "Terraform", "true",
    "Environment", "DEV",
    "DataClassification", "Internal",
    "ApplicationID", "APP1433689"
  )
}
