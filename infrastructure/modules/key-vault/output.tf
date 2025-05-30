output "key_vault_name" {
  value = azurerm_key_vault.keyvault.name
}

output "key_vault_id" {
  value = azurerm_key_vault.keyvault.id
}

output "key_vault_url" {
  value = azurerm_key_vault.keyvault.vault_uri
}
