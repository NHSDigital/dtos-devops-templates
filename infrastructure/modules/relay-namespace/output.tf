output "name" {
  description = "The name of the Relay namespace."
  value       = azurerm_relay_namespace.relay.name
}

output "id" {
  description = "The ID of the Relay namespace."
  value       = azurerm_relay_namespace.relay.id
}

output "primary_connection_string" {
  description = "The primary connection string for the Relay namespace."
  value       = azurerm_relay_namespace.relay.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the Relay namespace."
  value       = azurerm_relay_namespace.relay.secondary_connection_string
  sensitive   = true
}

output "primary_key" {
  description = "The primary access key for the Relay namespace."
  value       = azurerm_relay_namespace.relay.primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "The secondary access key for the Relay namespace."
  value       = azurerm_relay_namespace.relay.secondary_key
  sensitive   = true
}
