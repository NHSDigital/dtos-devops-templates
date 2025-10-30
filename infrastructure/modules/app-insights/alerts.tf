resource "azurerm_monitor_metric_alert" "exceptions" {
  count = var.enable_alerting ? 1 : 0

  auto_mitigate            = true
  description              = "Triggered by any Exception"
  enabled                  = true
  frequency                = var.alert_frequency
  name                     = "Exceptions"
  resource_group_name      = var.resource_group_name
  scopes                   = [azurerm_application_insights.appins.id]
  severity                 = 1
  window_size              = local.alert_window_size

  action {
    action_group_id    = var.action_group_id
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

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "custom_alert" {
  count = can(var.enable_alerting && var.custom_alert_query != null ) ? 1 : 0

  auto_mitigation_enabled           = false
  description                       = "An alert triggered when a result is returned for the query provided"
  enabled                           = var.enable_alerting
  evaluation_frequency              = var.alert_frequency
  location                          = var.location
  name                              = "${var.resource_group_name}-custom-alert"
  resource_group_name               = var.resource_group_name
  scopes                            = [azurerm_application_insights.appins.id]
  severity                          = 3
  skip_query_validation             = false
  target_resource_types             = ["microsoft.insights/components"]
  window_duration                   = local.alert_window_size
  workspace_alerts_storage_enabled  = false

  action {
    action_groups     = [var.action_group_id]
  }

  criteria {
    operator                = "GreaterThan"
    query                   = var.custom_alert_query
    threshold               = 0
    time_aggregation_method = "Count"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}

