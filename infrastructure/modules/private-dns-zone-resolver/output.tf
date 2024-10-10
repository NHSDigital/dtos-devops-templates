output "name" {
  value = azurerm_private_dns_resolver.private_dns_resolver.name
}

output "inbound_endpoint_ip_address" {
  value = azurerm_private_dns_resolver_inbound_endpoint.private_dns_resolver_inbound_endpoint.inbound_endpoint_ip_address
}
