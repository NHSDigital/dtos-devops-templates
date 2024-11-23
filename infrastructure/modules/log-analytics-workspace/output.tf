output "id" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace.id
}

output "name" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace.name
}

output "identity" {
  description = "The Managed Service Identity that is created by defaults for this Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.log_analytics_workspace.identity
  sensitive   = true
}

# This is an empty list for some reason
# output "principal_id" {
#   description = "The Principal ID of the Managed Service Identity that is created by defaults for this Log Analytics Workspace."
#   value       = azurerm_log_analytics_workspace.log_analytics_workspace.identity[0].principal_id
# }
