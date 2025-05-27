output "servicebus_connection_string" {
  value = azurerm_servicebus_namespace_authorization_rule.this.primary_connection_string
  sensitive = true
}

output "namespace_id" {
  value = azurerm_servicebus_namespace.this.id
}
