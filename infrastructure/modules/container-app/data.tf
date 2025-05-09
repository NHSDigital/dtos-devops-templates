# data "azurerm_key_vault" "app" {
#   count = var.app_key_vault_name != null ? 1 : 0

#   name                = var.app_key_vault_name
#   resource_group_name = var.resource_group_name
# }

data "azurerm_key_vault_secrets" "app" {
  count = var.fetch_secrets_from_app_key_vault ? 1 : 0

  depends_on = [module.key_vault_reader_role]

  key_vault_id = var.app_key_vault_id
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}
