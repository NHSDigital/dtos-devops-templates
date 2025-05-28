output "servicebus_connection_string" {
  value = azurerm_servicebus_namespace_authorization_rule.this.primary_connection_string
  sensitive = true
}

output "namespace_id" {
  value = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  value = azurerm_servicebus_namespace.this.name
}

output "topic_ids" {
  value = { for k, topic in azurerm_servicebus_topic.this : k => topic.id }
}
