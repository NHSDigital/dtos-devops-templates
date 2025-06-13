output "id" {
  value = azurerm_cdn_frontdoor_profile.this.id
}

output "resource_guid" {
  value = azurerm_cdn_frontdoor_profile.this.resource_guid
}

output "secrets" {
  value = azurerm_cdn_frontdoor_secret.this
}

output "system_assigned_identity" {
  value = try(azurerm_cdn_frontdoor_profile.this.identity[0].principal_id, null)
}
