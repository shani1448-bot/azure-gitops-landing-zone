data "azurerm_client_config" "current" {} #this lets tf get yout current Azure tanant ID for the key vault

module "core_rg" {
  source = "../../modules/resource-group"

  name     = "rg-${local.name_prefix}-core"
  location = local.location
  tags     = local.tags
}

module "hub_vnet" {
  source = "../../modules/vnet"

  name                = "vnet-${local.name_prefix}-hub"
  location            = module.core_rg.location
  resource_group_name = module.core_rg.name
  address_space       = local.vnet_address_space
  subnets             = local.subnets
  tags                = local.tags
}

module "nsg_shared" {
  source = "../../modules/nsg"

  name                = "nsg-${local.name_prefix}-shared"
  location            = module.core_rg.location
  resource_group_name = module.core_rg.name
  subnet_id           = module.hub_vnet.subnet_ids["snet-shared"]
  tags                = local.tags
}

module "nsg_runners" {
  source = "../../modules/nsg"

  name                = "nsg-${local.name_prefix}-runners"
  location            = module.core_rg.location
  resource_group_name = module.core_rg.name
  subnet_id           = module.hub_vnet.subnet_ids["snet-runners"]

  security_rules = {
    deny-vnet-inbound = {
      priority                   = 4000
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    }
  }
  tags = local.tags
}

module "nsg_private_endpoints" {
  source = "../../modules/nsg"

  name                = "nsg-${local.name_prefix}-private-endpoints"
  location            = module.core_rg.location
  resource_group_name = module.core_rg.name
  subnet_id           = module.hub_vnet.subnet_ids["snet-private-endpoints"]
  tags                = local.tags
}

module "rt_egress" {
  source = "../../modules/route-table"

  #create one route table 
  # associate it with snet-runners and snet-shared 
  # do not create custom routes yet.
  name                = "rt-${local.name_prefix}-egress"
  location            = module.core_rg.location
  resource_group_name = module.core_rg.name

  subnet_ids = {
    runners = module.hub_vnet.subnet_ids["snet-runners"]
    shared  = module.hub_vnet.subnet_ids["snet-shared"]
  }

  routes = {}

  tags = local.tags
}

module "log_analytics" {
  source = "../../modules/log-analytics"

  name                = "law-${local.name_prefix}-core"
  location            = module.core_rg.location
  resource_group_name = module.core_rg.name
  retention_in_days   = 30
  tags                = local.tags
}

module "diag_nsg_runners" {
  source = "../../modules/diagnostic-setting"

  name                       = "diag-nsg-${local.name_prefix}-runners"
  target_resource_id         = module.nsg_runners.id
  log_analytics_workspace_id = module.log_analytics.id

  log_categories = [
    "NetworkSecurityGroupEvent",
    "NetworkSecurityGroupRuleCounter"
  ]
}

module "diag_nsg_shared" {
  source = "../../modules/diagnostic-setting"

  name                       = "diag-nsg-${local.name_prefix}-shared"
  target_resource_id         = module.nsg_shared.id
  log_analytics_workspace_id = module.log_analytics.id

  log_categories = [
    "NetworkSecurityGroupEvent",
    "NetworkSecurityGroupRuleCounter"
  ]
}

module "diag_nsg_private_endpoints" {
  source = "../../modules/diagnostic-setting"

  name                       = "diag-nsg-${local.name_prefix}-private-endpoints"
  target_resource_id         = module.nsg_private_endpoints.id
  log_analytics_workspace_id = module.log_analytics.id

  log_categories = [
    "NetworkSecurityGroupEvent",
    "NetworkSecurityGroupRuleCounter"
  ]
}

module "key_vault" {
  source = "../../modules/key-vault"

  name                = local.key_vault_name
  location            = module.core_rg.location
  resource_group_name = module.core_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  enable_rbac_authorization     = true
  public_network_access_enabled = false

  tags = local.tags
}

module "diag_key_vault" {
  source = "../../modules/diagnostic-setting"

  name                       = "diag-kv-${local.name_prefix}-core"
  target_resource_id         = module.key_vault.id
  log_analytics_workspace_id = module.log_analytics.id

  log_categories = [
    "AuditEvent"
  ]

  metric_categories = [
    "AllMetrics"
  ]
}

module "private_dns_key_vault" {
  source = "../../modules/private-dns-zone"

  name                      = "privatelink.vaultcore.azure.net"
  resource_group_name       = module.core_rg.name
  virtual_network_id        = module.hub_vnet.vnet_id
  virtual_network_link_name = "pdnslink-${local.name_prefix}-hub"

  tags = local.tags
}

module "pe_key_vault" {
  source = "../../modules/private-endpoint"

  name                = "pe-kv-${local.name_prefix}-core"
  location            = module.core_rg.location
  resource_group_name = module.core_rg.name

  subnet_id = module.hub_vnet.subnet_ids["snet-private-endpoints"]
  # ↑ This part Create the private endpoint NIC inside snet-private-endpoints.
  private_connection_resource_id = module.key_vault.id
  subresource_names              = ["vault"]

  private_dns_zone_ids = [
    module.private_dns_key_vault.id
  ]

  tags = local.tags
}

module "tfstate_storage" {
  source = "../../modules/storage-account"

  name                = local.storage_account_name
  resource_group_name = module.core_rg.name
  location            = var.location

  container_name = "tfstate"

  public_network_access_enabled = true
  shared_access_key_enabled     = true

  tags = local.tags
}

module "tfstate_storage_blob_contributor" {
  source = "../../modules/role-assignment"

  scope                = module.tfstate_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

module "diag_tfstate_blob" {
  source = "../../modules/diagnostic-setting"

  name                       = "diag-blob-${local.storage_account_name}"
  target_resource_id         = module.tfstate_storage.blob_service_id
  log_analytics_workspace_id = module.log_analytics.id

  log_categories = [
    "StorageRead",
    "StorageWrite",
    "StorageDelete"
  ]

  metric_categories = [
    "Transaction"
  ]
}

