module "aks" {
  source = "git::ssh://github.com:esendex/terraform-modules.git//aks?ref=1.0.0"

  name   = "bongo"
  region = globals.azure_region
}
