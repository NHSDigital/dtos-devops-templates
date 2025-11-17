resource "azurerm_monitor_metric_alert" "exceptions" {
  count = var.enable_alerting ? 1 : 0

  auto_mitigate       = true
  description         = "Triggered by any Exception"
  enabled             = true
  frequency           = var.alert_frequency
  name                = "${var.name}-exceptions-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.appins.id]
  severity            = 1
  window_size         = local.alert_window_size

  action {
    action_group_id = var.action_group_id
  }

  criteria {
    aggregation            = "Count"
    metric_name            = "exceptions/count"
    metric_namespace       = "microsoft.insights/components"
    operator               = "GreaterThan"
    skip_metric_validation = false
    threshold              = 0
  }
}
