output "storage_account_name" {
  description = "The name of the created Storage Account"
  value       = azurerm_storage_account.storage_account.name
}

output "storage_account_id" {
  description = "The ID of the created Storage Account"
  value       = azurerm_storage_account.storage_account.id
}

output "storage_account_primary_connection_string" {
  sensitive = true
  value     = azurerm_storage_account.storage_account.primary_connection_string
}

output "storage_account_primary_access_key" {
  sensitive = true
  value     = azurerm_storage_account.storage_account.primary_access_key
}

output "storage_containers" {
  sensitive = true
  value     = azurerm_storage_container.container
}

output "primary_blob_endpoint_name" {
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
  description = "Name of blob storage endpoint "
}