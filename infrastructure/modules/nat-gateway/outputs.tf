output "id" {
  description = "The ID of the NAT gateway."
  value       = azurerm_nat_gateway.nat_gateway.id
}

output "name" {
  description = "The name of the NAT gateway."
  value       = azurerm_nat_gateway.nat_gateway.name
}

output "public_ip_address" {
  description = "The public IP address associated with the NAT gateway."
  value       = module.pip.ip_address
}
