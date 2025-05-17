output "id" {
  description = "Container app environment ID"
  value       = azurerm_container_app_environment.main.id
}

output "default_domain" {
  description = "Default internal DNS domain. Should be registered in the private DNS zone."
  value       = azurerm_container_app_environment.main.default_domain
}
