resource "azurerm_role_definition" "this" {
  scope = var.scope
  name = var.name
  description = var.description

  dynamic "permissions" {
    for_each = var.permissions
    content {
      actions          = try(permissions.value.actions, [])
      data_actions     = try(permissions.value.data_actions, [])
      not_actions      = try(permissions.value.not_actions, [])
      not_data_actions = try(permissions.value.not_data_actions, [])
    }
  }

  assignable_scopes = var.assignable_scopes
}
