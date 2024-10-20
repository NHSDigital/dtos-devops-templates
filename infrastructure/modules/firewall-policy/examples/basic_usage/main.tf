module "firewall-policy" {
  source = "../../modules/firewall-policy"

  name                     = var.policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku
  threat_intelligence_mode = var.threat_intelligence_mode
  dns_proxy_enabled        = var.dns_proxy_enabled
  dns_servers              = var.dns_servers

  tags = var.tags
}