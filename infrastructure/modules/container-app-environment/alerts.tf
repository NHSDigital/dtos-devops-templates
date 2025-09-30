resource "azurerm_monitor_metric_alert" "memory" {
  count = var.enable_monitoring ? 1 : 0

  name                = "${azurerm_container_app_environment.main.name}-memory-usage"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app_environment.main.id]
  description         = "Action will be triggered when memory usage exceeds ${var.alert_memory_threshold}% in the Container App Environment"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.App/managedEnvironments"
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

  name                = "${azurerm_container_app_environment.main.name}-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app_environment.main.id]
  description         = "Action will be triggered when cpu use is greater than ${var.azure_cpu_threshold}% in the Container App Environment"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.App/managedEnvironments"
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

  name                = "${azurerm_container_app_environment.main.name}-storage"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_app_environment.main.id]
  description         = "Action will be triggered when storage use is greater than ${var.azure_storage_threshold}% in the Container App Environment"
  window_size         = var.alert_window_size
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.App/managedEnvironments"
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
