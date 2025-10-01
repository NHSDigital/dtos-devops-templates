resource "azurerm_monitor_metric_alert" "memory" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${azurerm_container_app.main.name}-memory"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app.main.id]
  description         = "Action will be triggered when memory use is greater than ${var.alert_memory_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "memory_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.alert_memory_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "cpu" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${azurerm_container_app.main.name}-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app.main.id]
  description         = "Action will be triggered when cpu use is greater than ${var.azure_cpu_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_cpu_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_metric_alert" "storage" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${azurerm_container_app.main.name}-storage"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app.main.id]
  description         = "Action will be triggered when storage use is greater than ${var.azure_storage_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_storage_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
