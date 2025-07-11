data "azurerm_client_config" "current" {}
data "azurerm_key_vault_secrets" "app" {
  count      = var.fetch_secrets_from_app_key_vault ? 1 : 0
  depends_on = [module.key_vault_reader_role]

  key_vault_id = var.app_key_vault_id
}

data "azurerm_key_vault" "infra" {
  count = var.fetch_secrets_from_infra_key_vault ? 1 : 0
  name                = var.infra_key_vault_name
  resource_group_name = var.infra_key_vault_rg
}

data "azurerm_key_vault_secrets" "infra" {
  count      = var.fetch_secrets_from_infra_key_vault ? 1 : 0
  depends_on = [module.key_vault_reader_role]

  key_vault_id = var.infra_key_vault_id
}

data "azurerm_key_vault_secret" "all" {
  for_each    = local.secret_names
  name       = each.value
  key_vault_id = data.azurerm_key_vault.infra.id
}
