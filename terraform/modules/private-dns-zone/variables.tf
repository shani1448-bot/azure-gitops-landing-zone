variable "name" {
  description = "Name of the Private DNS zone."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the Private DNS zone will be created."
  type        = string
}

variable "virtual_network_id" {
  description = "ID of the VNet to link to the Private DNS zone."
  type        = string
}

variable "virtual_network_link_name" {
  description = "Name of the VNet link."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Private DNS zone."
  type        = map(string)
  default     = {}
}