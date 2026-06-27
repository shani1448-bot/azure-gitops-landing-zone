variable "name" {
  description = "Name of the policy assignment."
  type        = string
}

variable "display_name" {
  description = "Display name of the policy assignment."
  type        = string
}

variable "description" {
  description = "Description of the policy assignment."
  type        = string
  default     = null
}

variable "policy_definition_id" {
  description = "ID of the policy definition to assign."
  type        = string
}

variable "resource_group_id" {
  description = "Resource group scope for the policy assignment."
  type        = string
}

variable "parameters" {
  description = "Policy assignment parameters."
  type        = any
  default     = {}
}

variable "location" {
  description = "Azure region for the policy assignment identity."
  type        = string
  default     = null
}

variable "assign_identity" {
  description = "Whether to assign a system-assigned managed identity to the policy assignment."
  type        = bool
  default     = false
}