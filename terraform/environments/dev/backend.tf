#Important lesson: backend config cannot use variables or locals.
# so this is not allowed : storage_account_name = local.storage_account_name

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-gitops-lz-dev-core"
    storage_account_name = "stgitopslzdev07522e"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"

    use_azuread_auth = true # without this line - tf BE could use Storage Account key access
    # but with that line ↑ tf BE uses Entra ID + RBAC 
    # that line tells tf : when reading/writing the remote state blob,use my Azure login / Entra ID token + RBAC, not the Storage Account access key.
  }
}