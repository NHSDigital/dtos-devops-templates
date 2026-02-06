resource "azurerm_monitor_scheduled_query_rules_alert_v2" "ag_certificate_expired" {
  count = var.enable_alerting == true ? 1 : 0

  name                = "${azurerm_application_gateway.this.name}-certificate-expired"
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name
  location            = var.location

  evaluation_frequency = var.certificate_expired_alert.evaluation_frequency
  window_duration      = var.certificate_expired_alert.window_duration
  scopes               = [azurerm_application_gateway.this.id]
  severity             = 2

  criteria {
    query = <<-QUERY
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.NETWORK"
| where Category == "ApplicationGatewayAccessLog"
| where OperationName contains "Ssl"
       or OperationName contains "Certificate"
       or Details_s contains "Certificate"
       or failureDetails_s contains "certificate"
| extend Status = toint(httpStatus_d)
| where Status == 502
| project
    Details = column_ifexists("Details_s","")
| summarize Events=count() by Details
QUERY

    time_aggregation_method = "Total"
    threshold               = var.certificate_expired_alert.threshold
    operator                = "GreaterThanOrEqual"

    resource_id_column    = "Details"
    metric_measure_column = "Events"

    dimension {
      name     = "Details"
      operator = "Include"
      values   = ["*"]
    }
  }

  description = "The Application Gateway certificate has expired."

  action {
    action_groups = [var.action_group_id]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
