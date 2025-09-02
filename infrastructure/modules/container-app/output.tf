output "fqdn" {
  description = "FQDN of the container app. Only available if is_web_app is true."
  value       = var.is_web_app ? azurerm_container_app.main.ingress[0].fqdn : ""
}

output "url" {
  description = "URL of the container app. Only available if is_web_app is true."
  value       = var.is_web_app ? "https://${azurerm_container_app.main.ingress[0].fqdn}" : ""
}

output "container_app_fqdn" {
  value = azurerm_container_app.main.latest_revision_fqdn
}
