# Need to give the deployment service principal the required permissions to the storage account
module "rbac_assignmnents" {
  for_each = toset(var.rbac_roles)

  source = "../rbac-assignment"

  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = each.key
  scope                = azurerm_storage_account.storage_account.id
}

data "azurerm_client_config" "current" {}
