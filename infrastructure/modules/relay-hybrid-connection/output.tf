output "id" {
  description = "The ID of the Relay Hybrid Connection."
  value       = azurerm_relay_hybrid_connection.hybrid_connection.id
}

output "name" {
  description = "The name of the Relay Hybrid Connection."
  value       = azurerm_relay_hybrid_connection.hybrid_connection.name
}

output "authorization_rule_ids" {
  description = "A map of authorization rule names to their IDs."
  value       = { for k, v in azurerm_relay_hybrid_connection_authorization_rule.auth_rule : k => v.id }
}

output "authorization_rule_primary_keys" {
  description = "A map of authorization rule names to their primary keys."
  value       = { for k, v in azurerm_relay_hybrid_connection_authorization_rule.auth_rule : k => v.primary_key }
  sensitive   = true
}

output "authorization_rule_secondary_keys" {
  description = "A map of authorization rule names to their secondary keys."
  value       = { for k, v in azurerm_relay_hybrid_connection_authorization_rule.auth_rule : k => v.secondary_key }
  sensitive   = true
}

output "authorization_rule_primary_connection_strings" {
  description = "A map of authorization rule names to their primary connection strings."
  value       = { for k, v in azurerm_relay_hybrid_connection_authorization_rule.auth_rule : k => v.primary_connection_string }
  sensitive   = true
}

output "authorization_rule_secondary_connection_strings" {
  description = "A map of authorization rule names to their secondary connection strings."
  value       = { for k, v in azurerm_relay_hybrid_connection_authorization_rule.auth_rule : k => v.secondary_connection_string }
  sensitive   = true
}
