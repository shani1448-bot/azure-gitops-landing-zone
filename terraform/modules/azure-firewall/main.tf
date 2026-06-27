resource "azurerm_public_ip" "this" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

resource "azurerm_public_ip" "management" {
  name                = var.management_public_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                = var.firewall_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku = var.sku_tier

  tags = var.tags
}

resource "azurerm_firewall" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = "AZFW_VNet"
  sku_tier = var.sku_tier

  firewall_policy_id = azurerm_firewall_policy.this.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.this.id
  }

  management_ip_configuration {
    name                 = "management"
    subnet_id            = var.management_subnet_id
    public_ip_address_id = azurerm_public_ip.management.id
  }

  tags = var.tags
}