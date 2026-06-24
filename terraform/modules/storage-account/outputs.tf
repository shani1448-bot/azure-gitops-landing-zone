output "id" {
  description = "Storage Account resource ID."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage Account name."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the Storage Account."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "container_name" {
  description = "Name of the created blob container."
  value       = azurerm_storage_container.this.name
}

output "container_id" {
  description = "Storage container resource ID."
  value       = azurerm_storage_container.this.id
}

output "blob_service_id" {
  description = "Resource ID of the default blob service for diagnostic settings."
  value       = "${azurerm_storage_account.this.id}/blobServices/default"
}