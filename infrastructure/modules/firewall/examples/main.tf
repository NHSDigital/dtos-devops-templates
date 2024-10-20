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