resource "azurerm_monitor_metric_alert" "memory" {
  count = var.enable_alerting ? 1 : 0

  name                = "${azurerm_container_app.main.name}-memory"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app.main.id]
  description         = "Action will be triggered when memory use is greater than ${var.alert_memory_threshold}% of container limit"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.alert_memory_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "cpu" {
  count = var.enable_alerting ? 1 : 0

  name                = "${azurerm_container_app.main.name}-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app.main.id]
  description         = "Action will be triggered when cpu use is greater than ${var.azure_cpu_threshold}% of container limit"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.azure_cpu_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}
