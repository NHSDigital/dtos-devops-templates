# private dns resolver
resource "azurerm_private_dns_resolver" "private_dns_resolver" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_network_id  = var.vnet_id

  tags = var.tags
}

# azurerm_private_dns_resolver_inbound_endpoint
resource "azurerm_private_dns_resolver_inbound_endpoint" "private_dns_resolver_inbound_endpoint" {
  count = length(var.inbound_endpoint_config) > 0 ? 1 : 0

  name                    = var.inbound_endpoint_config.name
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.private_dns_resolver.id

  ip_configurations {
    private_ip_allocation_method = var.inbound_endpoint_config.private_ip_allocation_method
    subnet_id                    = var.inbound_endpoint_config.subnet_id
  }
}

# azurerm_private_dns_resolver_outbound_endpoint
resource "azurerm_private_dns_resolver_outbound_endpoint" "private_dns_resolver_outbound_endpoint" {
  count = length(var.outbound_endpoint_config) > 0 ? 1 : 0

  name                    = var.outbound_endpoint_config.name
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.private_dns_resolver.id
  subnet_id               = var.outbound_endpoint_config.subnet_id
}
