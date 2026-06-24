output "id" {
  description = "Role Assignment resource ID."
  value       = azurerm_role_assignment.this.id
}

output "principal_id" {
  description = "Principal ID that received the role assignment."
  value       = azurerm_role_assignment.this.principal_id
}

output "role_definition_name" {
  description = "Assigned role definition name."
  value       = var.role_definition_name
}

output "scope" {
  description = "Scope of the role assignment."
  value       = azurerm_role_assignment.this.scope
}