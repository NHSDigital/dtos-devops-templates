output "id" {
  description = "The ID of the Bastion host."
  value       = azurerm_bastion_host.bastion.id
}

output "name" {
  description = "The name of the Bastion host."
  value       = azurerm_bastion_host.bastion.name
}

output "dns_name" {
  description = "The FQDN of the Bastion host."
  value       = azurerm_bastion_host.bastion.dns_name
}

output "public_ip_address" {
  description = "The public IP address associated with the Bastion host."
  value       = module.pip.ip_address
}
