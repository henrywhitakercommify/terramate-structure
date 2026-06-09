stack {
  name        = "firewall-rules"
  description = "firewall-rules"
  id          = "7c9a05c0-1c3b-44b9-bb4b-85c84c54e151"
}

input "firewall_id" {
  backend       = "shared_outputs"
  from_stack_id = "c557c780-08ed-4fcb-a938-3cc6c21ff492"
  value         = outputs.firewall.id
}
