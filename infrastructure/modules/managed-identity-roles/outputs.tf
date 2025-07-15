#
# Note: for custom role definition resources, don't use the "id" property.
#
# "id"" is a Terraform property in the format "<id>|<scope>". Instead use
# the role_definition_resource_id property (the ARM ID)
#

output "storage_role_definition_id" {
  value = azurerm_role_definition.global_storage_role_rw.role_definition_resource_id
}
output "keyvault_role_definition_id" {
  value = azurerm_role_definition.global_keyvault_role_rw.role_definition_resource_id
}
output "sql_role_definition_id" {
  value = azurerm_role_definition.global_sql_role_rw.role_definition_resource_id
}

output "function_role_definition_id" {
  value = data.azurerm_role_definition.contributor_role.id
}

output "grid_role_definition_id" {
  value = azurerm_role_definition.global_event_grid_role_rw.role_definition_resource_id
}

output "bus_role_definition_id" {
  value = azurerm_role_definition.global_service_bus_role_rw.role_definition_resource_id
}

output "reader_role_id" {
  value = data.azurerm_role_definition.reader_role.id
}


