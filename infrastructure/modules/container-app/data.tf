data "azurerm_key_vault" "app" {
  count = var.app_key_vault_name != null ? 1 : 0

  name                = var.app_key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secrets" "app" {
  count = var.app_key_vault_name != null ? 1 : 0

  key_vault_id = data.azurerm_key_vault.app[0].id
}
