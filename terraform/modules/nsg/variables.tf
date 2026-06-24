variable "name" {
  description = "Name of the Network Security Group."
  type        = string
}

variable "location" {
  description = "Azure region where the NSG will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the NSG will be created."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to associate with this NSG."
  type        = string
}

variable "security_rules" {
  description = "Map of security rules to create inside the NSG."
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the NSG."
  type        = map(string)
  default     = {}
}