# Note it is not necessary to declare the name for the role assignment as this is auto-generated in GUID format.
resource "azurerm_role_assignment" "role_assignment" {
  scope                            = var.scope
  principal_id                     = var.principal_id
  role_definition_id               = data.azurerm_role_definition.role_definition.id
  skip_service_principal_aad_check = var.skip_service_principal_aad_check
}

# Declare the azurerm_subscription data source as this is required to get the full path for the role definition
data "azurerm_subscription" "target" {
}

# Look up the role definition by name as a convenience for the user
data "azurerm_role_definition" "role_definition" {
  name = var.role_definition_name

  # The scope is required to ensure the full role id path matches that saved in the state file
  scope = data.azurerm_subscription.target.id
}
