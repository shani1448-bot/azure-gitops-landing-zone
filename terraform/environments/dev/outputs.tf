output "resource_group_name" {
  value = module.core_rg.name
}

output "vnet_id" {
  value = module.hub_vnet.vnet_id
}

output "subnet_ids" {
  value = module.hub_vnet.subnet_ids
}

output "nsg_ids" {
  value = {
    shared            = module.nsg_shared.id
    runners           = module.nsg_runners.id
    private_endpoints = module.nsg_private_endpoints.id
  }
}

output "route_table_ids" {
  value = {
    egress = module.rt_egress.id
  }
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.id
}

output "log_analytics_workspace_name" {
  value = module.log_analytics.name
}

output "diagnostic_setting_ids" {
  value = {
    nsg_runners           = module.diag_nsg_runners.id
    nsg_shared            = module.diag_nsg_shared.id
    nsg_private_endpoints = module.diag_nsg_private_endpoints.id
  }
}

output "key_vault_diagnostic_setting_id" {
  value = module.diag_key_vault.id
}

output "key_vault_id" {
  value = module.key_vault.id
}

output "key_vault_name" {
  value = module.key_vault.name
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "key_vault_private_endpoint_id" {
  value = module.pe_key_vault.id
}

output "key_vault_private_endpoint_ip" {
  value = module.pe_key_vault.private_ip_address
}

output "key_vault_private_dns_zone_id" {
  value = module.private_dns_key_vault.id
}

output "tfstate_storage_account_name" {
  description = "Name of the Storage Account prepared for Terraform remote state."
  value       = module.tfstate_storage.name
}

output "tfstate_storage_account_id" {
  description = "Resource ID of the Storage Account prepared for Terraform remote state."
  value       = module.tfstate_storage.id
}

output "tfstate_container_name" {
  description = "Name of the blob container prepared for Terraform remote state."
  value       = module.tfstate_storage.container_name
}

output "tfstate_blob_endpoint" {
  description = "Primary blob endpoint of the Storage Account."
  value       = module.tfstate_storage.primary_blob_endpoint
}

output "tfstate_storage_blob_contributor_assignment_id" {
  description = "Role assignment ID for Storage Blob Data Contributor on the Terraform state Storage Account."
  value       = module.tfstate_storage_blob_contributor.id
}

output "tfstate_blob_diagnostic_setting_id" {
  description = "Diagnostic setting ID for the Terraform state Storage Account blob service."
  value       = module.diag_tfstate_blob.id
}