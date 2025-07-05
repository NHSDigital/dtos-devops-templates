output "global_uami_id" {
  value = module.global_uami.id
}

output "global_uami_principal_id" {
  value = module.global_uami.principal_id
}

output "storage_role_definition_id" {
  value = azurerm_role_definition.global_uami_storage_role_definition.id
}
output "keyvault_role_definition_id" {
  value = azurerm_role_definition.global_uami_keyvault_role_definition.id
}
output "sql_role_definition_id" {
  value = azurerm_role_definition.global_uami_sql_role_definition.id
}

output "function_role_definition_id" {
  value = data.azurerm_role_definition.contributor.id
}

