resource "azurerm_monitor_smart_detector_alert_rule" "service_health_incident_alert" {
  name                = "ServiceHealth-Incidents"
  resource_group_name = var.resource_group_name
  scope               = ["/subscriptions/${var.subscription_id}"]

  description         = var.description
  detector_name       = var.detector_name
  frequency           = var.frequency
  severity            = var.severity

  action_group {
    action_group_id = var.service_health_email_id
  }

  dynamic_criteria {
    alert_rule_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.AlertsManagement/smartDetectorAlertRules"
  }

  enabled = true
}

