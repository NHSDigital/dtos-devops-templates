resource "azurerm_public_ip" "pip" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method    = var.allocation_method
  ddos_protection_mode = var.ddos_protection_mode
  domain_name_label    = var.domain_name_label
  sku                  = var.sku
  zones                = var.zones

  tags = var.tags

}
