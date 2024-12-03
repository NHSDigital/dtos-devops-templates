/* --------------------------------------------------------------------------------------------------
  Event Hubs Namespace and Authorization Rule
-------------------------------------------------------------------------------------------------- */
resource "azurerm_eventhub_namespace" "eventhub_ns" {

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  auto_inflate_enabled     = var.auto_inflate
  capacity                 = var.capacity
  maximum_throughput_units = var.auto_inflate ? var.maximum_throughput_units : null
  minimum_tls_version      = var.minimum_tls_version
  sku                      = var.sku

  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      capacity
    ]
  }

  tags = var.tags

}

resource "azurerm_eventhub_namespace_authorization_rule" "auth_rule" {

  name                = "${var.name}-auth-rule"
  namespace_name      = azurerm_eventhub_namespace.eventhub_ns.name
  resource_group_name = azurerm_eventhub_namespace.eventhub_ns.resource_group_name

  listen = var.auth_rule.listen
  send   = var.auth_rule.send
  manage = var.auth_rule.manage
}

/* --------------------------------------------------------------------------------------------------
  Event Hubs and Consumer Groups
-------------------------------------------------------------------------------------------------- */

resource "azurerm_eventhub" "eventhub" {
  # create multiple event hubs per namespace
  for_each = var.event_hubs

  name         = each.value.name
  namespace_id = azurerm_eventhub_namespace.eventhub_ns.id

  partition_count   = each.value.partition_count
  message_retention = each.value.message_retention
}

resource "azurerm_eventhub_consumer_group" "consumer_group" {
  for_each = var.event_hubs

  name                = each.value.consumer_group
  eventhub_name       = azurerm_eventhub.eventhub[each.key].name
  namespace_name      = azurerm_eventhub_namespace.eventhub_ns.name
  resource_group_name = azurerm_eventhub_namespace.eventhub_ns.resource_group_name
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration for Azure Event Hub
-------------------------------------------------------------------------------------------------- */

module "private_endpoint_eventhub" {
  count = var.private_endpoint_properties.private_endpoint_enabled ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-azure-eventhub-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-azure-eventhub-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_eventhub
  }

  private_service_connection = {
    name                           = "${var.name}-eventhub-private-endpoint-connection"
    private_connection_resource_id = azurerm_eventhub_namespace.eventhub_ns.id
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
  target_resource_id         = azurerm_eventhub_namespace.eventhub_ns.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_eventhub_enabled_logs
  metric                     = var.monitor_diagnostic_setting_eventhub_metrics

}

data "azurerm_client_config" "current" {}
