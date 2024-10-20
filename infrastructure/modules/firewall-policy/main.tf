resource "azurerm_firewall_policy" "firewall_policy" {
  name                     = var.policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku
  threat_intelligence_mode = var.threat_intelligence_mode
  dns {
    proxy_enabled = var.dns_proxy_enabled
    servers       = var.dns_servers
  }

  tags = var.tags
}
