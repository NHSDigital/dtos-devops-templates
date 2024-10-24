output "name" {
  value = azurerm_firewall.firewall.name

}
output "id" {
  value = azurerm_firewall.firewall.id
}

output "firewall_policy_id" {
  value = azurerm_firewall.firewall.firewall_policy_id
}

output "private_ip_address" {
  value = azurerm_firewall.firewall.ip_configuration[0].private_ip_address

}
