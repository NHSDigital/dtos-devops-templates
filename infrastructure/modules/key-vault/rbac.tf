# Need to give the deployment service principal the required permissions to the key vault
module "rbac_assignments" {
  for_each = var.enable_rbac_authorization ? toset(var.rbac_roles) : []

  source = "../rbac-assignment"

  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = each.key
  scope                = azurerm_key_vault.keyvault.id
}
