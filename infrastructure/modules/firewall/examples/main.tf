module "firewall" {
  source = "./modules/firewall"

  firewall_name         = "myFirewall"
  resource_group_name   = module.resource_group["hub"].resource_group_name
  location              = module.resource_group["hub"].resource_group_location
  sku_name              = "AZFW_VNet"
  sku_tier              = "Premium"
  zones                 = module.public_ip.zones
  additional_public_ips = []
  public_ip_address_id  = module.public_ip.id
  firewall_subnet_id    = module.subnet.subnet_id

  tags = {
    environment = "Terraform"
  }

  ### policy variables
  policy_name              = "myFirewallPolicy"
  sku                      = "Premium"
  threat_intelligence_mode = "Alert"
  dns_proxy_enabled        = false
  dns_servers              = module.private-dns-zone-resolver.private_dns_resolver_ip

  depends_on = [module.public_ip
    , module.subnet
    , module.resource_group
  ]
}

module "firewall_policy_rule_collection_group" {
  source = "./modules/firewall-rule-collection-group"

  name               = "firewall-policy-rule-collection-group"
  firewall_policy_id = module.firewall.firewall_policy_id
  priority           = 400

  application_rule_collection = []
  network_rule_collection = [
    {
      name                  = "spoke01-spoke02"
      priority              = 900
      action                = "Allow"
      rule_name             = "spoke01-spoke02"
      protocols             = ["*P"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["10.3.0.0/16"]
      destination_ports     = ["*"]
    },
    {
      name                  = "spoke02-spoke01"
      priority              = 900
      action                = "Allow"
      rule_name             = "spoke02-spoke01"
      protocols             = ["*P"]
      source_addresses      = ["10.3.0.0/16"]
      destination_addresses = ["10.1.0.0/16"]
      destination_ports     = ["*"]
    }
  ]
  nat_rule_collection = []

}
