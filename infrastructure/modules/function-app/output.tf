output "name" {
  description = "The name of the Linux Function App."
  value       = azurerm_linux_function_app.function_app.name
}

output "function_app_sami_id" {
  description = "The Principal ID of the System Assigned Managed Service Identity that is configured on this Linux Function App."
  value       = azurerm_linux_function_app.function_app.identity.0.principal_id
}
