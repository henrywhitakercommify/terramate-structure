module "aks" {
  source = "some-source"

  name   = "bongo"
  region = globals.azure_region
}
