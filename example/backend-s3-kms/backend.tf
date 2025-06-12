# ------------------------------------------------------------------------------
# STORE EXAMPLE STATE LOCALLY
# ------------------------------------------------------------------------------

terraform {
  backend "local" {
    path = "../../.backend/example/backend-s3-kms/terraform.tfstate"
  }
}
