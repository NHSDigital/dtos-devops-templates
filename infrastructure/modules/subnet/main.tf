resource "azurerm_subnet" "subnet" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = var.address_prefixes
  virtual_network_name = var.vnet_name

  default_outbound_access_enabled = var.default_outbound_access_enabled

  dynamic "delegation" {
    for_each = var.delegation_name != "" ? [1] : []
    content {
      name = var.delegation_name

      service_delegation {
        name    = var.service_delegation_name
        actions = var.service_delegation_actions
      }
    }
  }

  private_endpoint_network_policies = var.private_endpoint_network_policies
}


module "nsg" {
  count = var.create_nsg ? 1 : 0

  source = "git::https://github.com/NHSDigital/dtos-devops-templates.git//infrastructure/modules/network-security-group?ref=e125d928afd9546e06d8af9bdb6391cbf6336773"

  name                = var.network_security_group_name
  resource_group_name = var.resource_group_name
  location            = var.location
  nsg_rules           = var.network_security_group_nsg_rules

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  count = var.create_nsg ? 1 : 0

  subnet_id = azurerm_subnet.subnet.id
  # Count in module "nsg" results in a list of 0 or 1 elements, so we need to use a list index in the below
  network_security_group_id = module.nsg[0].id
}
