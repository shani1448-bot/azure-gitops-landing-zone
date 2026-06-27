output "id" {
  description = "Azure Firewall ID."
  value       = azurerm_firewall.this.id
}

output "name" {
  description = "Azure Firewall name."
  value       = azurerm_firewall.this.name
}

output "private_ip_address" {
  description = "Azure Firewall private IP address."
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "public_ip_address" {
  description = "Azure Firewall public IP address."
  value       = azurerm_public_ip.this.ip_address
}

output "management_public_ip_address" {
  description = "Azure Firewall management public IP address."
  value       = azurerm_public_ip.management.ip_address
}

output "firewall_policy_id" {
  description = "Azure Firewall Policy ID."
  value       = azurerm_firewall_policy.this.id
}