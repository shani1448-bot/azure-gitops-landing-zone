variable "name" {
  description = "Name of the route table."
  type        = string
}

variable "location" {
  description = "Azure region where the route table will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the route table will be created."
  type        = string
}

variable "routes" {
  description = "Map of routes to create in the route table."
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}

variable "subnet_ids" {
  description = "Map of subnet IDs to associate with the route table."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the route table."
  type        = map(string)
  default     = {}
}