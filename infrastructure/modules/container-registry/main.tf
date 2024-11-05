
resource "azurerm_container_registry" "acr" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.uai.id]
  }
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration
-------------------------------------------------------------------------------------------------- */

module "private_endpoint_container_registry" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids
  }

  private_service_connection = {
    name                           = "${var.name}-private-endpoint-connection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}
