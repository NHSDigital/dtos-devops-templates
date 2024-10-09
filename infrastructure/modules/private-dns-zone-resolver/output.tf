output "name" {
  value = azurerm_private_dns_resolver.private_dns_resolver.name
}

output "private_dns_resolver_ip" {
  value = length(azurerm_private_dns_resolver_inbound_endpoint.private_dns_resolver_inbound_endpoint) > 0 ? azurerm_private_dns_resolver_inbound_endpoint.private_dns_resolver_inbound_endpoint[0].ip_configurations[0].private_ip_address : null
}
