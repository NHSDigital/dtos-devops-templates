resource "azurerm_monitor_smart_detector_alert_rule" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  scope_resource_ids  = var.scope_resource_ids

  description         = var.description
  detector_type       = var.detector_type
  frequency           = var.frequency
  severity            = var.severity

  action_group {
    ids = [ var.action_group_id ]
  }

  # dynamic_criteria {
  #   alert_rule_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.AlertsManagement/smartDetectorAlertRules"
  # }

  enabled = true
}
