variable "name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "location" {
  description = "Azure region where the workspace will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the workspace will be created."
  type        = string
}

variable "sku" {
  description = "SKU for the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Number of days to retain logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to the workspace."
  type        = map(string)
  default     = {}
}