output "url" {
  description = "URL of the container app. Only available if is_web_app is true."
  value       = var.is_web_app ? "https://${azurerm_container_app.main.ingress[0].fqdn}" : ""
}
