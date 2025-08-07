# Note it is not necessary to declare the name for the role assignment as this is auto-generated in GUID format
resource "azurerm_role_assignment" "role_assignment" {
  scope                            = var.scope
  principal_id                     = var.principal_id
  role_definition_name             = var.role_definition_name
  skip_service_principal_aad_check = var.skip_service_principal_aad_check
}
