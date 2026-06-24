variable "name" {
  description = "Name of the Key Vault. Must be globally unique."
  type        = string
}

variable "location" {
  description = "Azure region where the Key Vault will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the Key Vault will be created."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used by the Key Vault."
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Key Vault."
  type        = string
  default     = "standard"
}

variable "enable_rbac_authorization" {
  description = "Whether the Key Vault uses Azure RBAC instead of access policies."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  #This controls whether the Key Vault can be reached through its public endpoint.
  description = "Whether public network access is enabled for the Key Vault."
  type        = bool
  default     = false # means : Do not allow public network access to this Key Vault.
  #Use private access instead.
}

variable "soft_delete_retention_days" {
  #If someone deletes the Key Vault or a secret, it is not immediately gone.
  #It can be recovered during the retention window.
  description = "Number of days deleted vaults and objects are retained."
  type        = number
  default     = 7 # Meaning deleted items are retained for 7 days.
}

variable "purge_protection_enabled" {
  # means : Even after deleting the vault/secret, nobody can permanently purge(לטהר) it until the retention period ends.
  description = "Whether purge protection is enabled. For dev, false avoids cleanup issues."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the Key Vault."
  type        = map(string)
  default     = {}
}