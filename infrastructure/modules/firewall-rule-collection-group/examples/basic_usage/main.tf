module "firewall_policy_rule_collection_group" {
  source = "./modules/firewall-rule-collection-group"

  name               = "example-firewall-policy-rule-collection-group"
  firewall_policy_id = module.firewall.firewall_policy_id
  priority           = 400

  application_rule_collection = [
    {
      name      = "example-application-rule-collection-1"
      priority  = 600
      action    = "Allow"
      rule_name = "example-rule-1"
      protocols = [
        {
          type = "Http"
          port = 80
        },
        {
          type = "Https"
          port = 443
        }
      ]
      source_addresses  = ["0.0.0.0/0"]
      destination_fqdns = ["example.com"]
    },
    {
      name      = "example-application-rule-collection-2"
      priority  = 700
      action    = "Allow"
      rule_name = "example-rule-1"
      protocols = [
        {
          type = "Http"
          port = 80
        },
        {
          type = "Https"
          port = 443
        }
      ]
      source_addresses  = ["0.0.0.0/0"]
      destination_fqdns = ["google.com"]
    }
  ]
  network_rule_collection = [
    {
      name                  = "example-network-rule-collection-1"
      priority              = 900
      action                = "Allow"
      rule_name             = "example-rule-1"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["80", "443"]
    }
  ]
  nat_rule_collection = [
    {
      name                = "example-nat-rule-collection-1"
      priority            = 1000
      action              = "Dnat"
      rule_name           = "example-rule-1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["*"]
      destination_address = "10.0.1.4"
      destination_ports   = ["80"]
      translated_address  = "10.0.0.10"
      translated_port     = "80"
    }
  ]

}
