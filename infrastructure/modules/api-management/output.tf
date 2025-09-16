output "id" {
  description = "The id of the API Management service."
  value       = azurerm_api_management.apim.id
}

output "name" {
  description = "The name of the API Management service."
  value       = azurerm_api_management.apim.name
}

output "private_ip_addresses" {
  description = "The private IP address of the API Management service."
  value       = azurerm_api_management.apim.private_ip_addresses
}

output "system_assigned_identity" {
  description = "The system-assigned identity of the API Management service."
  value       = azurerm_api_management.apim.identity.0.principal_id
}
