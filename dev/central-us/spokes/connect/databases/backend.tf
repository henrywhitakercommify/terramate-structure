// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  backend "s3" {
    bucket  = "REPLACE_ME"
    encrypt = true
    key     = "/dev/central-us/spokes/connect/databases/terraform.tfstate"
    region  = "centralus"
  }
}
