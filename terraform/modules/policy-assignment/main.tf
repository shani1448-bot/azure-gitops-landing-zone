resource "azurerm_resource_group_policy_assignment" "this" {
  name                 = var.name
  display_name         = var.display_name
  description          = var.description
  resource_group_id    = var.resource_group_id
  policy_definition_id = var.policy_definition_id
  parameters           = jsonencode(var.parameters)

  location = var.assign_identity ? var.location : null

  dynamic "identity" {
    for_each = var.assign_identity ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }
}