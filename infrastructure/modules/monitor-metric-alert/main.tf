resource "azurerm_monitor_metric_alert" "planned_maintenance_alert" {
  name                = var.name
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${var.subscription_id}"]

  description          = "Alerts on Azure planned maintenance"
  severity             = var.severity
  frequency            = var.frequency
  evaluation_frequency = var.evaluation_frequency
  window_size          = var.window_size

  criteria {
    metric_namespace = "microsoft.insights/alertrules"
    metric_name      = "PlannedMaintenance"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}
