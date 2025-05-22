output "servicebus_connection_string" {
  value = azurerm_servicebus_namespace_authorization_rule.this.primary_connection_string
  sensitive = true
}

# output "servicebus_topic_ids" {
#   description = "A map of Service Bus Topic IDs"
#   value       = { for k, topic in azurerm_servicebus_topic.this : k => topic.id }
# }

output "id" {
 description = "A map of Service Bus Topic IDs"
 value       = { for k, topic in azurerm_servicebus_topic.this : k => topic.id }
}