variable "name" {
  description = "Name of the firewall policy rule collection group."
  type        = string
}

variable "firewall_policy_id" {
  description = "ID of the Azure Firewall Policy."
  type        = string
}

variable "priority" {
  description = "Priority of the rule collection group."
  type        = number
}

variable "source_addresses" {
  description = "Source address ranges allowed by these firewall rules."
  type        = list(string)
}