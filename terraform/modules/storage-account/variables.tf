variable "name" {
  description = "Name of the Storage Account. Must be globally unique, lowercase, numbers only, 3-24 characters."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group where the Storage Account will be created."
  type        = string
}

variable "location" {
  description = "Azure region where the Storage Account will be created."
  type        = string
}

variable "account_tier" {
  description = "Storage Account performance tier."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage Account replication type."
  type        = string
  default     = "LRS"
}

variable "container_name" {
  description = "Name of the blob container to create."
  type        = string
  default     = "tfstate"
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Storage Account."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version for the Storage Account."
  type        = string
  default     = "TLS1_2"
}

variable "shared_access_key_enabled" {
  description = "Whether the Storage Account permits Shared Key authorization."
  type        = bool
  default     = true
}

variable "blob_soft_delete_retention_days" {
  description = "Number of days deleted blobs are retained."
  type        = number
  default     = 7
}

variable "container_soft_delete_retention_days" {
  description = "Number of days deleted containers are retained."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to the Storage Account."
  type        = map(string)
  default     = {}
}