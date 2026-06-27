locals {
  environment    = "dev"
  location       = "westeurope"
  workload       = "gitops-lz"
  key_vault_name = "kv-${replace(local.name_prefix, "-", "")}-${substr(replace(var.subscription_id, "-", ""), 0, 6)}"

  name_prefix = "${local.workload}-${local.environment}"

  azure_firewall_name                = "afw-${local.name_prefix}-hub"
  azure_firewall_policy_name         = "afwp-${local.name_prefix}-hub"
  azure_firewall_pip_name            = "pip-afw-${local.name_prefix}-hub"
  azure_firewall_management_pip_name = "pip-afw-mgmt-${local.name_prefix}-hub"

  storage_account_name = "st${replace(local.name_prefix, "-", "")}${substr(replace(var.subscription_id, "-", ""), 0, 6)}"

  tags = {
    environment = local.environment
    project     = "azure-gitops-landing-zone"
    owner       = "shani"
    managed_by  = "terraform"
  }

  vnet_address_space = ["10.10.0.0/16"] #this is the vnet address space 

  subnets = {
    AzureFirewallSubnet = {
      address_prefixes = ["10.10.100.0/26"]
    }

    AzureFirewallManagementSubnet = {
      address_prefixes = ["10.10.101.0/26"]
    }

    snet-shared = {
      address_prefixes = ["10.10.1.0/24"]
    }

    snet-private-endpoints = {
      address_prefixes = ["10.10.2.0/24"]
    }

    snet-runners = {
      address_prefixes = ["10.10.10.0/24"]
    }
  }
}