resource "azurerm_monitor_metric_alert" "planned_maintenance_alert" {
  name                = "ServiceHealth-PlannedMaintenance"
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${var.subscription_id}"]

  description         = "Alerts on Azure planned maintenance"
  severity            = 2
  frequency           = "PT5M"
  evaluation_frequency = "PT5M"
  window_size          = "PT5M"

  criteria {
    metric_namespace = "microsoft.insights/alertrules"
    metric_name      = "PlannedMaintenance"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = var.service_health_email_id
  }
}
