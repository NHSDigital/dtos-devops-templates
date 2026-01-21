/* --------------------------------------------------------------------------------------------------
  Azure Relay Namespace
-------------------------------------------------------------------------------------------------- */
resource "azurerm_relay_namespace" "relay" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration for Azure Relay Namespace
-------------------------------------------------------------------------------------------------- */
module "private_endpoint_relay" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-azure-relay-pep"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-azure-relay-pep-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_relay
  }

  private_service_connection = {
    name                           = "${var.name}-relay-pep-connection"
    private_connection_resource_id = azurerm_relay_namespace.relay.id
    subresource_names              = ["namespace"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

/* --------------------------------------------------------------------------------------------------
  Diagnostic Settings
-------------------------------------------------------------------------------------------------- */
module "diagnostic-settings" {
  source = "../diagnostic-settings"

  name                       = "${var.name}-diagnostic-setting"
  target_resource_id         = azurerm_relay_namespace.relay.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_relay_enabled_logs
  enabled_metric             = var.monitor_diagnostic_setting_relay_metrics
}
