output "db_admin_pwd_keyvault_secret" {
  value = resource.azurerm_key_vault_secret.db_admin_pwd[0].versionless_id
}
