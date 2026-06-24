locals {
  environment    = "dev"
  location       = "westeurope"
  workload       = "gitops-lz"
  key_vault_name = "kv-${replace(local.name_prefix, "-", "")}-${substr(replace(var.subscription_id, "-", ""), 0, 6)}"

  name_prefix = "${local.workload}-${local.environment}"

  storage_account_name = "st${replace(local.name_prefix, "-", "")}${substr(replace(var.subscription_id, "-", ""), 0, 6)}"

  tags = {
    environment = local.environment
    project     = "azure-gitops-landing-zone"
    owner       = "shani"
    managed_by  = "terraform"
  }

  vnet_address_space = ["10.10.0.0/16"] #this is the vnet address space 

  subnets = {
    snet-shared = {
      address_prefixes = ["10.10.1.0/24"]
    }

    snet-private-endpoints = {
      address_prefixes = ["10.10.2.0/24"]
    }

    snet-runners = {
      address_prefixes = ["10.10.10.0/24"]
    }

    AzureFirewallSubnet = {
      address_prefixes = ["10.10.100.0/26"]
    }
  }
}