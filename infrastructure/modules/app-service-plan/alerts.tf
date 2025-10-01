resource "azurerm_monitor_metric_alert" "memory" {
  count = var.enable_alerting == true ? 1 : 0

  name                = "${azurerm_service_plan.appserviceplan.name}-memory"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  scopes              = [azurerm_service_plan.appserviceplan.id]
  description         = "Action will be triggered when memory use is greater than ${var.alert_memory_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency
  severity            = 2 # Warning

  criteria {
    metric_namespace = "Microsoft.Web/serverFarms"
    metric_name      = "MemoryPercentage"
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
  count = var.enable_alerting == true ? 1 : 0

  name                = "${azurerm_service_plan.appserviceplan.name}-cpu"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  scopes              = [azurerm_service_plan.appserviceplan.id]
  description         = "Action will be triggered when cpu use is greater than ${var.alert_cpu_threshold}%"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency
  severity            = 2 # Warning

  criteria {
    metric_namespace = "Microsoft.Web/serverFarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.alert_cpu_threshold
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
