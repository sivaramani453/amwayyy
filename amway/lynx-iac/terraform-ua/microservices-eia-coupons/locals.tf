locals {
  tags = map(
    "Name", "eia-coupons-db",
    "Service", "coupons",
    "Terraform", "true",
    "Environment", "DEV",
    "DataClassification", "Internal",
    "ApplicationID", "APP3150571"
  )
}
