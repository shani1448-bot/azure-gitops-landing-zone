variable "scope" {
  description = "Azure scope where the role assignment will apply."
  type        = string
}

variable "role_definition_name" {
  description = "Built-in Azure role name to assign."
  type        = string
}

variable "principal_id" {
  description = "Object ID of the user, group, service principal, or managed identity receiving the role."
  type        = string
}

variable "principal_type" {
  description = "Type of principal receiving the role assignment."
  type        = string
  default     = null
}