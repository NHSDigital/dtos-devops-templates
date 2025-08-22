resource "azurerm_role_definition" "this" {
  scope       = var.scope
  name        = var.name
  description = var.description

  permissions {
    actions          = try(var.permissions.actions, [])
    data_actions     = try(var.permissions.data_actions, [])
    not_actions      = try(var.permissions.not_actions, [])
    not_data_actions = try(var.permissions.not_data_actions, [])
  }

  assignable_scopes = var.assignable_scopes
}
