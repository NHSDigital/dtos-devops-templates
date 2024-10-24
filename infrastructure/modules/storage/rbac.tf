# Need to give the depolyment service principal the required permissions to the storage account
module "rbac_assignmnents" {
  for_each = { for idx, assignment in var.rbac_roles : idx => assignment }

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/rbac-assignment?ref=88d5befe18207895d1dd09ec514c6f2f9b1379b2"

  principal_id         = data.azurerm_client_config.current
  role_definition_name = each.value
  scope                = azurerm_storage_account.storage_account.id
}

data "azurerm_client_config" "current" {}
