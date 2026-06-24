output "id" {
  description = "ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  # uri = Uniform Resource Identifier. For Key Vault, it is the service endpoint address.
  description = "URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}