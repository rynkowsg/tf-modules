# ------------------------------------------------------------------------------
# STORE EXAMPLE STATE LOCALLY
# ------------------------------------------------------------------------------

terraform {
  backend "local" {
    path = "../../.backend/example/multi-account/terraform.tfstate"
  }
}
