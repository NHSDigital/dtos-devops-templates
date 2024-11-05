resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = var.sku_name
  sku_tier = var.sku_tier

  zones = var.zones

  firewall_policy_id = module.firewall-policy.id

  dynamic "ip_configuration" {
    for_each = toset(var.ip_configuration)
    content {
      name                 = ip_configuration.value.name
      public_ip_address_id = ip_configuration.value.public_ip_address_id
      subnet_id            = ip_configuration.value.firewall_subnet_id
    }
  }

  tags = var.tags
}

module "firewall-policy" {
  source = "../firewall-policy"

  policy_name         = var.policy_name
  resource_group_name = var.resource_group_name
  location            = var.location

  dns_proxy_enabled        = var.dns_proxy_enabled
  dns_servers              = var.dns_servers
  sku                      = var.sku
  threat_intelligence_mode = var.threat_intelligence_mode

  tags = var.tags
}
