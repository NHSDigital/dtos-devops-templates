resource "azurerm_storage_account" "storage_account" {

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_replication_type      = var.account_replication_type
  account_tier                  = var.account_tier
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags

  blob_properties {
    delete_retention_policy {
      days = var.blob_properties_delete_retention_policy
    }
    versioning_enabled = var.blob_properties_versioning_enabled
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_container" "container" {
  for_each = var.containers

  name                  = each.value.container_name
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = each.value.container_access_type
}

resource "azurerm_storage_queue" "queue" {
  for_each = var.queues

  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
}

/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration
-------------------------------------------------------------------------------------------------- */

module "private_endpoint_blob_storage" {
  count = can(var.private_endpoint_properties.private_endpoint_enabled) ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-blob-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-blob-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_blob
  }

  private_service_connection = {
    name                           = "${var.name}-blob-private-endpoint-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

module "private_endpoint_table_storage" {
  count = can(var.private_endpoint_properties.private_endpoint_enabled && var.private_endpoint_properties.private_dns_zone_ids_table != []) ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-table-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-table-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_table
  }

  private_service_connection = {
    name                           = "${var.name}-table-private-endpoint-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["table"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

module "private_endpoint_queue_storage" {
  count = can(var.private_endpoint_properties.private_endpoint_enabled) ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-queue-private-endpoint"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-queue-private-endpoint-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_queue
  }

  private_service_connection = {
    name                           = "${var.name}-queue-private-endpoint-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["queue"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

module "diagnostic-settings" {
  for_each = var.storage_account_service

  source = "../diagnostic-settings"

  name                       = "${var.name}-diagnotic-setting-storage"
  target_resource_id         = "${azurerm_storage_account.storage_account.id}/${each.value}/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log                = var.monitor_diagnostic_setting_storage_account_enabled_logs
  metric                     = var.monitor_diagnostic_setting_storage_account_metrics

}
