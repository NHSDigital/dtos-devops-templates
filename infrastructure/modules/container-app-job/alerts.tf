resource "azurerm_monitor_scheduled_query_rules_alert" "job_failure" {
  count = var.enable_alerting ? 1 : 0

  name                = "${azurerm_container_app_job.this.name}-containerjob-failure-alert"
  location            = var.location
  resource_group_name = var.resource_group_name_monitoring != null ? var.resource_group_name_monitoring : var.resource_group_name

  action {
    action_group = [var.action_group_id]
  }
  data_source_id = var.log_analytics_workspace_id
  description    = "Alert when ${azurerm_container_app_job.this.name} job fails"
  enabled        = true
  query          = <<-KQL
    ContainerAppSystemLogs_CL
    | where JobName_s == "${azurerm_container_app_job.this.name}"
    | where Reason_s == "ProcessExited"
    | extend ExitCode = toint(extract(@"exit code:\s*(\d+)", 1, Log_s))
    | where ExitCode != 0
  KQL
  severity       = 1
  frequency      = var.alert_frequency
  time_window    = var.time_window
  trigger {
    threshold = 0
    operator  = "GreaterThan"
  }
}
