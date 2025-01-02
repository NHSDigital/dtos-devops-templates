resource "azurerm_eventgrid_topic" "azurerm_eventgrid" {
  name                = var.topic_name
  resource_group_name = var.resource_group_name
  location            = var.location

  identity {
    type = var.identity_type
  }

  dynamic "inbound_ip_rule" {
    for_each = var.inbound_ip_rules
    content {
      ip_mask = inbound_ip_rule.value["ip_mask"]
      action  = inbound_ip_rule.value["action"]
    }
  }

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration
-------------------------------------------------------------------------------------------------- */

module "private_endpoint" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.topic_name}-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.topic_name}-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids
  }

  private_service_connection = {
    name                           = "${var.topic_name}-private-endpoint-connection"
    private_connection_resource_id = azurerm_eventgrid_topic.azurerm_eventgrid.id
    subresource_names              = ["sites"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}
