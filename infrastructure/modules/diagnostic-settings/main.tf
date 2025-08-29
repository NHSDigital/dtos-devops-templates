resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = var.name
  target_resource_id         = var.target_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  storage_account_id             = var.storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  dynamic "enabled_log" {
    for_each = var.enabled_log
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = var.enabled_metric
    content {
      category = enabled_metric.value
    }
  }

}
