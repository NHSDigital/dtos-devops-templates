output "endpoint" {
  value = azurerm_cdn_frontdoor_endpoint.this
}

output "origin_group" {
  value = azurerm_cdn_frontdoor_origin_group.this
}

output "origin" {
  value = azurerm_cdn_frontdoor_origin.this
}