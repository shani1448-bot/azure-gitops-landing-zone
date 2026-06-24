variable "name" {
  description = "Name of the Private Endpoint."
  type        = string
}

variable "location" {
  description = "Azure region where the Private Endpoint will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the Private Endpoint will be created."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the Private Endpoint NIC will be placed."
  type        = string
}

variable "private_connection_resource_id" {
  description = "ID of the Azure resource to connect privately to."
  type        = string
}

variable "subresource_names" {
  description = "List of subresources to connect to."
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs to associate with this Private Endpoint."
  type        = list(string)
  default     = []
}

variable "is_manual_connection" {
  description = "Whether the private endpoint connection requires manual approval."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the Private Endpoint."
  type        = map(string)
  default     = {}
}