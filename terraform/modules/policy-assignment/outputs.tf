output "id" {
  description = "Policy assignment ID."
  value       = azurerm_resource_group_policy_assignment.this.id
}

output "name" {
  description = "Policy assignment name."
  value       = azurerm_resource_group_policy_assignment.this.name
}

output "principal_id" {
  description = "System-assigned managed identity principal ID."
  value       = try(azurerm_resource_group_policy_assignment.this.identity[0].principal_id, null)
} 