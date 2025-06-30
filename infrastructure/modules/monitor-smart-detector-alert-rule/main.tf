resource "azurerm_monitor_smart_detector_alert_rule" "service_health_incident_alert" {
  name                = "ServiceHealth-Incidents"
  resource_group_name = var.resource_group_name
  scope               = ["/subscriptions/${var.subscription_id}"]

  description         = "Alerts on Azure service incidents and advisories"
  detector_name       = "ServiceHealth"
  frequency           = "PT5M"
  severity            = 2

  action_group {
    action_group_id = var.service_health_email_id
  }

  dynamic_criteria {
    alert_rule_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.AlertsManagement/smartDetectorAlertRules"
  }

  enabled = true
}

