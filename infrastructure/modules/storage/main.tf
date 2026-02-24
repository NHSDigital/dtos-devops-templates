resource "azurerm_storage_account" "storage_account" {

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_replication_type      = var.account_replication_type
  account_tier                  = var.account_tier
  public_network_access_enabled = var.public_network_access_enabled
  access_tier                   = var.access_tier

  tags = var.tags

  blob_properties {
    delete_retention_policy {
      days = var.blob_properties_delete_retention_policy
    }
    versioning_enabled = var.blob_properties_versioning_enabled

    container_delete_retention_policy {
      days = var.container_delete_retention_policy_days
    }

    change_feed_enabled = var.blob_properties_change_feed_enabled

    dynamic "restore_policy" {
      for_each = var.blob_properties_restore_policy_days != null ? [1] : []
      content {
        days = var.blob_properties_restore_policy_days
      }
    }
  }

  dynamic "share_properties" {
    for_each = var.share_properties_retention_policy_days != null ? [1] : []
    content {
      retention_policy {
        days = var.share_properties_retention_policy_days
      }
    }
  }

  lifecycle {
    ignore_changes = [tags]

    # Validation 1: Prevent the Change Feed / Restore Policy mismatch
    precondition {
      condition     = var.blob_properties_restore_policy_days == null || var.blob_properties_change_feed_enabled == true
      error_message = "Invalid configuration: If blob_properties_restore_policy_days is set, blob_properties_change_feed_enabled must be explicitly set to true."
    }

    # Validation 2: Prevent the Days limit mismatch
    precondition {
      condition     = var.blob_properties_restore_policy_days == null ? true : (var.blob_properties_restore_policy_days < var.blob_properties_delete_retention_policy)
      error_message = "Invalid configuration: blob_properties_restore_policy_days must be strictly less than blob_properties_delete_retention_policy."
    }
  }
}

resource "azurerm_storage_container" "container" {
  for_each = var.containers

  name                  = each.value.container_name
  storage_account_id    = azurerm_storage_account.storage_account.id
  container_access_type = each.value.container_access_type

  depends_on = [module.private_endpoint_blob_storage]
}

resource "azurerm_storage_queue" "queue" {
  for_each = var.queues != null ? toset(var.queues) : toset([])

  name                 = each.value
  storage_account_name = azurerm_storage_account.storage_account.name

  depends_on = [module.private_endpoint_queue_storage]
}


/* --------------------------------------------------------------------------------------------------
  Private Endpoint Configuration
-------------------------------------------------------------------------------------------------- */

module "private_endpoint_blob_storage" {
  count = can(var.private_endpoint_properties.private_endpoint_enabled) ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-blob-pep"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-blob-pep-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_blob
  }

  private_service_connection = {
    name                           = "${var.name}-blob-pep-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

module "private_endpoint_table_storage" {
  count = can(var.private_endpoint_properties.private_endpoint_enabled && var.private_endpoint_properties.private_dns_zone_ids_table != []) ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-table-pep"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-table-pep-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_table
  }

  private_service_connection = {
    name                           = "${var.name}-table-pep-connection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["table"]
    is_manual_connection           = var.private_endpoint_properties.private_service_connection_is_manual
  }

  tags = var.tags
}

module "private_endpoint_queue_storage" {
  count = can(var.private_endpoint_properties.private_endpoint_enabled) ? 1 : 0

  source = "../private-endpoint"

  name                = "${var.name}-queue-pep"
  resource_group_name = var.private_endpoint_properties.private_endpoint_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_properties.private_endpoint_subnet_id

  private_dns_zone_group = {
    name                 = "${var.name}-queue-pep-zone-group"
    private_dns_zone_ids = var.private_endpoint_properties.private_dns_zone_ids_queue
  }

  private_service_connection = {
    name                           = "${var.name}-queue-pep-connection"
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
  enabled_metric             = var.monitor_diagnostic_setting_storage_account_metrics

}

module "diagnostic-settings-sa-resource" {

  source = "../diagnostic-settings"

  name                       = "${azurerm_storage_account.storage_account.name}-diagnotic-setting-storage-account"
  target_resource_id         = "${azurerm_storage_account.storage_account.id}"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_metric             = var.monitor_diagnostic_setting_storage_account_resource_metrics

}
