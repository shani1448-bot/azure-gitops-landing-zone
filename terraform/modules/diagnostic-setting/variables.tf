variable "name" {
  description = "Name of the diagnostic setting."
  type        = string
}

variable "target_resource_id" {
  description = "ID of the Azure resource to configure diagnostics for."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace where diagnostics will be sent."
  type        = string
}

variable "log_categories" {
  description = "List of log categories to enable."
  type        = list(string)
  default     = []
}

variable "metric_categories" {
  description = "List of metric categories to enable."
  type        = list(string)
  default     = []
}

variable "disabled_metric_categories" {
  description = "List of metric categories to explicitly disable."
  type        = list(string)
  default     = []
}