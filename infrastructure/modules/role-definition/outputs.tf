output "role_definition_id" {
  value = azurerm_role_definition.this.role_definition_resource_id
}

output "role_definition_name" {
  description = "The name of the custom role definition"
  value       = azurerm_role_definition.this.name
}
