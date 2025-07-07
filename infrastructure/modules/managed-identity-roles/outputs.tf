output "global_mi_id" {
  value = module.global_managed_identity.id
}

output "global_mi_principal_id" {
  value = module.global_managed_identity.principal_id
}

output "storage_role_definition_id" {
  value = azurerm_role_definition.global_mi_storage_role_definition.id
}
output "keyvault_role_definition_id" {
  value = azurerm_role_definition.global_mi_keyvault_role_definition.id
}
output "sql_role_definition_id" {
  value = azurerm_role_definition.global_mi_sql_role_definition.id
}

output "function_role_definition_id" {
  value = data.azurerm_role_definition.contributor_role.id
}

