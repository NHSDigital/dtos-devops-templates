output "id" {
  description = "The id of the Linux Web App."
  value       = azurerm_linux_web_app.this.id
}

output "linux_web_app_endpoint_name" {
  description = "The linux web app endpoint name."
  value       = var.linux_web_app_name
}

output "linux_web_app_sami_id" {
  description = "The Principal ID of the System Assigned Managed Service Identity that is configured on this Linux Web App."
  value       = azurerm_linux_web_app.this.identity.0.principal_id
}

output "name" {
  description = "The name of the Linux Web App."
  value       = azurerm_linux_web_app.this.name
}
