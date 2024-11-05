# Need to give the depolyment service principal the required permissions to the storage account
module "rbac_assignmnents" {
  for_each = { for idx, assignment in var.rbac_roles : idx => assignment }

  source = "../rbac-assignment"

  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = each.value
  scope                = azurerm_storage_account.storage_account.id
}

data "azurerm_client_config" "current" {}
