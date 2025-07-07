# Note: for custom role definition resources, don't use the "id" property.
# This is a Terraform property in the format "<id>|<scope>". Instead use
# the role_definition_resource_id property (the ARM ID)
output "storage_role_definition_id" {
  value = azurerm_role_definition.global_mi_storage_role_definition.role_definition_resource_id
}
output "keyvault_role_definition_id" {
  value = azurerm_role_definition.global_mi_keyvault_role_definition.role_definition_resource_id
}
output "sql_role_definition_id" {
  value = azurerm_role_definition.global_mi_sql_role_definition.role_definition_resource_id
}

output "function_role_definition_id" {
  value = data.azurerm_role_definition.contributor_role.id
}

output "reader_role_id" {
  value = data.azurerm_role_definition.reader_role.id
}


