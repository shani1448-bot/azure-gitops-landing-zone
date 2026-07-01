resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = var.name
  firewall_policy_id = var.firewall_policy_id
  priority           = var.priority

  application_rule_collection {
    name     = "arc-bootstrap-app-allow"
    priority = 100
    action   = "Allow"

    rule {
      name             = "allow-github-actions"
      source_addresses = var.source_addresses

      destination_fqdns = [
        "github.com",
        "api.github.com",
        "*.actions.githubusercontent.com",
        "codeload.github.com",
        "results-receiver.actions.githubusercontent.com",
        "objects.githubusercontent.com",
        "objects-origin.githubusercontent.com",
        "github-releases.githubusercontent.com",
        "github-registry-files.githubusercontent.com",
        "*.blob.core.windows.net"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "allow-terraform-providers"
      source_addresses = var.source_addresses

      destination_fqdns = [
        "registry.terraform.io",
        "releases.hashicorp.com"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "allow-azure-auth-management"
      source_addresses = var.source_addresses

      destination_fqdns = [
        "login.microsoftonline.com",
        "management.azure.com",
        "graph.microsoft.com"
      ]

      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}