

# Azure Monitor alert for DToSDB CPU Percentage higher than 90% for the past 5 minutes
resource "azurerm_monitor_metric_alert" "cpu" {
  count = var.enable_alerting ? 1 : 0

  name                = "${azurerm_mssql_database.defaultdb.name}-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_mssql_database.defaultdb.id]
  description         = "Action will be triggered when cpu use is greater than ${var.alert_cpu_threshold}%"
  window_size         = var.alert_window_size
  severity            = 2
  frequency           = local.alert_frequency

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "cpu_percent"
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
