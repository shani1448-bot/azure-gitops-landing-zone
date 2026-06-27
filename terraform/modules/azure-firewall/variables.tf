variable "name" {
  description = "Name of the Azure Firewall."
  type        = string
}

variable "firewall_policy_name" {
  description = "Name of the Azure Firewall Policy."
  type        = string
}

variable "public_ip_name" {
  description = "Name of the Firewall public IP."
  type        = string
}

variable "management_public_ip_name" {
  description = "Name of the Firewall management public IP."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where the firewall resources will be created."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "subnet_id" {
  description = "ID of the AzureFirewallSubnet."
  type        = string
}

variable "management_subnet_id" {
  description = "ID of the AzureFirewallManagementSubnet."
  type        = string
}

variable "sku_tier" {
  description = "Azure Firewall SKU tier."
  type        = string
  default     = "Basic"

  validation {
    condition     = var.sku_tier == "Basic"
    error_message = "This module is currently designed for Azure Firewall Basic."
  }
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}