data "azurerm_client_config" "current" {}
data "azurerm_key_vault_secrets" "app" {
  count      = var.fetch_secrets_from_app_key_vault ? 1 : 0
  depends_on = [module.key_vault_reader_role_app]

  key_vault_id = var.app_key_vault_id
}

data "azurerm_key_vault" "infra" {
  provider            = azurerm.hub
  count               = var.enable_auth ? 1 : 0
  name                = var.infra_key_vault_name
  resource_group_name = var.infra_key_vault_rg
}

data "azurerm_key_vault_secret" "infra" {
  for_each     = var.enable_auth ? toset(var.infra_secret_names) : toset([])
  name         = each.value
  key_vault_id = data.azurerm_key_vault.infra[0].id
}
