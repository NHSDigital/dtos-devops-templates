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
