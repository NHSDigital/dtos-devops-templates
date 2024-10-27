module "public_ip" {
  source = "./modules/public-ip"

  name                 = "api-management-pip"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  allocation_method    = "Static"
  zones                = ["1"]
  sku                  = "Standard"
  ddos_protection_mode = "VirtualNetworkInherited"
  domain_name_label    = "api-management"
  tags = {
    environment = "Terraform"
  }
}

module "api-management" {
  source               = "./modules/api-management"
  name                 = "api-management"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  publisher_name       = "Example Ltd."
  publisher_email      = "email@example.com"
  sku_name             = "Developer"
  sku_capacity         = 1
  zones                = []
  virtual_network_type = "Internal"
  public_ip_address_id = module.public_ip.id
  additional_locations = []
  virtual_network_configuration = [module.subnets["apim"].id
  ]

  gateway_disabled    = false
  certificate_details = []
  tags = {
    environment = "dev"
  }
  depends_on = [module.subnets]
}
