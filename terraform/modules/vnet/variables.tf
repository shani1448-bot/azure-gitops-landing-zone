variable "name" {
  description = "Virtual network name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the VNet will be created."
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet."
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnets to create."
  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "tags" {
  description = "Tags to apply to the VNet."
  type        = map(string)
  default     = {}
}