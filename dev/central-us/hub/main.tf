module "hub" {
  source = "git::ssh://github.com:esendex/terraform-modules.git//hub?ref=1.0.0"

  region = globals.azure_region
  subnets = [
    # Some list of subnets
  ]
  firewall_public_ip_prefix = "/32"
}

output "firewall" {
  value = module.hub.firewall
}
