output "custom_domains" {
  value = azurerm_cdn_frontdoor_custom_domain.this
}

output "endpoint" {
  value = azurerm_cdn_frontdoor_endpoint.this
}

output "origin_group" {
  value = azurerm_cdn_frontdoor_origin_group.this
}

output "origins" {
  value = azurerm_cdn_frontdoor_origin.this
}

output "route" {
  value = azurerm_cdn_frontdoor_route.this
}

output "security_policy" {
  value = azurerm_cdn_frontdoor_security_policy.this
}
