terramate {
  config {
    experiments = [
      "outputs-sharing"
    ]
  }
}

# See: https://terramate.io/docs/cli/orchestration/outputs-sharing
sharing_backend "shared_outputs" {
  type     = terraform
  filename = "generated_sharing.tf"
  command  = ["tofu", "output", "-json"]
}
