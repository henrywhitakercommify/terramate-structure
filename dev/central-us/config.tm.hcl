globals {
  backend_bucket         = "REPLACE_ME"
  backend_region         = "centralus"
  backend_dynamodb_table = "REPLACE_ME"

  azure_region = "centralus"
}

generate_hcl "backend.tf" {
  content {
    terraform {
      backend "s3" {
        bucket  = global.backend_bucket
        region  = global.backend_region
        key     = "${terramate.stack.path.absolute}/terraform.tfstate"
        encrypt = true
      }
    }
  }
}
