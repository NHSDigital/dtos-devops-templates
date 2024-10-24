resource "azurerm_firewall" "firewall" {
  name                = var.firewall_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_name = var.sku_name
  sku_tier = var.sku_tier

  zones = var.zones

  firewall_policy_id = module.firewall-policy.id

  ip_configuration {
    name                 = var.ip_configuration_name
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = var.public_ip_address_id
  }

  dynamic "ip_configuration" {
    for_each = toset(var.additional_public_ips)
    content {
      name                 = ip_configuration.value.name
      public_ip_address_id = ip_configuration.value.public_ip_address_id
    }
  }

  tags = var.tags

  depends_on = [module.firewall-policy]


}

module "firewall-policy" {

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/firewall-policy?ref=e4cf26bd62cdc01c7066e46180950ff05fbe36bb"

  policy_name              = var.policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku
  threat_intelligence_mode = var.threat_intelligence_mode
  dns_proxy_enabled        = var.dns_proxy_enabled
  dns_servers              = var.dns_servers

  tags = var.tags
}
