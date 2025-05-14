data "azurerm_key_vault_secrets" "app" {
  count      = var.fetch_secrets_from_app_key_vault ? 1 : 0
  depends_on = [module.key_vault_reader_role]

  key_vault_id = var.app_key_vault_id
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}
