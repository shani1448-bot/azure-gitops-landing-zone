variable "subscription_id" {
  description = "Azure subscription ID where the landing zone will be deployed."
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "westeurope"
}